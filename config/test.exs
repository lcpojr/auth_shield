use Mix.Config

config :logger, level: :error

config :authx_ex, AuthX.Repo, pool: Ecto.Adapters.SQL.Sandbox
