use Mix.Config

# This is the default auth_shield database configuration
# but its highly recomendate that you configure it to be in
# the same database if you want to extend the identity to
# your on custom tables.

config :auth_shield, ecto_repos: [AuthShield.Repo]

config :auth_shield, AuthShield.Repo,
  database: "authshield_#{Mix.env()}",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5432

# You can set the session expiration and block attempts by changing this config
# The default expiration is 15 minutes (in seconds)
# The default max attempts before block is 10
# The default block time is 30 minutes
config :auth_shield, AuthShield,
  session_expiration: 60 * 15,
  block_attempts: 10,
  block_time: 60 * 15

import_config "#{Mix.env()}.exs"
