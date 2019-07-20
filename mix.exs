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

  defp deps do
    [
      # Domain
      {:burnex, "~> 1.0"},
      {:argon2_elixir, "~> 2.0"},
      {:uuid, "~> 1.1.8"},
      {:jason, "~> 1.1"},
      {:timex, "~> 3.5"},

      # Database
      {:postgrex, "~> 0.14"},
      {:ecto_sql, "~> 3.1"},

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

  defp aliases do
    [
      "ecto.setup": [
        "ecto.create -r AuthX.Repo"
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
