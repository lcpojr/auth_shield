defmodule AuthX.Users do
  @moduledoc """
  Implements an interface to deal with database transactions as inserts, updates, deletes, etc.

  It will also be used to verify user credentials on authentication and permissions on
  authorization.
  """

  alias AuthX.Schemas.User
  alias AuthX.Repo

  @doc "Creates a new `__MODULE__` register."
  @spec insert(params :: map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def insert(params) when is_map(params) do
    %User{}
    |> User.changeset_insert(params)
    |> Repo.insert()
  end

  @doc """
  Creates a new `__MODULE__` register.

  Similar to `insert/1` but raises if the changeset is invalid.
  """
  @spec insert!(params :: map()) :: {:ok, User.t()}
  def insert!(params) when is_map(params) do
    %User{}
    |> User.changeset_insert(params)
    |> Repo.insert!()
  end

  @doc "Updates a `__MODULE__` register."
  @spec update(model :: User.t(), params :: map()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update(%User{} = model, params) when is_map(params) do
    model
    |> User.changeset_update(params)
    |> Repo.update()
  end

  @doc """
  Updates a `__MODULE__` register.

  Similar to `update/2` but raises if the changeset is invalid.
  """
  @spec update!(model :: User.t(), params :: map()) :: {:ok, User.t()}
  def update!(%User{} = model, params) when is_map(params) do
    model
    |> User.changeset_update(params)
    |> Repo.update()
  end

  @doc "Gets a `__MODULE__` register by its filters."
  @spec get_by(filters :: keyword()) :: User.t() | nil
  def get_by(filters) when is_list(filters), do: Repo.get_by(User, filters)

  @doc """
  Gets a `__MODULE__` register by its filters.

  Similar to `get_by/1` but raises `Ecto.NoResultsError` if no record was found.
  Raises if more than one entry.
  """
  @spec get_by!(filters :: keyword()) :: User.t()
  def get_by!(filters) when is_list(filters), do: Repo.get_by(User, filters)

  @doc "Deletes a `__MODULE__` register."
  @spec delete(model :: User.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def delete(%User{} = model), do: Repo.delete(model)

  @doc """
  Deletes a `__MODULE__` register.

  Similar to `delete/1` but raises `Ecto.NoResultsError` if no record was found.
  Raises if changeset is invalid.
  """
  @spec delete!(model :: User.t()) :: {:ok, User.t()}
  def delete!(%User{} = model), do: Repo.delete!(model)

  @doc "Changes a `__MODULE__` status."
  @spec status(model :: User.t(), status :: boolean()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def status(%User{} = model, status) when is_boolean(status) do
    model
    |> User.changeset_status(%{is_active: status})
    |> Repo.update()
  end

  @doc """
  Changes a `__MODULE__` status.

  Similar to `status/1` but raises `Ecto.NoResultsError` if no record was found.
  Raises if changeset is invalid.
  """
  @spec status!(model :: User.t(), status :: boolean()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def status!(%User{} = model, status) when is_boolean(status) do
    model
    |> User.changeset_status(%{is_active: status})
    |> Repo.update!()
  end

  @doc "Changes a `__MODULE__` status."
  @spec change_password(model :: User.t(), password :: String.t()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def change_password(%User{} = model, password) when is_binary(status) do
    model
    |> User.changeset_status(%{password: password})
    |> Repo.update()
  end

  @doc """
  Changes a `__MODULE__` password.

  Similar to `change_password/1` but raises `Ecto.NoResultsError` if no record was found.
  Raises if changeset is invalid.
  """
  @spec change_password!(model :: User.t(), password :: String.t()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def change_password!(%User{} = model, password) when is_binary(password) do
    model
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
