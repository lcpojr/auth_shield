defmodule AuthX.Repo do
  @moduledoc false
  use Ecto.Repo, otp_app: :authx_ex, adapter: Ecto.Adapters.Postgres
end
