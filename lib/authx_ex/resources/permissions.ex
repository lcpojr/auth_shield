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

  @typedoc "Transactional responses of success"
  @type success_response :: {:ok, Permission.t()}

  @typedoc "Transactional responses of failed"
  @type failed_response :: {:error, Ecto.Changeset.t()}

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
  @spec insert(params :: map()) :: success_response() | failed_response()
  def insert(params) when is_map(params) do
    %Permission{}
    |> Permission.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Creates a new `AuthShield.Resources.Schemas.Permission` register.

  Similar to `insert/1` but returns the struct or raises if the changeset is invalid.
  """
  @spec insert!(params :: map()) :: Permission.t() | no_return()
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
  @spec update(permission :: Permission.t(), params :: map()) ::
          success_response() | failed_response()
  def update(%Permission{} = permission, params) when is_map(params) do
    permission
    |> Permission.changeset(params)
    |> Repo.update()
  end

  @doc """
  Updates a `AuthShield.Resources.Schemas.Permission` register.

  Similar to `update/2` but returns the struct or raises if the changeset is invalid.
  """
  @spec update!(permission :: Permission.t(), params :: map()) :: Permission.t() | no_return()
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
  @spec list(filters :: keyword()) :: list(Permission.t())
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
  @spec get_by(filters :: keyword()) :: Permission.t() | nil
  def get_by(filters) when is_list(filters), do: Repo.get_by(Permission, filters)

  @doc """
  Gets a `AuthShield.Resources.Schemas.Permission` register by its filters.

  Similar to `get_by/1` but returns the struct or raises if the changeset is invalid.
  """
  @spec get_by!(filters :: keyword()) :: Permission.t() | no_return()
  def get_by!(filters) when is_list(filters), do: Repo.get_by!(Permission, filters)

  @doc """
  Deletes a `AuthShield.Resources.Schemas.Permission` register.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Permissions.delete(permission)
    ```
  """
  @spec delete(permission :: Permission.t()) :: success_response() | failed_response()
  def delete(%Permission{} = permission), do: Repo.delete(permission)

  @doc """
  Deletes a `AuthShield.Resources.Schemas.Permission` register.

  Similar to `delete/1` but returns the struct or raises if the changeset is invalid.
  """
  @spec delete!(permission :: Permission.t()) :: Permission.t() | no_return()
  def delete!(%Permission{} = permission), do: Repo.delete!(permission)
end
