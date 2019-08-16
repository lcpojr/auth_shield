defmodule AuthX.Resources.Permissions do
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

  alias AuthX.Repo
  alias AuthX.Resources.Schemas.Permission

  @typedoc "Transactional responses of success"
  @type success_response :: {:ok, Permission.t()}

  @typedoc "Transactional responses of failed"
  @type failed_response :: {:error, Ecto.Changeset.t()}

  @doc "Creates a new `Permissions` register."
  @spec insert(params :: map()) :: success_response() | failed_response()
  def insert(params) when is_map(params) do
    %Permission{}
    |> Permission.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Creates a new `__MODULE__` register.

  Similar to `insert/1` but raises if the changeset is invalid.
  """
  @spec insert!(params :: map()) :: success_response() | no_return()
  def insert!(params) when is_map(params) do
    %Permission{}
    |> Permission.changeset(params)
    |> Repo.insert!()
  end

  @doc "Updates a `Permissions` register."
  @spec update(permission :: Permission.t(), params :: map()) ::
          success_response() | failed_response()
  def update(%Permission{} = permission, params) when is_map(params) do
    permission
    |> Permission.changeset(params)
    |> Repo.update()
  end

  @doc """
  Updates a `Permissions` register.

  Similar to `update/2` but raises if the changeset is invalid.
  """
  @spec update!(permission :: Permission.t(), params :: map()) :: success_response() | no_return()
  def update!(%Permission{} = permission, params) when is_map(params) do
    permission
    |> Permission.changeset(params)
    |> Repo.update()
  end

  @doc "Returns a list of `Permission` by its filters"
  @spec list(filters :: keyword()) :: list(Permission.t())
  def list(filters \\ []) when is_list(filters) do
    Permission
    |> Ecto.Query.where([p], ^filters)
    |> Repo.all()
  end

  @doc "Gets a `Permissions` register by its filters."
  @spec get_by(filters :: keyword()) :: Permission.t() | nil
  def get_by(filters) when is_list(filters), do: Repo.get_by(Permission, filters)

  @doc """
  Gets a `Permissions` register by its filters.

  Similar to `get_by/1` but raises `Ecto.NoResultsError` if no record was found.
  Raises if more than one entry.
  """
  @spec get_by!(filters :: keyword()) :: Permission.t() | no_return()
  def get_by!(filters) when is_list(filters), do: Repo.get_by(Permission, filters)

  @doc "Deletes a `Permissions` register."
  @spec delete(permission :: Permission.t()) :: success_response() | failed_response()
  def delete(%Permission{} = permission), do: Repo.delete(permission)

  @doc """
  Deletes a `Permissions` register.

  Similar to `delete/1` but raises `Ecto.NoResultsError` if no record was found.
  Raises if changeset is invalid.
  """
  @spec delete!(permission :: Permission.t()) :: success_response() | no_return()
  def delete!(%Permission{} = permission), do: Repo.delete!(permission)
end
