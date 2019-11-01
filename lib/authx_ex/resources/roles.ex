defmodule AuthShield.Resources.Roles do
  @moduledoc """
  Roles are used to define an group of permissions that the user has. It usually works
  as an definition of the person function in the company.

  We use this to implement and Role-based access control (RBAC).

  RBAC is a policy-neutral access-control mechanism defined around roles and privileges.

  The components of RBAC such as role-permissions and user-role relationships make it simple
  to perform user assignments.

  This module implements an interface to deal with database transactions
  as inserts, updates, deletes, etc.
  """

  require Ecto.Query

  alias AuthShield.Repo
  alias AuthShield.Resources.Schemas.{Permission, Role}

  @typedoc "Transactional responses of success"
  @type success_response :: {:ok, Role.t()}

  @typedoc "Transactional responses of failed"
  @type failed_response :: {:error, Ecto.Changeset.t()}

  @doc """
  Creates a new `AuthShield.Resources.Schemas.Role` register.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Roles.insert(%{
      name: "admin",
      description: "System administrator"
    })
    ```
  """
  @spec insert(params :: map()) :: success_response() | failed_response()
  def insert(params) when is_map(params) do
    %Role{}
    |> Role.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Creates a new `AuthShield.Resources.Schemas.Role` register.

  Similar to `insert/1` but returns the struct or raises if the changeset is invalid.
  """
  @spec insert!(params :: map()) :: Role.t() | no_return()
  def insert!(params) when is_map(params) do
    %Role{}
    |> Role.changeset(params)
    |> Repo.insert!()
  end

  @doc """
  Updates a `AuthShield.Resources.Schemas.Role` register.
  ## Exemples:
    ```elixir
    AuthShield.Resources.Roles.update(role, %{
      name: "sales",
      description: "The sales user roles"
    })
    ```
  """
  @spec update(role :: Role.t(), params :: map()) :: success_response() | failed_response()
  def update(%Role{} = role, params) when is_map(params) do
    role
    |> Role.changeset(params)
    |> Repo.update()
  end

  @doc """
  Updates a `AuthShield.Resources.Schemas.Role` register.

  Similar to `update/2` but returns the struct or raises if the changeset is invalid.
  """
  @spec update!(role :: Role.t(), params :: map()) :: Role.t() | no_return()
  def update!(%Role{} = role, params) when is_map(params) do
    role
    |> Role.changeset(params)
    |> Repo.update!()
  end

  @doc """
  Returns a list of `AuthShield.Resources.Schemas.Role` by its filters

  ## Exemples:
    ```elixir
    # Getting the all list
    AuthShield.Resources.Roles.list()

    # Filtering the list by field
    AuthShield.Resources.Roles.list(name: "admin")
    ```
  """
  @spec list(filters :: keyword()) :: list(Role.t())
  def list(filters \\ []) when is_list(filters) do
    Role
    |> Ecto.Query.where([r], ^filters)
    |> Repo.all()
  end

  @doc """
  Gets a `AuthShield.Resources.Schemas.Role` register by its filters.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Roles.get_by(name: "admin")
    ```
  """
  @spec get_by(filters :: keyword()) :: Role.t() | nil
  def get_by(filters) when is_list(filters), do: Repo.get_by(Role, filters)

  @doc """
  Gets a `Role` register by its filters.

  Similar to `get_by/1` but returns the struct or raises if the changeset is invalid.
  """
  @spec get_by!(filters :: keyword()) :: Role.t() | no_return()
  def get_by!(filters) when is_list(filters), do: Repo.get_by!(Role, filters)

  @doc """
  Deletes a `AuthShield.Resources.Schemas.Role` register.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Roles.delete(role)
    ```
  """
  @spec delete(role :: Role.t()) :: success_response() | failed_response()
  def delete(%Role{} = role), do: Repo.delete(role)

  @doc """
  Deletes a `AuthShield.Resources.Schemas.Role` register.

  Similar to `delete/1` but returns the struct or raises if the changeset is invalid.
  """
  @spec delete!(role :: Role.t()) :: Role.t() | no_return()
  def delete!(%Role{} = role), do: Repo.delete!(role)

  @doc """
  Changes an set of `AuthShield.Resources.Schemas.Permission` of the `AuthShield.Resources.Schemas.Role`.

  It will add or remove permissions from the list, so you should pass
  the all list every time you use this function.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Roles.change_permissions(role, permissions)
    ```
  """
  @spec change_permissions(role :: Role.t(), permissions :: list(Permission.t())) ::
          success_response() | failed_response()
  def change_permissions(%Role{} = role, permissions) when is_list(permissions) do
    role
    |> Repo.preload(:permissions)
    |> Role.changeset_permissions(permissions)
    |> Repo.update()
  end

  @doc """
  Changes an set of `AuthShield.Resources.Schemas.Permission` of the `AuthShield.Resources.Schemas.Role`.

  Similar to `appeappend_permissionnd_role/2` but returns the struct or raises if the changeset is invalid.
  """
  @spec change_permissions!(role :: Role.t(), permissions :: list(Permission.t())) ::
          Role.t() | no_return()
  def change_permissions!(%Role{} = role, permissions) when is_list(permissions) do
    role
    |> Repo.preload(:permissions)
    |> Role.changeset_permissions(permissions)
    |> Repo.update!()
  end
end
