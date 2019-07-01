defmodule AuthX.MixProject do
  use Mix.Project

  @version "0.0.1"
  @url "https://github.com/lcpojr/authx_ex"
  @maintainers ["Luiz Carlos", "Yashin Santos"]

  def project do
    [
      name: "AuthX",
      app: :authex_ex,
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      source_url: @url,
      homepage_url: @url,
      maintainers: @maintainers,
      description: "Elixir authentication and authorization framework",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application(:prod) do
    [
      mod: {AuthX.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      # Tools
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.11", only: :test},
      {:dialyxir, "~> 1.0.0-rc.6", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "AuthX",
      logo: "",
      extras: ["README.md"]
    ]
  end
end
