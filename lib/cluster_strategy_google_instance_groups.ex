defmodule Cluster.Strategy.GoogleInstanceGroups do
  @moduledoc """
  A libcluster clustering strategy supporting Google's managed instance groups
  """
  use GenServer
  use Cluster.Strategy

  alias Cluster.Strategy.State

  require Logger

  @default_polling_interval 5_000
  def start_link(args), do: GenServer.start_link(__MODULE__, args)

  @impl true
  def init([%State{} = state]) do
    {:ok, load(state)}
  end

  @impl true
  def handle_info(:timeout, state) do
    handle_info(:load, state)
  end

  def handle_info(:load, %State{} = state) do
    {:noreply, load(state)}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  defp load(%State{config: config, topology: topology} = state) do
    adapter = config[:adapter]

    case adapter.get_nodes(topology, config) do
      {:ok, nodes} ->
        Cluster.Strategy.connect_nodes(state.topology, state.connect, state.list_nodes, nodes)

      e ->
        Logger.error(inspect(e))
    end

    Process.send_after(self(), :load, polling_interval(state))
    state
  end

  defp polling_interval(%State{config: config}) do
    Keyword.get(config, :polling_interval, @default_polling_interval)
  end
end
