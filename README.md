# A simple libcluster strategy for Google Instance Groups

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `libcluster_gig` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:libcluster_gig, "~> 0.3.0"}
  ]
end
```

## Setup

This library is using the Google APIs to call various services, and you'll need to provide an access token. Excerpt from [Google's API docs](https://github.com/googleapis/elixir-google-api), in relation to obtaining an Access Token

### Service Accounts

Authentication is typically done through Application Default Credentials which means you do not have to change the code to authenticate as long as your environment has credentials. Start by creating a Service Account key file. This file can be used to authenticate to Google Cloud Platform services from any environment. To use the file, set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to the path to the key file, for example:

```sh
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service_account.json
```

If you are deploying to App Engine, Compute Engine, or Container Engine, your credentials will be available by default.

### Usage

In your application supervision tree, add this custom `libcluster` strategy.

```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    topologies = [
      myapp_release_name: [
        strategy: Cluster.Strategy.GoogleInstanceGroups,
        config: [
          project: "4thehorde",
          zone: "kekw",
          instance_group: "omegalul",
          adapter: Cluster.Strategy.Adapter.InstanceGroups
        ]
      ]
    ]

    children = [
      {Cluster.Supervisor, [topologies, [name: GoogleInstanceGroups.ClusterSupervisor]]}
    ]

    Supervisor.start_link(children, [name: MyApp.Supervisor, strategy: :one_for_one])
  end
end
```

But you can also use a `libcluster` specific configuration. For example:

```elixir
config :libcluster,
  topologies: [
    myapp_release_name: [
      strategy: Cluster.Strategy.GoogleInstanceGroups,
      config: [
        project: "4thehorde",
        zone: "kekw",
        instance_group: "omegalul",
        adapter: Cluster.Strategy.Adapter.InstanceGroups
      ]
    ]
  ]

```

and then add the following to one of your app's supervision trees, as a child

```elixir
  {Cluster.Supervisor,
    [Application.get_env(:libcluster, :topologies), [name: MyApp.ClusterSupervisor]]}

```

That's it™

:)

### License

Copyright 2020-2021 Florin T.Patrascu

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
