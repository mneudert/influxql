defmodule InfluxQL.Mixfile do
  use Mix.Project

  @url_github "https://github.com/mneudert/influxql"

  def project do
    [
      app: :influxql,
      name: "InfluxQL",
      version: "0.2.1",
      elixir: "~> 1.3",
      deps: deps(),
      description: "InfluxQL utility/tooling package",
      docs: docs(),
      package: package(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.travis": :test
      ],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test, runtime: false}
    ]
  end

  defp docs do
    [
      main: "InfluxQL",
      source_ref: "v0.2.1",
      source_url: @url_github
    ]
  end

  defp package do
    %{
      files: ["CHANGELOG.md", "LICENSE", "mix.exs", "README.md", "lib"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => @url_github},
      maintainers: ["Marc Neudert"]
    }
  end
end
