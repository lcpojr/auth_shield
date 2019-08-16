defmodule AuthX.Resources.Users do
  @moduledoc """
  Users are the base identity in our architecture. It is used to
  authenticate an profile or to authorize an action given its set of
  roles.

  We use an Role-based access control architecture as an approach to restricting
  system access to authorized users, so our resources contains users, roles and permissions.

  This module implements an interface to deal with database transactions
  as inserts, updates, deletes, etc.
  """

  require Ecto.Query

  alias AuthX.Credentials.Passwords
  alias AuthX.Resources.Schemas.{Role, User}
  alias AuthX.Repo

  @typedoc "Transactional responses of success"
  @type success_response :: {:ok, User.t()}

  @typedoc "Transactional responses of failed"
  @type failed_response :: {:error, Ecto.Changeset.t()}

  @doc "Creates a new `User` register."
  @spec insert(params :: map()) :: success_response() | failed_response()
  def insert(params) when is_map(params) do
    %User{}
    |> User.changeset_insert(params)
    |> Repo.insert()
  end

  @doc """
  Creates a new `__MODULE__` register.

  Similar to `insert/1` but raises if the changeset is invalid.
  """
  @spec insert!(params :: map()) :: success_response() | no_return()
  def insert!(params) when is_map(params) do
    %User{}
    |> User.changeset_insert(params)
    |> Repo.insert!()
  end

  @doc "Updates a `User` register."
  @spec update(user :: User.t(), params :: map()) :: success_response() | failed_response()
  def update(%User{} = user, params) when is_map(params) do
    user
    |> User.changeset_update(params)
    |> Repo.update()
  end

  @doc """
  Updates a `User` register.

  Similar to `update/2` but raises if the changeset is invalid.
  """
  @spec update!(user :: User.t(), params :: map()) :: success_response() | no_return()
  def update!(%User{} = user, params) when is_map(params) do
    user
    |> User.changeset_update(params)
    |> Repo.update()
  end

  @doc "Returns a list of `User` by its filters"
  @spec list(filters :: keyword()) :: list(User.t())
  def list(filters \\ []) when is_list(filters) do
    User
    |> Ecto.Query.where([u], ^filters)
    |> Repo.all()
  end

  @doc "Gets a `User` register by its filters."
  @spec get_by(filters :: keyword()) :: User.t() | nil
  def get_by(filters) when is_list(filters), do: Repo.get_by(User, filters)

  @doc """
  Gets a `User` register by its filters.

  Similar to `get_by/1` but raises `Ecto.NoResultsError` if no record was found.
  Raises if more than one entry.
  """
  @spec get_by!(filters :: keyword()) :: User.t() | no_return()
  def get_by!(filters) when is_list(filters), do: Repo.get_by(User, filters)

  @doc "Deletes a `User` register."
  @spec delete(user :: User.t()) :: success_response() | failed_response()
  def delete(%User{} = user), do: Repo.delete(user)

  @doc """
  Deletes a `User` register.

  Similar to `delete/1` but raises `Ecto.NoResultsError` if no record was found.
  Raises if changeset is invalid.
  """
  @spec delete!(user :: User.t()) :: success_response() | no_return()
  def delete!(%User{} = user), do: Repo.delete!(user)

  @doc "Changes a `User` status."
  @spec status(user :: User.t(), status :: boolean()) :: success_response() | failed_response()
  def status(%User{} = user, status) when is_boolean(status) do
    user
    |> User.changeset_status(%{is_active: status})
    |> Repo.update()
  end

  @doc """
  Changes a `User` status.

  Similar to `status/1` but raises `Ecto.NoResultsError` if no record was found.
  Raises if changeset is invalid.
  """
  @spec status!(user :: User.t(), status :: boolean()) :: success_response() | no_return()
  def status!(%User{} = user, status) when is_boolean(status) do
    user
    |> User.changeset_status(%{is_active: status})
    |> Repo.update!()
  end

  @doc """
  Changes an set of `Role` of the `User`.

  It will add or remove roles from the list, so you should pass
  the all list every time you use this function.
  """
  @spec change_roles(user :: User.t(), roles :: list(Role.t())) ::
          success_response() | failed_response()
  def change_roles(%User{} = user, roles) do
    user
    |> Repo.preload(:roles)
    |> User.changeset_roles(roles)
    |> Repo.update()
  end

  @doc """
  Changes an set of `Role` of the `User`.

  Similar to `append_role/2` but raises if the changeset is invalid.
  """
  @spec change_roles!(user :: User.t(), roles :: list(Role.t())) ::
          success_response() | no_return()
  def change_roles!(%User{} = user, roles) do
    user
    |> Repo.preload(:roles)
    |> User.changeset_roles(roles)
    |> Repo.update!()
  end

  @doc "Preloads the user data by the given fields."
  @spec preload(user :: User.t(), fields :: keyword()) :: User.t()
  def preload(%User{} = user, fields) when is_list(fields), do: Repo.preload(user, fields)
end
