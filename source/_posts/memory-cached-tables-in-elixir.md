title: Memory Cached Tables in Elixir
date: 2021-10-31 22:26:30
tags:
- Memory Cached Tables
- Speed
- Performance
- Elixir
- Web apps
- Fast
- Lookup tables
---

## Implementation in Elixir

Right off the bat, we know that we need a process which holds the data for the
table and allows us to query for it and can also keep polling for changes. We
can set this up using a GenServer.

```
defmodule MCT.CachedSettings do
  use GenServer

  @doc false
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state, {:continue, :init}}
  end

end
```

This is a boiler plate GenServer which is initialized with a name and a map as
its state. Now, let us write a few helper functions which will help us load the
data.

We need one to get the content hash.

```
  defp get_content_hash(model) do
    # in SQL below we sort by the whole row, so that order doesn't change every time we compute the hash
    Repo.one(from s in model, select: fragment("md5(array_agg(? ORDER BY ?)::text)", s, s))
  end
  
  get_content_hash(Setting) # => "337f91e1e09b09e96b3413d27102c761"
```

We also need a function to load all the settings and convert them into a map.

```
  defp build_state() do
    state = %{
      content_hash: get_content_hash(Setting),
      settings_map:
        Setting
        |> Repo.all()
        |> Enum.map(fn x -> {x.key, x} end)
        |> Enum.into(%{})
    }
  end
```

We also want a function which can schedule a message every few minutes.

```
  @polling_interval 5 * 60 * 1000 # poll every 5 minutes
  defp schedule_poll() do
    Process.send_after(self(), :poll_db, @polling_interval)
  end
```

With 
