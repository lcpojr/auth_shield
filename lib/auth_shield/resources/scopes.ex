defmodule AuthShield.Resources.Scopes do
  @moduledoc """
  Scopes are used to define an group of action that the applications can do.

  This module implements an interface to deal with database transactions
  as inserts, updates, deletes, etc.
  """

  require Ecto.Query

  alias AuthShield.Repo
  alias AuthShield.Resources.Schemas.{Application, Scope}

  @behaviour AuthShield.Resources.Behaviour

  @doc """
  Creates a new `AuthShield.Resources.Schemas.Scope` register.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Scopes.insert(%{name: "user:read", description: "Can read all user information"})
    ```
  """
  @impl true
  def insert(params) when is_map(params) do
    %Scope{}
    |> Scope.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Creates a new `AuthShield.Resources.Schemas.Scope` register.

  Similar to `insert/1` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def insert!(params) when is_map(params) do
    %Scope{}
    |> Scope.changeset(params)
    |> Repo.insert!()
  end

  @doc """
  Updates a `AuthShield.Resources.Schemas.Scope` register.
  ## Exemples:
    ```elixir
    AuthShield.Resources.Scopes.update(scope, %{name: "user:write", description: "Can write information on user profile"})
    ```
  """
  @impl true
  def update(%Scope{} = scope, params) when is_map(params) do
    scope
    |> Scope.changeset(params)
    |> Repo.update()
  end

  @doc """
  Updates a `AuthShield.Resources.Schemas.Scope` register.

  Similar to `update/2` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def update!(%Scope{} = scope, params) when is_map(params) do
    scope
    |> Scope.changeset(params)
    |> Repo.update!()
  end

  @doc """
  Returns a list of `AuthShield.Resources.Schemas.Scope` by its filters

  ## Exemples:
    ```elixir
    # Getting the all list
    AuthShield.Resources.Scopes.list()

    # Filtering the list by field
    AuthShield.Resources.Scopes.list(name: "user:read")
    ```
  """
  @impl true
  def list(filters \\ []) when is_list(filters) do
    Scope
    |> Ecto.Query.where([r], ^filters)
    |> Repo.all()
  end

  @doc """
  Gets a `AuthShield.Resources.Schemas.Scope` register by its filters.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Scopes.get_by(name: "user:read")
    ```
  """
  @impl true
  def get_by(filters) when is_list(filters), do: Repo.get_by(Scope, filters)

  @doc """
  Gets a `Scope` register by its filters.

  Similar to `get_by/1` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def get_by!(filters) when is_list(filters), do: Repo.get_by!(Scope, filters)

  @doc """
  Deletes a `AuthShield.Resources.Schemas.Scope` register.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Scopes.delete(scope)
    ```
  """
  @impl true
  def delete(%Scope{} = scope), do: Repo.delete(scope)

  @doc """
  Deletes a `AuthShield.Resources.Schemas.Scope` register.

  Similar to `delete/1` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def delete!(%Scope{} = scope), do: Repo.delete!(scope)

  @doc """
  Changes an set of `AuthShield.Resources.Schemas.Application` of the `AuthShield.Resources.Schemas.Scope`.

  It will add or remove applications from the list, so you should pass
  the all list every time you use this function.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Scopes.change_applications(scope, applications)
    ```
  """
  @spec change_applications(
          scope :: Scope.t(),
          applications :: list(Application.t())
        ) :: {:ok, Scope.t()} | {:error, Ecto.Changeset.t()}
  def change_applications(%Scope{} = scope, applications) when is_list(applications) do
    scope
    |> Repo.preload(:applications)
    |> Scope.changeset_applications(applications)
    |> Repo.update()
  end

  @doc """
  Changes an set of `AuthShield.Resources.Schemas.Application` of the `AuthShield.Resources.Schemas.Scope`.

  Similar to `appeappend_permissionnd_scope/2` but returns the struct or raises if the changeset is invalid.
  """
  @spec change_applications!(
          scope :: Scope.t(),
          applications :: list(Application.t())
        ) :: Scope.t() | no_return()
  def change_applications!(%Scope{} = scope, applications) when is_list(applications) do
    scope
    |> Repo.preload(:applications)
    |> Scope.changeset_applications(applications)
    |> Repo.update!()
  end
end
