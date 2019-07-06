use Mix.Config

config :authex_ex, ecto_repos: [AuthX.Repo]

config :authex_ex, AuthX.Repo,
  database: "authex_ex",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
