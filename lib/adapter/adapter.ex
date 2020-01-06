defmodule Cluster.Strategy.Adapter do
  @callback get_nodes(release_name :: atom, config :: struct) ::
              {:ok, nodes :: List.t()} | {:error, reason :: term}
end

defmodule Cluster.Strategy.Adapter.Test do
  @behaviour Cluster.Strategy.Adapter
  def get_nodes(release_name, config \\ %{})

  def get_nodes(release_name, _config) do
    {:ok, [:"#{release_name}@127.0.0.1"]}
  end
end
