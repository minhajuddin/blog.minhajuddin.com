title: How to deploy a simple phoenix app on a single server using distillery
date: 2016-11-13 16:09:14
tags:
- Phoenix
- Elixir
- Distillery
- Git
- Deploy
- Heroku
---

### If you find issues or can improve this guide, please create a pull request at:

## 0. Assumptions
# TODO: make these assumptions in the form a table
  1. Our local computer is an ubuntu machine with ruby, git and elixir installed.
  2. We are deploying to a server whose hostname is `slugex.com`
  3. The server process runs under a user called `slugex`
  4. The server is an ubuntu machine which has git, postgresql, elixir, nginx and nodejs installed
  5. We'll be running our app server behind nginx
  6. We'll be setting up SSL using letsencrypt
  7. We'll be using distillery to do the deploys
  8. We'll be using git tags to tag releases?
  9. We'll be running our builds on the production server

## 1. Install the prerequisites on the server (on server)
[Install elixir](http://elixir-lang.org/install.html), [git](https://help.ubuntu.com/lts/serverguide/git.html),
[postgresql](https://help.ubuntu.com/community/PostgreSQL) and [nodejs](https://nodejs.org/en/download/package-manager/)

```sh
## commands to be executed on our server
# elixir and erlang
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
sudo dpkg -i erlang-solutions_1.0_all.deb
sudo apt-get update
sudo apt-get install esl-erlang
sudo apt-get install elixir

# git
sudo apt-get install git

# postgresql
sudo apt-get install postgresql postgresql-contrib

# nodejs
curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -
sudo apt-get install -y nodejs
```

## 2. Setup the server
We'll be running our server under the user called `slugex`. So, we first need
to create that user.

```sh
## commands to be executed on our server
APP_USER=slugex

# create prent dir for our home
sudo mkdir -p /opt/www
# create the user
sudo useradd --home "/opt/www/$APP_USER" --create-home --shell /bin/bash $APP_USER
# create the postgresql role for our user
sudo -u postgres createuser --echo --no-createrole --no-superuser --createdb $APP_USER
```

## 3. Install the git-deploy rubygem on our local computer
We'll be using the [git-deploy](https://github.com/mislav/git-deploy) rubygem to
do deploys. This allows deploys similar to Heroku. You just need to push to your
  production git repository to start a deployment.

```sh
## commands to be executed on our local computer
# install the gem
# you need ruby installed on your computer for this
gem install git-deploy
```

## 4. Setup distillery in our phoenix app (on local computer)
We'll be using [distillery](https://github.com/bitwalker/distillery) to manage our releases.

Add the distillery dependency to our `mix.exs`

```elixir
defp deps do
  [{:distillery, "~> 0.10"}]
end
```

Init the distillery config
```sh
# get dependencies
mix deps.get
# init distillery
mix release.init
```

Change `rel/config.ex` to look like below

```elixir
...
environment :prod do
  set include_erts: false
  set include_src: false
  # cookie info ...
end
...
```

## 5. Setup git deploy (local computer)
Let us setup the remote and the deploy hooks

```sh
## commands to be executed on our local computer

# setup the git remote pointing to our prod server
git remote add prod slugex@slugex.com:/opt/www/slugex

# init
git deploy setup -r "prod"
# create the deploy files
git deploy init
# push to production
git push prod master
```

## TODO: release this as a book

## 6. Setup postgresql access

```sh
## commands to be executed on the server as the slugex user

# create the database
createdb slugex_prod

# set the password for the slugex user
psql slugex_prod
> slugex_prod=> \password slugex
> Enter new password: enter the password
> Enter it again: repeat the password
```

## 6. Setup the prod.secret.exs
Copy the config/prod.secret.exs file from your local computer to /opt/www/slugex/config/prod.secret.exs

```sh
## on local computer from our phoenix app directory
scp config/prod.secret.exs slugex@slugex.com:config/
```

create a new secret on your local computer using `mix phoenix.gen.secret` and
paste it in the server's config/prod.secret.exs secret

It should look something like below:

```elixir
# on the server
# /opt/www/slugex/config/prod.secret.exs
use Mix.Config

config :simple, Simple.Endpoint,
  secret_key_base: "RgeM4Dt8kl3yyf47K1DXWr8mgANzOL9TNOOiCknZM8LLDeSdS1ia5Vc2HkmKhy68"
  http: [port: 4010],
  server: true, # <=== this is very important
  root: "/opt/www/slugex",
  url: [host: "slugex.com", port: 443],
  cache_static_manifest: "priv/static/manifest.json"

# Do not print debug messages in production
config :logger, level: :info

# Configure your database
config :simple, Simple.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "slugex",
  password: "another brick in the wall",
  database: "slugex_prod",
  pool_size: 20
```

## 6. Tweak the deploy scripts

## 7. One time setup on the server

```sh
## commands to be executed on server as slugex
MIX_ENV=prod mix do compile, ecto.create
MIX_ENV=prod ./deploy/after_push
```

## Logger

## Exception notifications

## Setup systemd

## 6. One time setup on server (on server as slugex user)

```sh
## commands to be run on the server as the slugex user
cd /opt/www/slugex

# create the secrets config
echo 'use Mix.Config' > config/prod.secrets.exs
# add your configuration to this file

# update hex
export MIX_ENV=prod
mix local.hex --force
mix deps.get
mix ecto.create

```


## 6. Nginx configuration

## 7. Letsencrypt setup and configuration

## 9. TODO: Configuration using conform

## 10. TODO: database backups to S3
## 10. TODO: uptime monitoring of websites using uptime monitor
## 10. TODO: email via SES
## 10. TODO: db seeds
## 10. TODO: nginx caching basics, static assets large expirations
## 10. TODO: remote console for debugging
sudo letsencrypt certonly --webroot -w /opt/www/webmonitor/public/ -d webmonitorhq.com  --webroot -w /opt/www/webmonitor/public/ -d www.webmonitorhq.com

## 11. Check SSL certificate: https://www.sslshopper.com/ssl-checker.html

### Common mistakes/errors
 1. SSH errors

### Improvements
 1. Automate all of these using a hex package?
 2. Remove dependencies on `git-deploy` if possible
 3. Hot upgrades
