use Mix.Config

config :auth_shield, ecto_repos: [AuthShield.Repo]

config :auth_shield, AuthShield.Repo,
  database: "authx_ex_#{Mix.env()}",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5432

config :auth_shield, AuthShield,
  # 15 minutes (in seconds)
  session_expiration: 60 * 15

import_config "#{Mix.env()}.exs"
