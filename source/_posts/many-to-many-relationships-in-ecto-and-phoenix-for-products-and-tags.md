title: many_to_many relationships in Ecto and Phoenix for Products and Tags
date: 2020-05-03 12:54:34
tags:
- many_to_many
- Ecto
- Phoenix
- Elixir
- Tags
- relationships
---

The other day I was helping a friend set up a phoenix app which required the use
of tags on products, we all have used tags in our day to day to add information
about notes, images, and other stuff. Tags, are just names which are used to
associate with an entity like a product, blog post, image etc,. This blog post
has a few tags too (Ecto, Elixir, Phoenix etc,.). Tags help us organize
information in a loose fashion by annotating entities with useful fragments of
information. And modeling these in a database is pretty straightforward, it is
usually implemented in the following design.

~photo of the ERD

As you can see, we have a many to many relation between the products and tags
via a products_tags table which has just 2 columns the product_id and the tag_id
and it has a composite primary key (while also having an index on the tag_id to
make lookups faster). The use of a join table is required, however, you want
this to be invisible in your app as you don't want to deal with a ProductTag
model, it doesn't serve any purpose other than helping you bridge the object
model with the relational model. Anyway, here is how we ended up building the
many to many relationship in Phoenix and Ecto.

# Scaffolding the models

We use a nondescript Core context for our products by running the following
scaffold code:

```
mix phx.gen.html Core Product products name:string description:text
```

