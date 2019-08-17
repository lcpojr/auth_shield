use Mix.Config

config :authx_ex, ecto_repos: [AuthX.Repo]

config :authx_ex, AuthX.Repo,
  database: "authx_ex_#{Mix.env()}",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5432

import_config "#{Mix.env()}.exs"
