defmodule AuthX.Users do
  @moduledoc """
  Implements an interface to deal with database transactions as inserts, updates, deletes, etc.

  It will also be used to verify user credentials on authentication and permissions on
  authorization.
  """

  alias AuthX.Resources.Schemas.User
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

  @doc "Changes a `User` status."
  @spec change_password(user :: User.t(), password :: String.t()) ::
          success_response() | failed_response()
  def change_password(%User{} = user, password) when is_binary(password) do
    user
    |> User.changeset_status(%{password: password})
    |> Repo.update()
  end

  @doc """
  Changes a `User` password.

  Similar to `change_password/1` but raises `Ecto.NoResultsError` if no record was found.
  Raises if changeset is invalid.
  """
  @spec change_password!(user :: User.t(), password :: String.t()) ::
          success_response() | no_return()
  def change_password!(%User{} = user, password) when is_binary(password) do
    user
    |> User.changeset_status(%{password: password})
    |> Repo.update!()
  end

  @doc """
  Checks if the given password matches with the user password_hash

  It calls the `Argon2` to verify and returns `true` if the password
  matches and `false` if the passwords doesn't match.
  """
  @spec check_password?(user :: User.t(), password :: String.t()) :: boolean()
  def check_password?(%User{} = user, password) when is_binary(password),
    do: Argon2.verify_pass(password, user.password_hash)
end
