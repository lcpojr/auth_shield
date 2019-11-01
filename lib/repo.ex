defmodule AuthShield.Repo do
  @moduledoc false
  use Ecto.Repo, otp_app: :auth_shield, adapter: Ecto.Adapters.Postgres
end
