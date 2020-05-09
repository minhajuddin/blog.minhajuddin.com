title: >-
  How to use a single aurora cluster for multiple databases each with its own
  restricted user
date: 2020-05-09 15:58:55
tags:
- AWS
- Aurora
- RDS
- Postgres
- Multiple
- Restricted
- Isolated
- User
- Terraform
- Postgres provider
---

I have been playing around with terraform for the last few days and it is an
amazing tool to manage infrastructure. For my AWS infrastructure I needed an
aurora postgresql cluster which would allow hosting of multiple databases, each
for one of my side projects, while also keeping them isolated and preventing
an app user from accessing other app's databases.

{% asset_img db.png %}

[Terraform has an awesome postgresql
provider](https://www.terraform.io/docs/providers/postgresql/index.html) which
can be used for managing databases, However there are a few parts which are
tricky and needed trial and error to get right.

## Connecting to an RDS database via an SSH tunnel

The first roadblock was that my RDS cluster wasn't accessible publicly (which is
how it should be for security reasons). I do have a [way to connect to my
postgres servers via a bastion
host](https://minhajuddin.com/2020/05/06/how-to-create-temporary-bastion-ec2-instances-using-terraform/).
I thought we could use an SSH tunnel over the bastion host to get to our RDS
cluster from my local computer. However, terraform doesn't support
connecting to the postgres server over an SSH tunnel via its configuration.

So, it required a little bit of jerry-rigging. The postgresql provider was happy
as long as it could reach the postgres cluster using a host, port and password.
So, I set up a local tunnel outside terraform via my SSH config like so:

```ssh
Host bastion
Hostname ec2-180-21-145-48.us-east-2.compute.amazonaws.com
IdentityFile ~/.ssh/aws_ssh.pem

Host ecs1-pg
  LocalForward localhost:3333 hn-aurora-pg-1.hosturl.us-east-2.rds.amazonaws.com:5432

Host ecs1 ecs1-pg
  Hostname 20.10.22.214
  User ec2-user
  IdentityFile ~/.ssh/aws_ssh.pem
  ForwardAgent yes
  ProxyJump bastion
```

The relevant line here is the `LocalForward` declaration which wires up a local
port forward so that when you network traffic hits port `3333` on your
`localhost` it is tunneled over the bastion and then the ecs server and is
routed to your cluster's port `5432`. One thing to note here is that your ecs
cluster should be able to connect to your RDS cluster via proper security group
rules.

## Setting up the postgres provider

Once you have the ssh tunnel set up, you can start wiring up your postgres
provider for terraform like so:

```hcl
provider "postgresql" {
  version = "~> 1.5"

  # LocalForwarded on the local computer via an SSH tunnel to
  # module.hn_db.this_rds_cluster_endpoint
  # via
  # LocalForward localhost:3333 module.hn_db.this_rds_cluster_endpoint:5432
  host            = "localhost"
  port            = 3333
  username        = "root"
  superuser       = false
  password        = module.hn_db.this_rds_cluster_master_password
  sslmode         = "require"
  connect_timeout = 15
}
```

The provider config is pretty straightforward, we point it to `localhost:3333`
with a `root` user (which is the master user created by the rds cluster). So,
when you connect to `localhost:3333`, you are actually connecting to the RDS
cluster through an SSH tunnel (make sure that your ssh connection is open at
this point via `ssh ecs1-pg` in a separate terminal). We also need to set the
`superuser` to `false` because RDS doesn't give us a postgres superuser, getting
this wrong initially caused me a lot of frustration.

## Setting up the database and it's user

Now that our cluster connectivity is set up, we can start creating the databases
and users, each for one of our apps.

Below is a sensible configuration for a database called `liveform_prod` and it's
user called `liveform`.

```hcl
locals {
  lf_connection_limit  = 5
  lf_statement_timeout = 60000 # 1 minute
}

resource "postgresql_database" "liveform_db" {
  name             = "liveform_prod"
  owner            = postgresql_role.liveform_db_role.name
  connection_limit = local.lf_connection_limit
}

resource "postgresql_role" "liveform_db_role" {
  name              = "liveform"
  login             = true
  password          = random_password.liveform_db_password.result
  connection_limit  = local.lf_connection_limit
  statement_timeout = local.lf_statement_timeout
}

resource "random_password" "liveform_db_password" {
  length  = 40
  special = false
}

output "liveform_db_password" {
  description = "Liveform db password"
  value       = random_password.liveform_db_password.result
}
```

A few things to note here:
  1. The database `liveform_prod` is owned by a new user called `liveform`.
  2. It has a connection limit of `5`, You should always set a sensible
     connection limit to prevent this app from crashing the cluster.
  3. The db user too has a connection limit of `5` and a statement timeout of 1
     minute which is big enough for web apps, you should set it to the least
     duration which works for your app.
  4. A random password (via the `random_password` resource) is used as the
     password of our new `liveform` role. This can be viewed by running
     `terraform show`

## Isolating this database from other users

By default postgres allows all users to connect to all databases and create/view
from all the tables. We want our databases to be isolated properly so that a
user for one app cannot access another app's database. This requires running of
some SQL on the newly created database. We can easily do this using a
`null_resource` and a `local-exec` provisioner like so:

```hcl
resource "null_resource" "liveform_db_after_create" {
  depends_on = [
    postgresql_database.liveform_db,
    postgresql_role.liveform_db_role
  ]

  provisioner "local-exec" {
    command = "./pg_database_roles_setup.sh"
    environment = {
      PG_DB_ROLE_NAME = postgresql_role.liveform_db_role.name
      PG_DB_NAME      = postgresql_database.liveform_db.name
      PGPASSWORD      = random_password.liveform_db_password.result
    }
  }
}
```

`./pg_database_roles_setup.sh` script:

```bash
#!/bin/bash

set -e

# This needs an SSH TUNNEL to be set up
# password needs to be supplied via the PGPASSWORD env var
psql --host "localhost" \
    --port "3333" \
    --username "$PG_DB_ROLE_NAME" \
    --dbname "$PG_DB_NAME" \
    --file - <<SQL
  REVOKE CONNECT ON DATABASE $PG_DB_NAME FROM PUBLIC;
  GRANT CONNECT ON DATABASE $PG_DB_NAME TO $PG_DB_ROLE_NAME;
  GRANT CONNECT ON DATABASE $PG_DB_NAME TO root;
SQL
```

The `pg_database_roles_setup.sh` script connects to our rds cluster over the SSH
tunnel to the newly created database as the newly created user and revokes
connect privileges for all users on this database, and then adds connect
privileges to the app user and the root user. You can add more queries to this
script that you might want to run after the database is set up. Finally, the
`local-exec` provisioner passes the right data via environment variables and
calls the database setup script.

## Gotchas
If you create a `posgresql_role` before setting the connection's `superuser` to
`false`, you'll get stuck trying to update or delete the new role. To work around
this, manually log in to the rds cluster via psql and `DROP` the role, and remove
this state from terraform using: `terraform state rm
postgresql_role.liveform_db_role`
