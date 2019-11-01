defmodule AuthShield.DataCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      alias AuthShield.Ecto.Changeset
      alias AuthShield.Repo

      import AuthShield.{DataCase, Factory}
    end
  end

  setup tags do
    :ok = Sandbox.checkout(AuthShield.Repo)

    unless tags[:async] do
      Sandbox.mode(AuthShield.Repo, {:shared, self()})
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
