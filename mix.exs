defmodule InfluxQL.Mixfile do
  use Mix.Project

  @url_github "https://github.com/mneudert/influxql"

  def project do
    [
      app: :influxql,
      name: "InfluxQL",
      version: "0.3.0-dev",
      elixir: "~> 1.7",
      deps: deps(),
      description: "InfluxQL utility/tooling package",
      dialyzer: dialyzer(),
      docs: docs(),
      package: package(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test
      ],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14.0", only: :test, runtime: false}
    ]
  end

  defp dialyzer do
    [
      flags: [
        :error_handling,
        :race_conditions,
        :underspecs,
        :unmatched_returns
      ],
      plt_core_path: "plts",
      plt_local_path: "plts"
    ]
  end

  defp docs do
    [
      main: "InfluxQL",
      extras: [
        "CHANGELOG.md",
        LICENSE: [title: "License"],
        "README.md": [title: "Overview"]
      ],
      source_ref: "master",
      source_url: @url_github
    ]
  end

  defp package do
    %{
      files: ["CHANGELOG.md", "LICENSE", "mix.exs", "README.md", "lib"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @url_github}
    }
  end
end
