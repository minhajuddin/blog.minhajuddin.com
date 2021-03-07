title: A simple way to store secrets using Parameter Store for your ECS applications
date: 2021-03-07 13:52:40
tags:
- ECS
- Secrets
- Environment Variables
- Parameter Store
- AWS
- Docker
- Terraform
---

I have an ECS cluster for my side projects and need to pass secrets to the app.
There are a few ways of doing it, and I think I found a nice balance between
simplicity and ease of use.

## Wrong ways of sharing secrets

There are a few wrong ways of sharing secrets, Make sure you don't do any of
these 🙂

1. *Secrets in source code*: This is a big no-no, you don't want to store
   secrets in your code because anyone with access to your code will be able to
   read them.
2. *Secrets built into the docker image*: This is another bad idea, because
   anyone with access to your images will have your secrets, moreover, if you
   want to change a secret, you'll have to build a new image and deploy it.
3. *Secrets in the terraform ECS task definitions Environment block*: This is
   not very bad, but anyone with access to your terraform repo will be able to
   read your secrets.

## Store Secrets in the parameter store, one parameter per secret
The parameter store is a *free* and easy tool to save your secrets. There are
more fancy options like the secret manager, but they cost money.

One way of storing secrets is to create one parameter per environment variable,
e.g. if you have an app called money, you could create parameters called
`money_database_url`, `money_secret_access_token` etc,. Make sure you create
them as 'SecretString' types. And then in your task definition. Use the
following code:

```json
{
    "name": "money-web",
    "image": "...",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8000,
        "hostPort": 0
      }
    ],
    "secrets": [
      {
        "name": "DATABASE_URL",
        "valueFrom": "money_database_url"
      },
      {
        "name": "SECRET_ACCESS_TOKEN",
        "valueFrom": "money_secret_access_token"
      }
    ],
    "environment": [
      {
        "name": "MIX_ENV",
        "value": "prod"
      }
    ]
  }
```

This will make your secrets available to your ECS container via environment
variables called `DATABASE_URL` and `SECRET_ACCESS_TOKEN`. However, if you have
lots of secrets, this becomes unweildy.

## Store Secrets in the parameter store, one parameter per app
I create a file called `secrets.json` with all the secrets (You can tweak this
step, and use some other format)

```json
{
  "db":"ecto://user:password@endpoint/dbname",
  "secret_key_base":"....",
  ....
}
```

Once I have all the secrets listed in this file. I pass it through the following
command:

```
jq -c . < "secrets.json" | base64 --wrap 0
```

This strips the spaces in the json and base64 encodes it. I plug this value into
a single parameter called `money_config` and then use the same strategy as
before to pass it as an env var:

```json
    "secrets": [
      {
        "name": "APP_CONFIG",
        "valueFrom": "money_config"
      },
```

Now, in the app, I just decode base64 and then decode the json to get all the
values. Here is how I do it in my Elixir apps:

```
# config/releases.exs
import Config

app_config = System.fetch_env!("APP_CONFIG") |> Base.decode64!() |> Jason.decode!()

config :money, Money.Repo,
  ssl: true,
  url: Map.fetch!(app_config, "db"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE", "10"))

config :money, MoneyWeb.Endpoint,
  http: [
    port: 8000,
    transport_options: [socket_opts: [:inet6]]
  ],
  server: true,
  secret_key_base: Map.fetch!(app_config, "secret_key_base")

```

This approach allows you to use around 70 secrets in one parameter because paramater values are limited to a size of 4K characters.

## Making space for more environment variables

If you have more than 70 environment variables you can add `gzip` to the pipe to get in more environment variables in a single parameter.

```
jq -c . < "secrets.json" | gzip | base64 --wrap 0
```

You'll have to do things in the opposite order on your app to read this data. With gzip, You can get almost 140 env variables.
