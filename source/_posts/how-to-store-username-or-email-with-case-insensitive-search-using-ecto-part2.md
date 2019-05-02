title: How to store username or email with case insensitive search using Ecto - Part 2
date: 2019-04-14 10:59:55
tags:
- Ecto
- Elixir
- Username
- Email
- Index
- Postgresql
---

In a previous blog post I was trying to [store username/email in a case
insensitive way in
postgres](/2019/04/14/how-to-store-username-or-email-with-case-insensitive-search-using-ecto/).
A few folks commented that the `citext` postgres extension actually did this in
a very easy and straightforward way. So, I went back to my code and ripped out
the unnecessary complexity and here is what I ended up with:


```elixir
defmodule SF.Repo.Migrations.EnableCitextExtension do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION citext", "DROP EXTENSION citext"
  end
end

 SF.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :citext, null: false
      add :magic_token, :uuid
      add :magic_token_created_at, :naive_datetime
      add :confirmation_token, :uuid
      add :confirmed_at, :naive_datetime

      timestamps()
    end

    create index(:users, [:email], unique: true)
    create index(:users, [:magic_token], unique: true)
    create index(:users, [:confirmation_token], unique: true)
  end
end

defmodule SF.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :magic_token, Ecto.Base64UUID
    field :confirmation_token, Ecto.Base64UUID
    field :confirmed_at, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :confirmation_token])
    |> validate_required([:email])
    |> unique_constraint(:email)
  end
end

defmodule SF.UserService do

  def find_by_email(email) do
    Repo.one(from u in User, where: u.email == ^email)
  end

end
```

So, the way [citext](https://www.postgresql.org/docs/11/citext.html) works is
similar to our previous approach. If you want to get into all the gory details
about how citext is implemented you can check out the code on GitHub at:
https://github.com/postgres/postgres/blob/6dd86c269d5b9a176f6c9f67ea61cc17fef9d860/contrib/citext/citext.c
