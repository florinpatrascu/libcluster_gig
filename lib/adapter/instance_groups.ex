defmodule Cluster.Strategy.Adapter.InstanceGroups do
  @moduledoc """
  Find all the instances available in a  managed instance group
  A managed instance group is a group of homogeneous instances based on an instance template.

  https://cloud.google.com/compute/docs/instance-groups/creating-groups-of-managed-instances

  """
  @behaviour Cluster.Strategy.Adapter
  alias GoogleApi.Compute.V1.Connection
  alias GoogleApi.Compute.V1.Model.InstanceGroupsListInstances
  alias GoogleApi.Compute.V1.Model.InstanceWithNamedPorts
  alias GoogleApi.Compute.V1.Api

  require Logger

  @doc """
  return a list of compute instances, available in the specified topology
  """
  def get_nodes(release_name, config),
    do:
      get_instance_group_nodes(
        release_name,
        config[:project],
        config[:zone],
        config[:instance_group]
      )

  defp get_instance_group_nodes(
         release_name,
         project,
         zone,
         instance_group
       ) do
    conn = get_access_token() |> Connection.new()

    with {:ok, %InstanceGroupsListInstances{items: items}} <-
           conn
           |> Api.InstanceGroups.compute_instance_groups_list_instances(
             project,
             zone,
             instance_group
           ) do
      nodes =
        items
        |> Enum.filter(fn
          %InstanceWithNamedPorts{status: "RUNNING"} -> true
          _ -> false
        end)
        |> Enum.map(fn %InstanceWithNamedPorts{instance: instance} ->
          %{"instance_name" => instance_name} =
            Regex.named_captures(~r/.*\/(?<instance_name>.*)$/, instance)

          :"#{release_name}@#{instance_name}"
        end)

      {:ok, nodes}
    else
      e ->
        Logger.error(inspect(e))
        {:error, e}
    end
  end

  defp get_access_token() do
    {:ok, response} =
      "https://www.googleapis.com/auth/cloud-platform"
      |> Goth.Token.for_scope()

    response.token
  end
end
