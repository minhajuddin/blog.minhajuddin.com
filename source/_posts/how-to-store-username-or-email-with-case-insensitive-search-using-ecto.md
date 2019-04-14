title: How to store username or email with case insensitive search using Ecto
date: 2019-04-14 10:59:55
tags:
- Ecto
- Elixir
- Username
- Email
- Index
- Postgresql
---

I am building a small personal project which stores users in a `users` table and
every user has a unique email. So, my first model looked something like below:

```elixir
defmodule SF.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string, null: false
      add :magic_token, :uuid
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
```

Like all good developers I had a unique index on the email field to make the
searches faster. So, when I do a `Repo.get_by(User, email: "danny@m.com")`,
postgres doesn't have to scan the whole table to find my user. However, users
sometimes enter email in mixed case, so some people might enter the above email
as `DANNY@m.com`, and since postgres makes a distinction between upper cased and
lower cased strings, we would end up returning a 404 Not found error to the
user. To work around this I would usually lower case the email whenever it
entered the system, in Rails you would do something like below:

```ruby
class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users, id: :uuid do |t|
      # ...
    end
    add_index :users, %i[email], unique: true
  end
end

class User < ActiveRecord::Base
  # downcase email before saving
  before_save :normalize_email

  def normalize_email
    self.email = email&.downcase
  end

  # always downcase before you find a record
  def find_by_email
    find_by(email: email.downcase)
  end
end
```

One downside of this approach is the need to ensure that all the emails in the
database are stored as lower case. If you mess up on your data entry code, you
might end up with a table containing the same email with different cases.

A better way to do this in Ecto would be to create an index on a lower cased
email like so:

```elixir
    create index(:users, ["(lower(email))"], unique: true)
```

This way you would never end up with a table with duplicate emails, and when you
want to find a user with an email you can do something like below:

```elixir
defmodule SF.UserService do
  def find_by_email(email) do
    email = String.downcase(email)

    user =
      Repo.one(
        from u in User,
          where: fragment("lower(?)", u.email) == ^email
      )

    if user != nil, do: {:ok, user}, else: {:error, :not_found}
  end
end
```

This would also make sure that your index is actually used. You can take the SQL
logged in your IEx and run a quick `EXPLAIN` to make sure that your index is
properly being used:

```sql
# EXPLAIN ANALYZE SELECT u0."id", u0."email", u0."magic_token", u0."confirmation_token", u0."confirmed_at", u0."inserted_at", u0."updated_at" FROM "users" AS u0 WHERE (lower(u0
."email") = 'foobar@x.com');
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                             QUERY PLAN                                                              │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Index Scan using users__lower_email_index on users u0  (cost=0.14..8.16 rows=1 width=588) (actual time=0.013..0.014 rows=0 loops=1) │
│   Index Cond: (lower((email)::text) = 'foobar@x.com'::text)                                                                         │
│ Planning time: 0.209 ms                                                                                                             │
│ Execution time: 0.064 ms                                                                                                            │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
(4 rows)

Time: 1.086 ms
```

A common rookie mistake is creating an index on the email column and then comparing
in sql using the `lower` function like so:


```sql
simpleform_dev=# EXPLAIN ANALYZE select * from users where lower(email) = 'danny';
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                     QUERY PLAN                                                      │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Seq Scan on users  (cost=10000000000.00..10000000001.01 rows=1 width=580) (actual time=0.034..0.034 rows=0 loops=1) │
│   Filter: (lower((email)::text) = 'danny'::text)                                                                     │
│   Rows Removed by Filter: 1                                                                                         │
│ Planning time: 0.158 ms                                                                                             │
│ Execution time: 0.076 ms                                                                                            │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
(5 rows)

Time: 1.060 ms
simpleform_dev=#
```
