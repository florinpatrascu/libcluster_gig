defmodule Cluster.Strategy.GigTest do
  use ExUnit.Case

  alias Cluster.Strategy.GoogleInstanceGroups
  alias Cluster.Strategy.Test.Nodes

  require Nodes

  import ExUnit.CaptureLog

  test "calls strategy" do
    capture_log(fn ->
      start_supervised!(
        {GoogleInstanceGroups,
         [
           %Cluster.Strategy.State{
             topology: :gig,
             config: [
               project: "4thehorde",
               zone: "kekw",
               instance_group: "omegalul",
               adapter: Cluster.Strategy.Adapter.Test
             ],
             connect: {Nodes, :connect, [self()]},
             disconnect: {Nodes, :disconnect, [self()]},
             list_nodes: {Nodes, :list_nodes, [[]]}
           }
         ]}
      )

      assert_receive {:connect, :"gig@127.0.0.1"}, 5_000
    end)
  end
end
