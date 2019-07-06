use Mix.Config

config :authx_ex, ecto_repos: [AuthX.Repo]

config :authx_ex, AuthX.Repo,
  database: "authx_ex_#{Mix.env()}",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  port: 5432