This generates the following migration (I've omitted the boilerplate):

```
create table(:products) do
  add :name, :string
  add :description, :text

  timestamps()
end
```

Don't forget to add the following to your `router.ex`

```elixir
resources "/products", ProductController
```

Then, we add the `Tag` in the same context for convenience by running the
following scaffold generator:

```
mix phx.gen.html Core Tag tags name:string:unique
```

This generates the following migration, note the unique index on name, as we
don't want tags with duplicate names, you might have separate tags per user in
which case you would have a unique index on `[:user_id, :name]`.

```elixir
create table(:tags) do
  add :name, :string

  timestamps()
end

create unique_index(:tags, [:name])
```

Finally we generate the migration for the join table `products_tags`, by
convention it uses the pluralized names of both entities joined by an underscore
so `products` and `tags` joined by an `_` gives us the name `products_tags`.

```
mix phx.gen.schema Core.ProductTag products_tags product_id:references:products tag_id:references:tags
```

This scaffolded migration requires a few tweaks to make it look like the
following:

```elixir
create table(:products_tags, primary_key: false) do
  add :product_id, references(:products, on_delete: :nothing), primary_key: true
  add :tag_id, references(:tags, on_delete: :nothing), primary_key: true
end

create index(:products_tags, [:product_id])
create index(:products_tags, [:tag_id])
```

Note the following:
  1. We added a `primary_key: false` declaration to the `table()` function call
  2. We got rid of the `timestamps()` declaration
  3. We added a `, primary_key: true` to the `:product_id` and `:tag_id` lines
     to make `[:product_id, :tag_id]` a composite primary key

Now our database is set up nicely for our many to many relationship. Here is how
your tables look in the database:

```
product_tags_demo_dev=# \d products
                                       Table "public.products"
┌─────────────┬────────────────────────────────┬───────────┬──────────┬─────────────────────────────┐
│   Column    │              Type              │ Collation │ Nullable │           Default           │
├─────────────┼────────────────────────────────┼───────────┼──────────┼─────────────────────────────┤
│ id          │ bigint                         │           │ not null │ nextval('products_id_seq'::…│
│             │                                │           │          │…regclass)                   │
│ name        │ character varying(255)         │           │          │                             │
│ description │ text                           │           │          │                             │
│ inserted_at │ timestamp(0) without time zone │           │ not null │                             │
│ updated_at  │ timestamp(0) without time zone │           │ not null │                             │
└─────────────┴────────────────────────────────┴───────────┴──────────┴─────────────────────────────┘
Indexes:
    "products_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "products_tags" CONSTRAINT "products_tags_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id)

product_tags_demo_dev=# \d tags
                                         Table "public.tags"
┌─────────────┬────────────────────────────────┬───────────┬──────────┬─────────────────────────────┐
│   Column    │              Type              │ Collation │ Nullable │           Default           │
├─────────────┼────────────────────────────────┼───────────┼──────────┼─────────────────────────────┤
│ id          │ bigint                         │           │ not null │ nextval('tags_id_seq'::regc…│
│             │                                │           │          │…lass)                       │
│ name        │ character varying(255)         │           │          │                             │
│ inserted_at │ timestamp(0) without time zone │           │ not null │                             │
│ updated_at  │ timestamp(0) without time zone │           │ not null │                             │
└─────────────┴────────────────────────────────┴───────────┴──────────┴─────────────────────────────┘
Indexes:
    "tags_pkey" PRIMARY KEY, btree (id)
    "tags_name_index" UNIQUE, btree (name)
Referenced by:
    TABLE "products_tags" CONSTRAINT "products_tags_tag_id_fkey" FOREIGN KEY (tag_id) REFERENCES tags(id)

product_tags_demo_dev=# \d products_tags
              Table "public.products_tags"
┌────────────┬────────┬───────────┬──────────┬─────────┐
│   Column   │  Type  │ Collation │ Nullable │ Default │
├────────────┼────────┼───────────┼──────────┼─────────┤
│ product_id │ bigint │           │ not null │         │
│ tag_id     │ bigint │           │ not null │         │
└────────────┴────────┴───────────┴──────────┴─────────┘
Indexes:
    "products_tags_pkey" PRIMARY KEY, btree (product_id, tag_id)
    "products_tags_product_id_index" btree (product_id)
    "products_tags_tag_id_index" btree (tag_id)
Foreign-key constraints:
    "products_tags_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id)
    "products_tags_tag_id_fkey" FOREIGN KEY (tag_id) REFERENCES tags(id)
```

Now comes the fun part, modifying our controllers and contexts to get our tags
working!

The first thing we need to do is add a many_to_many relationship on the `Product` schema like so:

```elixir
  schema "products" do
    field :description, :string
    field :name, :string
    many_to_many :tags, ProductTagsDemo.Core.Tag, join_through: "products_tags"

    timestamps()
  end
```

Now, we need to modify our `Product` form to show an input for tags, the easy
way to do this is to ask the users to provide a comma separated list of tags in
an input textbox. A nicer way is to use a javascript library like *select2*(https://select2.org/getting-started/basic-usage#multi-select-boxes-pillbox)
For us a text boxy with comma separated tags will suffice.

The easiest way to do this is to add a text field like so:
```html
  <%= label f, :tags %>
  <%= text_input f, :tags %>
  <%= error_tag f, :tags %>
```

However, as soon as you wire this up you'll get an error on the `/products/new`
page like below:
```
protocol Phoenix.HTML.Safe not implemented for #Ecto.Association.NotLoaded<association :tags is not loaded> of type Ecto.Association.NotLoaded (a struct).
```
This is telling us that the `to_string` function can't convert an `Ecto.Association.NotLoaded` struct
into a string, When you have a relation like a `belongs_to` or `has_one` or
`many_to_many` that isn't loaded on an entity it has this default value. This is
coming from our controller, we can remedy this by changing our action to the
following:

```elixir
def new(conn, _params) do
  changeset = Core.change_product(%Product{tags: []})
  render(conn, "new.html", changeset: changeset)
end
```
Notice the `tags: []`, we are creating a new product with an empty tags
collection so that it renders properly in the form.

Now that we have fixed our form, we can try submitting some tags through this
form, However, when you enter any tags and hit `Save` it doesn't do anything
which is not surprising because we haven't set up handling of these tags on the
backend.

Now, we know that the tags field has comma separated tags, so we need to do the
following to be able to save a product.

Parse the tags by splitting them on a comma, stripping them of whitespace, and
downcasing them to get them to be homogeneous. If you want your tag names to be
persisted using the input casing and still treat the upcased version the same as
the downcased or capitalized version, you can use `:citext` (short for case
insensitive text) you can read more about how to set up `:citext` columns in my
blog post about [storing username/email in a case insensitive
fashion](https://minhajuddin.com/2019/04/14/how-to-store-username-or-email-with-case-insensitive-search-using-ecto-part2/)

Once we have all the tag `names` we can insert the any new tags and then fetch
the existing tags, combine them and use `put_assoc` to put them on the product.
This usually creates a race condition in your code which can happen when 2
requests try to create the tags with the same name. An easy way to work around
this is to treat all the tags as new and do an upsert using `Repo.insert_all`
with a `on_conflict: :nothing` option which adds the fragment `ON CONFLICT DO
NOTHING` to your sql which makes your query run successfully even if there are
tags with the same name, it just doesn't insert new tags. Also note that this
function inserts all the tags in a single query doing a bulk insert of all the
input tags. Once you `upsert` all the tags, you can then find them and use a
`put_assoc` to create an association.

This is what ended up as the final `Core.create_product` function

```elixir
  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    # use put_assoc to associate the input tags to the product
    |> Ecto.Changeset.put_assoc(:tags, product_tags(attrs))
    |> Repo.insert()
  end

  defp parse_tags(nil), do: []

  defp parse_tags(tags) do
    # Repo.insert_all requires the inserted_at and updated_at to be filled out
    # and they should have time truncated to the second that is why we need this
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    for tag <- String.split(tags, ","),
        tag = tag |> String.trim() |> String.downcase(),
        tag != "",
        do: %{name: tag, inserted_at: now, updated_at: now}
  end

  defp product_tags(attrs) do
    tags = parse_tags(attrs["tags"]) # => [%{name: "phone", inserted_at: ..},  ...]

    # do an upsert ensuring that all the input tags are present
    Repo.insert_all(Tag, tags, on_conflict: :nothing)

    tag_names = for t <- tags, do: t.name
    # find all the input tags
    Repo.all(from t in Tag, where: t.name in ^tag_names)
  end
```

It does the following:

 1. Normalize our tags
 2. Ensure that all the tags are in our database using `Repo.insert_all` with
    `on_conflict: :nothing` in a single SQL query.
 3. Load all the tag structs using the names.
 4. Use `put_assoc` to associate the tags with the newly created product.
 5. From here `Ecto` takes over and makes sure that our product has the right
    association records in the `products_tags` table

Notice, how through all of our code we haven't used the `products_tags` table
except for defining the `many_to_many` relationship in the `Product` schema.

This is all you need to insert a product with multiple tags, However, we still
want to show the tags of a product on the product details page. We can do this
by tweaking our action and the Core module like so:

```elixir
defmodule Core do
  def get_product_with_tags!(id), do: Product |> preload(:tags) |> Repo.get!(id)
end
defmodule ProductTagsDemoWeb.ProductController do
  def show(conn, %{"id" => id}) do
    product = Core.get_product_with_tags!(id)
    render(conn, "show.html", product: product)
  end
end
```
Here we are preloading the tags with the product and we can use it in the view
like below to show all the tags for a product:

```html
Tags: <%= (for tag <- @product.tags, do: tag.name) |> Enum.join(", ") %>
```

This takes care of creating and showing a product with tags, However, if we try
to edit a product we are greeted with the following error:

```
protocol Phoenix.HTML.Safe not implemented for #Ecto.Association.NotLoaded<association :tags is not loaded> of type Ecto.Association.NotLoaded (a struct).
```

Hmmm, we have seen this before when we rendered a new Product without tags,
However in this case our product does have tags but they haven't been
loaded/preloaded. We can remedy that easily by tweaking our action code to the
following:

```elixir
def edit(conn, %{"id" => id}) do
  product = Core.get_product_with_tags!(id)
  changeset = Core.change_product(product)
  render(conn, "edit.html", product: product, changeset: changeset)
end
```

This gives us a new error:

```
lists in Phoenix.HTML and templates may only contain integers representing bytes, binaries or other lists, got invalid entry: %ProductTagsDemo.Core.Tag{__meta__: #Ecto.Schema.Metadata<:loaded, "tags">, id: 1, inserted_at: ~N[2020-05-04 05:20:45], name: "phone", updated_at: ~N[2020-05-04 05:20:45]}
```

This is because we are using a `text_input` for a collection of tags and when
phoenix tries to convert the list of tags into a string it fails. This is a good
place to add a custom input:

```elixir
defmodule ProductTagsDemoWeb.ProductView do
  use ProductTagsDemoWeb, :view

  def tag_input(form, field, opts \\ []) do
    # get the input tags collection
    tags = Phoenix.HTML.Form.input_value(form, field)
    # render text using the text_input after converting tags to text
    Phoenix.HTML.Form.text_input(form, field, value: tags_to_text(tags), opts)
  end

  defp tags_to_text(tags) do
    tags
    |> Enum.map(fn t -> t.name end)
    |> Enum.join(", ")
  end
end
```

With this helper we can tweak our form to:
```html
<%= label f, :tags %>
<%= tag_input f, :tags %>
<%= error_tag f, :tags %>
<small class="help-text">tags separated by commas</small>
```
Note that the `text_input` has been changed to `tag_input`.

Now, when we go to edit a product, it should render the form with the tags
separated by commas. However, updating the product by changing tags still
doesn't work because we haven't updated our backend code to handle this. To
complete this we need to tweak the controller and the `Core` context like so:

```elixir
defmodule ProductTagsDemoWeb.ProductController do
  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Core.get_product_with_tags!(id)
    # ... rest is the same
  end
end
defmodule ProductTagsDemo.Core do
  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:tags, product_tags(attrs))
    |> Repo.update()
  end
end
```

Note that in the controller we are using `get_product_with_tags!` and in the
context we inserted a line to `put_assoc` similar to the `create_product`
function which does the same things as `create_product`.

Astute readers will observe that our create and update product implementation
doesn't rollback newly created tags in the case a product insertion or updation
fails. Let us add this and wrap our post!

Ecto provides `Ecto.Multi` to allow easy transaction handling. This just needs
changes to our context and our view like so:

```elixir
defmodule ProductTagsDemo.Core do
  alias Ecto.Multi

  def create_product(attrs \\ %{}) do
    multi_result =
      Multi.new()
      |> ensure_tags(attrs)
      |> Multi.insert(:product, fn %{tags: tags} ->
        %Product{}
        |> Product.changeset(attrs)
        |> Ecto.Changeset.put_assoc(:tags, tags)
      end)
      |> Repo.transaction()

    case multi_result do
      {:ok, %{product: product}} -> {:ok, product}
      {:error, :product, changeset, _} -> {:error, changeset}
    end
  end

  def update_product(%Product{} = product, attrs) do
    multi_result =
      Multi.new()
      |> ensure_tags(attrs)
      |> Multi.update(:product, fn %{tags: tags} ->
        product
        |> Product.changeset(attrs)
        |> Ecto.Changeset.put_assoc(:tags, tags)
      end)
      |> Repo.transaction()

    case multi_result do
      {:ok, %{product: product}} -> {:ok, product}
      {:error, :product, changeset, _} -> {:error, changeset}
    end
  end

  # parse_tags is unchanged

  defp ensure_tags(multi, attrs) do
    tags = parse_tags(attrs["tags"])

    multi
    |> Multi.insert_all(:insert_tags, Tag, tags, on_conflict: :nothing)
    |> Multi.run(:tags, fn repo, _changes ->
      tag_names = for t <- tags, do: t.name
      {:ok, repo.all(from t in Tag, where: t.name in ^tag_names)}
    end)
  end
end
```

Whew, that was long, but hopefully this gives you a comprehensive understanding
of how to handle many_to_many relationships in Ecto and Phoenix.

P.S There is a lot of duplication in our final `create_product` and
`update_product` try removing the duplication in an elegant way! I'll share my
take on it in the next post!
