defmodule AuthX.Credentials.Passwords do
  @moduledoc """
  A password is an set of characters that only the user should known.

  We generate an password hash in order to save de password data in our
  database that should be checked in authentication requests.

  This module implements an interface to deal with database transactions
  as inserts, updates, deletes, etc.
  """

  require Ecto.Query

  alias AuthX.Credentials.Schemas.Password
  alias AuthX.Repo

  @typedoc "Transactional responses of success"
  @type success_response :: {:ok, Password.t()}

  @typedoc "Transactional responses of failed"
  @type failed_response :: {:error, Ecto.Changeset.t()}

  @doc "Creates a new `Password` register."
  @spec insert(params :: map()) :: success_response() | failed_response()
  def insert(params) when is_map(params) do
    %Password{}
    |> Password.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Creates a new `__MODULE__` register.

  Similar to `insert/1` but returns the struct or raises if the changeset is invalid.
  """
  @spec insert!(params :: map()) :: Password.t() | no_return()
  def insert!(params) when is_map(params) do
    %Password{}
    |> Password.changeset(params)
    |> Repo.insert!()
  end

  @doc "Updates a `Password` register."
  @spec update(password :: Password.t(), params :: map()) ::
          success_response() | failed_response()
  def update(%Password{} = password, params) when is_map(params) do
    password
    |> Password.changeset(params)
    |> Repo.update()
  end

  @doc """
  Updates a `Password` register.

  Similar to `update/2` but returns the struct or raises if the changeset is invalid.
  """
  @spec update!(password :: Password.t(), params :: map()) :: Password.t() | no_return()
  def update!(%Password{} = password, params) when is_map(params) do
    password
    |> Password.changeset(params)
    |> Repo.update()
  end

  @doc "Returns a list of `Password` by its filters"
  @spec list(filters :: keyword()) :: list(Password.t())
  def list(filters \\ []) when is_list(filters) do
    Password
    |> Ecto.Query.where([p], ^filters)
    |> Repo.all()
  end

  @doc "Gets a `Password` register by its filters."
  @spec get_by(filters :: keyword()) :: Password.t() | nil
  def get_by(filters) when is_list(filters), do: Repo.get_by(Password, filters)

  @doc """
  Gets a `Password` register by its filters.

  Similar to `get_by/1` but returns the struct or raises if the changeset is invalid.
  """
  @spec get_by!(filters :: keyword()) :: Password.t() | no_return()
  def get_by!(filters) when is_list(filters), do: Repo.get_by(Password, filters)

  @doc "Deletes a `Password` register."
  @spec delete(password :: Password.t()) :: success_response() | failed_response()
  def delete(%Password{} = password), do: Repo.delete(password)

  @doc """
  Deletes a `Password` register.

  Similar to `delete/1` but returns the struct or raises if the changeset is invalid.
  """
  @spec delete!(password :: Password.t()) :: Password.t() | no_return()
  def delete!(%Password{} = password), do: Repo.delete!(password)

  @doc """
  Checks if the given password matches with the saved password_hash

  It calls the `Argon2` to verify and returns `true` if the password
  matches and `false` if the passwords doesn't match.
  """
  @spec check_password?(password :: Password.t(), code :: String.t()) :: boolean()
  def check_password?(%Password{} = password, code) when is_binary(code),
    do: Argon2.verify_pass(code, password.password_hash)
end
