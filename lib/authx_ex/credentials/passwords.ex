defmodule AuthShield.Credentials.Passwords do
  @moduledoc """
  A password is an set of characters that only the user should known.

  We generate an password hash in order to save de password data in our
  database that should be checked in authentication requests.

  This module implements an interface to deal with database transactions
  as inserts, updates, deletes, etc.
  """

  require Ecto.Query

  alias AuthShield.Credentials.Schemas.Password
  alias AuthShield.Repo

  @behaviour AuthShield.Credentials.Behaviour

  @doc """
  Creates a new `AuthShield.Credentials.Schemas.Password` register.

  ## Exemples:
    ```elixir
    AuthShield.Credentials.Passwords.insert(%{
      user_id: "ecb4c67d-6380-4984-ae04-1563e885d59e",
      password: "Mypass@rd123"
    })
    ```
  """
  @impl true
  def insert(params) when is_map(params) do
    %Password{}
    |> Password.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Creates a new `AuthShield.Credentials.Schemas.Password` register.

  Similar to `insert/1` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def insert!(params) when is_map(params) do
    %Password{}
    |> Password.changeset(params)
    |> Repo.insert!()
  end

  @doc """
  Updates a `AuthShield.Credentials.Schemas.Password` register.

  ## Exemples:
    ```elixir
    AuthShield.Credentials.Passwords.update(password, %{
      user_id: "ecb4c67d-6380-4984-ae04-1563e885d59e",
      password: "Mypass@rd123"
    })
    ```
  """
  @spec update(
          password :: Password.t(),
          params :: map()
        ) :: {:ok, Password.t()} | {:error, Ecto.Changeset.t()}
  def update(%Password{} = password, params) when is_map(params) do
    password
    |> Password.changeset(params)
    |> Repo.update()
  end

  @doc """
  Updates a `AuthShield.Credentials.Schemas.Password` register.

  Similar to `update/2` but returns the struct or raises if the changeset is invalid.
  """
  @spec update!(password :: Password.t(), params :: map()) :: {:ok, Password.t()} | no_return()
  def update!(%Password{} = password, params) when is_map(params) do
    password
    |> Password.changeset(params)
    |> Repo.update!()
  end

  @doc """
  Returns a list of `AuthShield.Credentials.Schemas.Password` by its filters

  ## Exemples:
    ```elixir
    # Getting the all list
    AuthShield.Credentials.Passwords.list()

    # Filtering the list by field
    AuthShield.Credentials.Passwords.list(user_id: "ecb4c67d-6380-4984-ae04-1563e885d59e")
    ```
  """
  @impl true
  def list(filters \\ []) when is_list(filters) do
    Password
    |> Ecto.Query.where([p], ^filters)
    |> Repo.all()
  end

  @doc """
  Gets a `AuthShield.Credentials.Schemas.Password` register by its filters.

  ## Exemples:
    ```elixir
    AuthShield.Credentials.Passwords.get_by(user_id: "ecb4c67d-6380-4984-ae04-1563e885d59e")
    ```
  """
  @impl true
  def get_by(filters) when is_list(filters), do: Repo.get_by(Password, filters)

  @doc """
  Gets a `AuthShield.Credentials.Schemas.Password` register by its filters.

  Similar to `get_by/1` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def get_by!(filters) when is_list(filters), do: Repo.get_by!(Password, filters)

  @doc """
  Deletes a `AuthShield.Credentials.Schemas.Password` register.

  ## Exemples:
    ```elixir
    AuthShield.Credentials.Passwords.delete(password)
    ```
  """
  @impl true
  def delete(%Password{} = password), do: Repo.delete(password)

  @doc """
  Deletes a `AuthShield.Credentials.Schemas.Password` register.

  Similar to `delete/1` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def delete!(%Password{} = password), do: Repo.delete!(password)

  @doc """
  Checks if the given password matches with the saved password_hash

  It calls the `Argon2` to verify and returns `true` if the password
  matches and `false` if the passwords doesn't match.

  ## Exemples:
    ```elixir
    AuthShield.Credentials.Passwords.check_password?(password, "345617")
    ```
  """
  @spec check_password?(password :: Password.t(), pass_code :: String.t()) :: boolean()
  def check_password?(%Password{} = password, pass_code) when is_binary(pass_code),
    do: Argon2.verify_pass(pass_code, password.password_hash)
end
