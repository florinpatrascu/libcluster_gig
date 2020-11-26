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

    instances =
      Api.InstanceGroups.compute_instance_groups_list_instances(
        conn,
        project,
        zone,
        String.trim(instance_group)
      )

    case instances do
      {:ok, %InstanceGroupsListInstances{items: items}} when is_list(items) ->
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

      {:ok, %InstanceGroupsListInstances{}} ->
        {:ok, []}

      e ->
        Logger.error(inspect(e))
        {:error, e}
    end
  end

  defp get_access_token() do
    {:ok, response} = Goth.Token.for_scope("https://www.googleapis.com/auth/cloud-platform")

    response.token
  end
end
