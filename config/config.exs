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
# All timestamps are in seconds.
config :auth_shield, AuthShield,
  session_expiration: 60 * 15,
  max_login_attempts: 10,
  login_block_time: 60 * 15,
  brute_force_login_interval: 1,
  brute_force_login_attempts: 5

import_config "#{Mix.env()}.exs"
