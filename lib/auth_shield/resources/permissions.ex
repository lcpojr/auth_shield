defmodule AuthShield.Resources.Permissions do
  @moduledoc """
  Permissions are used to define what a set of roles can do in the
  system.

  We use this to implement and Role-based access control (RBAC).

  RBAC is a policy-neutral access-control mechanism defined around roles and privileges.

  The components of RBAC such as role-permissions and user-role relationships make it simple
  to perform user assignments.

  This module implements an interface to deal with database transactions
  as inserts, updates, deletes, etc.
  """

  require Ecto.Query

  alias AuthShield.Repo
  alias AuthShield.Resources.Schemas.Permission

  @behaviour AuthShield.Resources.Behaviour

  @doc """
  Creates a new `AuthShield.Resources.Schemas.Permission` register.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Permissions.insert(%{
      name: "can_create_users",
      description: "Has permission to create users on the system"
    })
    ```
  """
  @impl true
  def insert(params) when is_map(params) do
    %Permission{}
    |> Permission.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Creates a new `AuthShield.Resources.Schemas.Permission` register.

  Similar to `insert/1` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def insert!(params) when is_map(params) do
    %Permission{}
    |> Permission.changeset(params)
    |> Repo.insert!()
  end

  @doc """
  Updates a `AuthShield.Resources.Schemas.Permission` register.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Permissions.update(permission, %{
      name: "can_update_users",
      description: "Has permission to update users on the system"
    })
    ```
  """
  @impl true
  def update(%Permission{} = permission, params) when is_map(params) do
    permission
    |> Permission.changeset(params)
    |> Repo.update()
  end

  @doc """
  Updates a `AuthShield.Resources.Schemas.Permission` register.

  Similar to `update/2` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def update!(%Permission{} = permission, params) when is_map(params) do
    permission
    |> Permission.changeset(params)
    |> Repo.update!()
  end

  @doc """
  Returns a list of `AuthShield.Resources.Schemas.Permission` by its filters

  ## Exemples:
    ```elixir
    # Getting the all list
    AuthShield.Resources.Permissions.list()

    # Filtering the list by field
    AuthShield.Resources.Permissions.list(name: "can_create_users")
    ```
  """
  @impl true
  def list(filters \\ []) when is_list(filters) do
    Permission
    |> Ecto.Query.where([p], ^filters)
    |> Repo.all()
  end

  @doc """
  Gets a `AuthShield.Resources.Schemas.Permission` register by its filters.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Permissions.get_by(name: "can_create_users")
    ```
  """
  @impl true
  def get_by(filters) when is_list(filters), do: Repo.get_by(Permission, filters)

  @doc """
  Gets a `AuthShield.Resources.Schemas.Permission` register by its filters.

  Similar to `get_by/1` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def get_by!(filters) when is_list(filters), do: Repo.get_by!(Permission, filters)

  @doc """
  Deletes a `AuthShield.Resources.Schemas.Permission` register.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Permissions.delete(permission)
    ```
  """
  @impl true
  def delete(%Permission{} = permission), do: Repo.delete(permission)

  @doc """
  Deletes a `AuthShield.Resources.Schemas.Permission` register.

  Similar to `delete/1` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def delete!(%Permission{} = permission), do: Repo.delete!(permission)
end
