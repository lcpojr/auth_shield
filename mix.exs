defmodule AuthX.MixProject do
  use Mix.Project

  @version "0.0.1"
  @url "https://github.com/lcpojr/authx_ex"
  @maintainers ["Luiz Carlos", "Yashin Santos"]

  def project do
    [
      name: "AuthX",
      app: :authx_ex,
      version: @version,
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      aliases: aliases(),
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

  def application do
    [
      mod: {AuthX.Application, []},
      extra_applications: [:logger]
    ]
  end

  # This makes sure your factory and any other modules in test/support are compiled
  # when in the test environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Domain
      {:argon2_elixir, "~> 2.0"},
      {:uuid, "~> 1.1.8"},
      {:jason, "~> 1.1"},
      {:timex, "~> 3.5"},
      {:eqrcode, "~> 0.1.6"},

      # Database
      {:postgrex, "~> 0.14"},
      {:ecto_sql, "~> 3.1"},

      # Tools
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.11", only: :test},
      {:dialyxir, "~> 1.0.0-rc.6", only: :dev, runtime: false},
      {:ex_machina, "~> 2.3.0", only: :test, runtime: false}
    ]
  end

  defp docs do
    [
      main: "AuthX",
      extras: ["README.md", "docs/database.md"],
      deps: [
        postgrex: "https://hexdocs.pm/postgrex/readme.html",
        ecto_sql: "https://hexdocs.pm/ecto_sql/Ecto.Adapters.SQL.html",
        argon2_elixir: "https://hexdocs.pm/argon2_elixir/api-reference.html",
        timex: "https://hexdocs.pm/timex/getting-started.html",
        eqrcode: "https://hexdocs.pm/eqrcode/readme.html"
      ]
    ]
  end

  defp aliases do
    [
      "ecto.setup": [
        "ecto.create -r AuthX.Repo",
        "ecto.migrate -r AuthX.Repo"
      ],
      "ecto.reset": [
        "ecto.drop -r AuthX.Repo",
        "ecto.setup"
      ],
      test: [
        "ecto.create --quiet -r AuthX.Repo",
        "ecto.migrate -r AuthX.Repo",
        "test"
      ]
    ]
  end
end
