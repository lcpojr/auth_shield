defmodule AuthShield.MixProject do
  use Mix.Project

  @version "0.0.4"
  @url "https://github.com/lcpojr/auth_shield"
  @maintainers ["Luiz Carlos", "Yashin Santos"]
  @licenses ["Apache 2.0"]

  def project do
    [
      name: "AuthShield",
      app: :auth_shield,
      version: @version,
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      aliases: aliases(),
      package: package(),
      description: description(),
      source_url: @url,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      mod: {AuthShield.Application, []},
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
      {:plug_cowboy, "~> 2.0"},
      {:eqrcode, "~> 0.1.6"},

      # Database
      {:postgrex, "~> 0.14", only: [:dev, :test], runtime: false},
      {:ecto_sql, "~> 3.1"},

      # Tools
      {:dialyxir, "~> 1.0.0-rc.6", only: :dev, runtime: false},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_machina, "~> 2.3.0", only: :test, runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:excoveralls, "~> 0.11", only: :test},
      {:mox, "~> 0.5", only: :test},
      {:delx, "~> 3.0"}
    ]
  end

  defp description, do: "Elixir authentication and authorization"

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.txt", "CHANGELOG.md"],
      maintainers: @maintainers,
      licenses: @licenses,
      links: %{
        "GitHub" => "https://github.com/lcpojr/auth_shield",
        "Docs" => "http://hexdocs.pm/auth_shield"
      }
    ]
  end

  defp docs do
    [
      main: "AuthShield",
      extras: [
        "README.md",
        "docs/database.md",
        "docs/authentication.md",
        "docs/authorization.md",
        "docs/utilities.md"
      ],
      deps: [
        ecto_sql: "https://hexdocs.pm/ecto_sql/Ecto.Adapters.SQL.html",
        argon2_elixir: "https://hexdocs.pm/argon2_elixir/api-reference.html",
        eqrcode: "https://hexdocs.pm/eqrcode/readme.html",
        delx: "https://hexdocs.pm/delx/readme.html"
      ]
    ]
  end

  defp aliases do
    [
      "ecto.setup": [
        "ecto.create -r AuthShield.Repo",
        "ecto.migrate -r AuthShield.Repo"
      ],
      "ecto.reset": [
        "ecto.drop -r AuthShield.Repo",
        "ecto.setup"
      ],
      test: [
        "ecto.create --quiet -r AuthShield.Repo",
        "ecto.migrate -r AuthShield.Repo",
        "test"
      ]
    ]
  end
end
