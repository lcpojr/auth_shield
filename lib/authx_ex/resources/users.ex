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

  alias AuthX.Repo
  alias AuthX.Resources.Schemas.{Role, User}

  @typedoc "Transactional responses of success"
  @type success_response :: {:ok, User.t()}

  @typedoc "Transactional responses of failed"
  @type failed_response :: {:error, Ecto.Changeset.t()}

  @doc """
  Creates a new `AuthX.Resources.Schemas.User` register.

  For an user to be authenticate in the system it will need an credential,
  so when we create an user we also creates a `AuthX.Credentials.Schemas.Password`
  that can be used to perform actions in `AuthX.Authentication`.

  ## Exemples:
    ```elixir
    AuthX.Resources.Users.insert(%{
      first_name: "Lucas",
      last_name: "Mesquita",
      email: "lucas@gmail.com",
      password_credential: %{password: "My_passw@rd2"}
    })
    ```
  """
  @spec insert(params :: map()) :: success_response() | failed_response()
  def insert(params) when is_map(params) do
    %User{}
    |> User.changeset_insert(params)
    |> Repo.insert()
  end

  @doc """
  Creates a new `AuthX.Resources.Schemas.User` register.

  Similar to `insert/1` but returns the struct or raises if the changeset is invalid.
  """
  @spec insert!(params :: map()) :: User.t() | no_return()
  def insert!(params) when is_map(params) do
    %User{}
    |> User.changeset_insert(params)
    |> Repo.insert!()
  end

  @doc """
  Updates a `User` register.

  ## Exemples:
    ```elixir
    AuthX.Resources.Users.update(user, %{
      first_name: "Marcos",
      last_name: "Farias",
      email: "marcos@gmail.com"
    })
    ```
  """
  @spec update(user :: User.t(), params :: map()) :: success_response() | failed_response()
  def update(%User{} = user, params) when is_map(params) do
    user
    |> User.changeset_update(params)
    |> Repo.update()
  end

  @doc """
  Updates a `AuthX.Resources.Schemas.User` register.

  Similar to `update/2` but returns the struct or raises if the changeset is invalid.
  """
  @spec update!(user :: User.t(), params :: map()) :: User.t() | no_return()
  def update!(%User{} = user, params) when is_map(params) do
    user
    |> User.changeset_update(params)
    |> Repo.update!()
  end

  @doc """
  Returns a list of `AuthX.Resources.Schemas.User` by its filters

  ## Exemples:
    ```elixir
    # Getting the all list
    AuthX.Resources.Users.list()

    # Filtering the list by field
    AuthX.Resources.Users.list(name: "Lucas")
    ```
  """
  @spec list(filters :: keyword()) :: list(User.t())
  def list(filters \\ []) when is_list(filters) do
    User
    |> Ecto.Query.where([u], ^filters)
    |> Repo.all()
  end

  @doc """
  Gets a `AuthX.Resources.Schemas.User` register by its filters.

  ## Exemples:
    ```elixir
    AuthX.Resources.Users.get_by(email: "lucas@gmail.com")
    ```
  """
  @spec get_by(filters :: keyword()) :: User.t() | nil
  def get_by(filters) when is_list(filters), do: Repo.get_by(User, filters)

  @doc """
  Gets a `AuthX.Resources.Schemas.User` register by its filters.

  Similar to `get_by/1` but returns the struct or raises if the changeset is invalid.
  """
  @spec get_by!(filters :: keyword()) :: User.t() | no_return()
  def get_by!(filters) when is_list(filters), do: Repo.get_by!(User, filters)

  @doc """
  Deletes a `User` register.

  ## Exemples:
    ```elixir
    AuthX.Resources.Users.delete(user)
    ```
  """
  @spec delete(user :: User.t()) :: success_response() | failed_response()
  def delete(%User{} = user), do: Repo.delete(user)

  @doc """
  Deletes a `AuthX.Resources.Schemas.User` register.

  Similar to `delete/1` but returns the struct or raises if the changeset is invalid.
  """
  @spec delete!(user :: User.t()) :: User.t() | no_return()
  def delete!(%User{} = user), do: Repo.delete!(user)

  @doc """
  Changes a `User` status.

  ## Exemples:
    ```elixir
    AuthX.Resources.Users.status(user, true)
    ```
  """
  @spec status(user :: User.t(), status :: boolean()) :: success_response() | failed_response()
  def status(%User{} = user, status) when is_boolean(status) do
    user
    |> User.changeset_status(%{is_active: status})
    |> Repo.update()
  end

  @doc """
  Changes a `AuthX.Resources.Schemas.User` status.

  Similar to `status/1` but returns the struct or raises if the changeset is invalid.
  """
  @spec status!(user :: User.t(), status :: boolean()) :: User.t() | no_return()
  def status!(%User{} = user, status) when is_boolean(status) do
    user
    |> User.changeset_status(%{is_active: status})
    |> Repo.update!()
  end

  @doc """
  Changes an set of `AuthX.Resources.Schemas.Role` of the `AuthX.Resources.Schemas.User`.

  It will add or remove roles from the list, so you should pass
  the complete list every time you use this function.

  Roles are used in `AuthX.Authorization` requests.

  ## Exemples:
    ```elixir
    AuthX.Resources.Users.change_roles(user, roles)
    ```
  """
  @spec change_roles(user :: User.t(), roles :: list(Role.t())) ::
          success_response() | failed_response()
  def change_roles(%User{} = user, roles) when is_list(roles) do
    user
    |> Repo.preload(:roles)
    |> User.changeset_roles(roles)
    |> Repo.update()
  end

  @doc """
  Changes an set of `AuthX.Resources.Schemas.Role` of the `AuthX.Resources.Schemas.User`.

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
    AuthX.Resources.Users.preload(user, [:roles])
    ```
  """
  @spec preload(user :: User.t(), fields :: keyword()) :: User.t()
  def preload(%User{} = user, fields) when is_list(fields), do: Repo.preload(user, fields)
end
