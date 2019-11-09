defmodule AuthShield.Resources.Users do
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

  alias AuthShield.Repo
  alias AuthShield.Resources.Schemas.{Role, User}

  @behaviour AuthShield.Resources.Behaviour

  @doc """
  Creates a new `AuthShield.Resources.Schemas.User` register.

  For an user to be authenticate in the system it will need an credential,
  so when we create an user we also creates a `AuthShield.Credentials.Schemas.Password`
  that can be used to perform actions in `AuthShield.Authentication`.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Users.insert(%{
      first_name: "Lucas",
      last_name: "Mesquita",
      email: "lucas@gmail.com",
      password_credential: %{password: "My_passw@rd2"}
    })
    ```
  """
  @impl true
  def insert(params) when is_map(params) do
    %User{}
    |> User.changeset_insert(params)
    |> Repo.insert()
  end

  @doc """
  Creates a new `AuthShield.Resources.Schemas.User` register.

  Similar to `insert/1` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def insert!(params) when is_map(params) do
    %User{}
    |> User.changeset_insert(params)
    |> Repo.insert!()
  end

  @doc """
  Updates a `AuthShield.Resources.Schemas.User` register.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Users.update(user, %{
      first_name: "Marcos",
      last_name: "Farias",
      email: "marcos@gmail.com"
    })
    ```
  """
  @impl true
  def update(%User{} = user, params) when is_map(params) do
    user
    |> User.changeset_update(params)
    |> Repo.update()
  end

  @doc """
  Updates a `AuthShield.Resources.Schemas.User` register.

  Similar to `update/2` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def update!(%User{} = user, params) when is_map(params) do
    user
    |> User.changeset_update(params)
    |> Repo.update!()
  end

  @doc """
  Returns a list of `AuthShield.Resources.Schemas.User` by its filters

  ## Exemples:
    ```elixir
    # Getting the all list
    AuthShield.Resources.Users.list()

    # Filtering the list by field
    AuthShield.Resources.Users.list(name: "Lucas")
    ```
  """
  @impl true
  def list(filters \\ []) when is_list(filters) do
    User
    |> Ecto.Query.where([u], ^filters)
    |> Repo.all()
  end

  @doc """
  Gets a `AuthShield.Resources.Schemas.User` register by its filters.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Users.get_by(email: "lucas@gmail.com")
    ```
  """
  @impl true
  def get_by(filters) when is_list(filters), do: Repo.get_by(User, filters)

  @doc """
  Gets a `AuthShield.Resources.Schemas.User` register by its filters.

  Similar to `get_by/1` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def get_by!(filters) when is_list(filters), do: Repo.get_by!(User, filters)

  @doc """
  Deletes a `User` register.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Users.delete(user)
    ```
  """
  @impl true
  def delete(%User{} = user), do: Repo.delete(user)

  @doc """
  Deletes a `AuthShield.Resources.Schemas.User` register.

  Similar to `delete/1` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def delete!(%User{} = user), do: Repo.delete!(user)

  @doc """
  Changes a `User` status.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Users.status(user, true)
    ```
  """
  @spec status(
          user :: User.t(),
          status :: boolean()
        ) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def status(%User{} = user, status) when is_boolean(status) do
    user
    |> User.changeset_status(%{is_active: status})
    |> Repo.update()
  end

  @doc """
  Changes a `AuthShield.Resources.Schemas.User` status.

  Similar to `status/1` but returns the struct or raises if the changeset is invalid.
  """
  @spec status!(user :: User.t(), status :: boolean()) :: User.t() | no_return()
  def status!(%User{} = user, status) when is_boolean(status) do
    user
    |> User.changeset_status(%{is_active: status})
    |> Repo.update!()
  end

  @doc """
  Changes an set of `AuthShield.Resources.Schemas.Role` of the `AuthShield.Resources.Schemas.User`.

  It will add or remove roles from the list, so you should pass
  the complete list every time you use this function.

  Roles are used in `AuthShield.Authorization` requests.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Users.change_roles(user, roles)
    ```
  """
  @spec change_roles(
          user :: User.t(),
          roles :: list(Role.t())
        ) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def change_roles(%User{} = user, roles) when is_list(roles) do
    user
    |> Repo.preload(:roles)
    |> User.changeset_roles(roles)
    |> Repo.update()
  end

  @doc """
  Changes an set of `AuthShield.Resources.Schemas.Role` of the `AuthShield.Resources.Schemas.User`.

  Similar to `append_role/2` but returns the struct or raises if the changeset is invalid.
  """
  @spec change_roles!(user :: User.t(), roles :: list(Role.t())) :: User.t() | no_return()
  def change_roles!(%User{} = user, roles) when is_list(roles) do
    user
    |> Repo.preload(:roles)
    |> User.changeset_roles(roles)
    |> Repo.update!()
  end

  @doc """
  Preloads the user data by the given fields.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Users.preload(user, [:roles])
    ```
  """
  @spec preload(user :: User.t(), fields :: keyword()) :: User.t()
  def preload(%User{} = user, fields) when is_list(fields), do: Repo.preload(user, fields)
end
