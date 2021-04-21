title: A baton server to test your Erlang/Elixir cluster
date: 2021-04-20 21:33:26
tags:
- Elixir
- Erlang
- Distributed
- Cluster
- Baton
- Server
- libcluster
---

I have been dipping my feet into Distributed Systems and [set up a cluster of Raspberry Pi Nodes recently](https://minhajuddin.com/2021/04/15/how-to-show-raspberry-pi-temperatures-in-your-datadog-dashboard/).
The first thing I wanted to try was forming an Erlang cluster, And [libcluster](https://github.com/bitwalker/libcluster)
makes this very easy through the Gossip strategy. Here is the code to form the
erlang cluster automatically (as long as it is on the same network).

```elixir
# application.ex

# ...
children = [
  {Cluster.Supervisor,
   [Application.get_env(:herd, :topologies), [name: Herd.ClusterSupervisor]]},
# ...

# config/config.exs
config :herd,
  topologies: [
    # topologies can contain multiple strategies, However, we just have one
    # The name `:gossip` is not important
    gossip: [
      # The selected clustering strategy. Required.
      strategy: Cluster.Strategy.Gossip,
      # Configuration for the provided strategy. Optional.
      config: [
        port: 45892,
        if_addr: "0.0.0.0",
        multicast_if: "192.168.1.1",
        multicast_addr: "230.1.1.251",
        multicast_ttl: 1,
        secret: "somepassword"
      ],
      # The function to use for connecting nodes. The node
      # name will be appended to the argument list. Optional
      connect: {:net_kernel, :connect_node, []},
      # The function to use for disconnecting nodes. The node
      # name will be appended to the argument list. Optional
      disconnect: {:erlang, :disconnect_node, []},
      # The function to use for listing nodes.
      # This function must return a list of node names. Optional
      list_nodes: {:erlang, :nodes, [:connected]}
    ]
  ]
```

Once, the clustering was set up I wanted to try sending messages through the
cluster and see how it performed, the simplest test I could think of was a baton
relay. Essentially, I spin up one GenServer per node and it relays a counter to
the next node, which sends it to the next node and so on like the picture below
(psa, psb, psc, and psd are the names of the nodes):

{% asset_img BatonServer.svg Baton Server Flow %}

The code for this ended up being very straightforward. We create a GenServer and
make one of the nodes a `main_node` so that it can kick off the baton relay.
And, whenever we get a counter with a `:pass` message we increment the counter
and forward it to the next node. Here is the full code:

```elixir
defmodule Herd.Baton.ErlangProcess do
  use GenServer
  require Logger

  @doc false
  def start_link(opts) do
    # Use {:global, ...} name's so that they can be addressed from other nodes
    name = global_proc_name(Node.self())
    Logger.info("starting a baton process", name: inspect(name))
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  # API to capture the shape of the function that sends a message to the next node
  def pass(node, rest_nodes, counter) do
    GenServer.cast(global_proc_name(node), {:pass, rest_nodes, counter})
  end

  @impl true
  def init(state) do
    send(self(), :init)
    {:ok, state}
  end

  @impl true
  def handle_info(:init, state) do
    if main_node?() do
      if cluster_formed?() do
        # Kick off the baton relay if we are the main node
        pass(Node.self(), [], 1)
      else
        # check again after 1 second
        Process.send_after(self(), :init, 1000)
      end
    end

    {:noreply, state}
  end

  # Our config has the name of the main node like so:
  # config :herd,
  #   main_node: :herd@psa
  defp main_node?() do
    Application.get_env(:herd, :main_node) == Node.self()
  end

  defp cluster_formed?() do
    Node.list() != []
  end

  @impl true
  def handle_cast({:pass, nodes, counter}, state) do
    pass_the_baton(nodes, counter)
    {:noreply, state}
  end

  defp pass_the_baton([], counter), do: pass_the_baton(cluster_nodes(), counter)
  defp pass_the_baton([next_node | rest_nodes], counter) do
    # Datadog guage to show us the change in counter
    Datadog.gauge("baton", counter, tags: host_tags())
    pass(next_node, rest_nodes, counter + 1)
  end

  defp host_tags do
    tags(host: to_string(Node.self()))
  end

  def tags(kwlist) do
    kwlist
    |> Enum.map(fn {k, v} -> "#{k}:#{v}" end)
  end

  defp global_proc_name(node) do
    {:global, {node, __MODULE__}}
  end

  defp cluster_nodes do
    [Node.self() | Node.list()]
    |> Enum.shuffle()
  end
end
```

Finally, here is the Datadog graph for the counter, The big thing to note is
that the 4 GenServers on a local lan were able to pass around 100M messages in 8
hours which amounts to about 3.5K messages per second which is impressive:

{% asset_img datadog-counter.png Datadog Counter Graph %}
