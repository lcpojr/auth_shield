defmodule AuthShield.Application do
  @moduledoc false

  use Application

  alias AuthShield.Repo

  @spec start(any(), any()) :: {:error, any()} | {:ok, pid()}
  def start(_type, _args) do
    Supervisor.start_link([Repo], strategy: :one_for_one, name: AuthShield.Supervisor)
  end
end
