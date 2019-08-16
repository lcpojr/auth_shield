defmodule AuthX.Resources.Roles do
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

  alias AuthX.Resources.Schemas.{Role, Permission}
  alias AuthX.Repo

  @typedoc "Transactional responses of success"
  @type success_response :: {:ok, Role.t()}

  @typedoc "Transactional responses of failed"
  @type failed_response :: {:error, Ecto.Changeset.t()}

  @doc "Creates a new `Role` register."
  @spec insert(params :: map()) :: success_response() | failed_response()
  def insert(params) when is_map(params) do
    %Role{}
    |> Role.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Creates a new `__MODULE__` register.

  Similar to `insert/1` but raises if the changeset is invalid.
  """
  @spec insert!(params :: map()) :: success_response() | no_return()
  def insert!(params) when is_map(params) do
    %Role{}
    |> Role.changeset(params)
    |> Repo.insert!()
  end

  @doc "Updates a `Role` register."
  @spec update(role :: Role.t(), params :: map()) :: success_response() | failed_response()
  def update(%Role{} = role, params) when is_map(params) do
    role
    |> Role.changeset(params)
    |> Repo.update()
  end

  @doc """
  Updates a `Role` register.

  Similar to `update/2` but raises if the changeset is invalid.
  """
  @spec update!(role :: Role.t(), params :: map()) :: success_response() | no_return()
  def update!(%Role{} = role, params) when is_map(params) do
    role
    |> Role.changeset(params)
    |> Repo.update()
  end

  @doc "Returns a list of `Role` by its filters"
  @spec list(filters :: keyword()) :: list(Role.t())
  def list(filters \\ []) when is_list(filters) do
    Role
    |> Ecto.Query.where([r], ^filters)
    |> Repo.all()
  end

  @doc "Gets a `Role` register by its filters."
  @spec get_by(filters :: keyword()) :: Role.t() | nil
  def get_by(filters) when is_list(filters), do: Repo.get_by(Role, filters)

  @doc """
  Gets a `Role` register by its filters.

  Similar to `get_by/1` but raises `Ecto.NoResultsError` if no record was found.
  Raises if more than one entry.
  """
  @spec get_by!(filters :: keyword()) :: Role.t() | no_return()
  def get_by!(filters) when is_list(filters), do: Repo.get_by(Role, filters)

  @doc "Deletes a `Role` register."
  @spec delete(role :: Role.t()) :: success_response() | failed_response()
  def delete(%Role{} = role), do: Repo.delete(role)

  @doc """
  Deletes a `Role` register.

  Similar to `delete/1` but raises `Ecto.NoResultsError` if no record was found.
  Raises if changeset is invalid.
  """
  @spec delete!(role :: Role.t()) :: success_response() | no_return()
  def delete!(%Role{} = role), do: Repo.delete!(role)

  @doc """
  Changes an set of `Permission` of the `Role`.

  It will add or remove permissions from the list, so you should pass
  the all list every time you use this function.
  """
  @spec change_permissions(role :: Role.t(), permissions :: list(Permission.t())) ::
          success_response() | failed_response()
  def change_permissions(%Role{} = role, permissions) do
    role
    |> Repo.preload(:permissions)
    |> Role.changeset_permissions(permissions)
    |> Repo.update()
  end

  @doc """
  Changes an set of `Permission` of the `Role`.

  Similar to `appeappend_permissionnd_role/2` but raises if the changeset is invalid.
  """
  @spec change_permissions!(role :: Role.t(), permissions :: list(Permission.t())) ::
          success_response() | no_return()
  def change_permissions!(%Role{} = role, permissions) do
    role
    |> Repo.preload(:permissions)
    |> Role.changeset_permissions(permissions)
    |> Repo.update!()
  end
end
