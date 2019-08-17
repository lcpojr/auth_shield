defmodule AuthX.DataCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      alias Authx.Ecto.Changeset
      alias AuthX.Repo

      import AuthX.{DataCase, Factory}
    end
  end

  setup tags do
    :ok = Sandbox.checkout(AuthX.Repo)

    unless tags[:async] do
      Sandbox.mode(AuthX.Repo, {:shared, self()})
    end

    :ok
  end

  @doc "A helper that transform changeset errors to a map of messages."
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
