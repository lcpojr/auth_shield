use Mix.Config

config :logger, level: :error

config :auth_shield, AuthShield.Repo, pool: Ecto.Adapters.SQL.Sandbox

config :auth_shield, Delx, delegator: AuthShield.DelegatorMock
