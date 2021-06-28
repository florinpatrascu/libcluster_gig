defmodule LibclusterGig.MixProject do
  use Mix.Project

  @version "0.3.0"
  def project do
    [
      app: :libcluster_gig,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      source_url: source_url(),
      project_url: source_url(),
      package: package(),
      docs: docs(),
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      dialyzer: [
        flags: ~w(-Wunmatched_returns -Werror_handling -Wrace_conditions -Wno_opaque -Wunderspecs)
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:libcluster, "~> 3.3.0"},
      # Using the required Google API support from: https://github.com/googleapis/elixir-google-api
      # - Compute: https://hexdocs.pm/google_api_compute/api-reference.html
      {:google_api_compute, ">= 0.0.0"},
      # - authentication
      {:goth, "~> 1.2"},
      # and for internal use, i.e. development
      {:mix_test_watch, "~> 1.0.3", only: [:dev, :test]},
      {:dialyxir, "~> 1.1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.5.0-rc.4", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    """
    Clustering strategy for connecting nodes running as Google Instance Groups members.
    """
  end

  defp source_url do
    "https://github.com/florinpatrascu/libcluster_gig"
  end

  defp package do
    [
      files: ["lib", "mix.exs", "LICENSE", "README.md", "CHANGELOG.md"],
      maintainers: ["Florin T.PATRASCU"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => source_url()}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: source_url(),
      source_ref: "v#{@version}",
      formatter_opts: [gfm: true],
      extras: [
        "README.md"
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
