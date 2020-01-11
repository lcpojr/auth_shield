defmodule AuthShield.Resources.Applications do
  @moduledoc """
  Applications are another type of identity in our architecture. It is used to
  authenticate an profile or to authorize an action given its set of
  scopes.

  This module implements an interface to deal with database transactions
  as inserts, updates, deletes, etc.
  """

  require Ecto.Query

  alias AuthShield.Repo
  alias AuthShield.Resources.Schemas.{Scope, Application}

  @behaviour AuthShield.Resources.Behaviour

  @doc """
  Creates a new `AuthShield.Resources.Schemas.Application` register.

  For an application to be authenticate in the system it will need an credential,
  so when we create an application we also creates a `AuthShield.Credentials.Schemas.PublicKey`
  that can be used to perform actions in `AuthShield.Authentication`.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Applications.insert(%{
      name: "My application",
      description: "User application service",
      public_key: %{format: "pem", key: "MY_PUBLIC_KEY"}
    })
    ```
  """
  @impl true
  def insert(params) when is_map(params) do
    %Application{}
    |> Application.changeset_insert(params)
    |> Repo.insert()
  end

  @doc """
  Creates a new `AuthShield.Resources.Schemas.Application` register.

  Similar to `insert/1` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def insert!(params) when is_map(params) do
    %Application{}
    |> Application.changeset_insert(params)
    |> Repo.insert!()
  end

  @doc """
  Updates a `AuthShield.Resources.Schemas.Application` register.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Applications.update(application, %{name: "My application", description: "Updated application"})
    ```
  """
  @impl true
  def update(%Application{} = application, params) when is_map(params) do
    application
    |> Application.changeset_update(params)
    |> Repo.update()
  end

  @doc """
  Updates a `AuthShield.Resources.Schemas.Application` register.

  Similar to `update/2` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def update!(%Application{} = application, params) when is_map(params) do
    application
    |> Application.changeset_update(params)
    |> Repo.update!()
  end

  @doc """
  Returns a list of `AuthShield.Resources.Schemas.Application` by its filters

  ## Exemples:
    ```elixir
    # Getting the all list
    AuthShield.Resources.Applications.list()

    # Filtering the list by field
    AuthShield.Resources.Applications.list(name: "My application")
    ```
  """
  @impl true
  def list(filters \\ []) when is_list(filters) do
    Application
    |> Ecto.Query.where([u], ^filters)
    |> Repo.all()
  end

  @doc """
  Gets a `AuthShield.Resources.Schemas.Application` register by its filters.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Applications.get_by(name: "My application")
    ```
  """
  @impl true
  def get_by(filters) when is_list(filters), do: Repo.get_by(Application, filters)

  @doc """
  Gets a `AuthShield.Resources.Schemas.Application` register by its filters.

  Similar to `get_by/1` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def get_by!(filters) when is_list(filters), do: Repo.get_by!(Application, filters)

  @doc """
  Deletes a `Application` register.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Applications.delete(application)
    ```
  """
  @impl true
  def delete(%Application{} = application), do: Repo.delete(application)

  @doc """
  Deletes a `AuthShield.Resources.Schemas.Application` register.

  Similar to `delete/1` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def delete!(%Application{} = application), do: Repo.delete!(application)

  @doc """
  Changes a `Application` status.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Applications.change_status(application, true)
    ```
  """
  @spec change_status(
          application :: Application.t(),
          status :: boolean()
        ) :: {:ok, Application.t()} | {:error, Ecto.Changeset.t()}
  def change_status(%Application{} = application, status) when is_boolean(status) do
    application
    |> Application.changeset_status(%{is_active: status})
    |> Repo.update()
  end

  @doc """
  Changes a `AuthShield.Resources.Schemas.Application` status.

  Similar to `change_status/1` but returns the struct or raises if the changeset is invalid.
  """
  @spec change_status!(
          application :: Application.t(),
          status :: boolean()
        ) :: Application.t() | no_return()
  def change_status!(%Application{} = application, status) when is_boolean(status) do
    application
    |> Application.changeset_status(%{is_active: status})
    |> Repo.update!()
  end

  @doc """
  Changes an set of `AuthShield.Resources.Schemas.Scope` of the `AuthShield.Resources.Schemas.Application`.

  It will add or remove scopes from the list, so you should pass
  the complete list every time you use this function.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Applications.change_scopes(application, scopes)
    ```
  """
  @spec change_scopes(
          application :: Application.t(),
          scopes :: list(Scope.t())
        ) :: {:ok, Application.t()} | {:error, Ecto.Changeset.t()}
  def change_scopes(%Application{} = application, scopes) when is_list(scopes) do
    application
    |> Repo.preload(:scopes)
    |> Application.changeset_scopes(scopes)
    |> Repo.update()
  end

  @doc """
  Changes an set of `AuthShield.Resources.Schemas.Scope` of the `AuthShield.Resources.Schemas.Application`.

  Similar to `append_role/2` but returns the struct or raises if the changeset is invalid.
  """
  @spec change_scopes!(
          application :: Application.t(),
          scopes :: list(Scope.t())
        ) :: Application.t() | no_return()
  def change_scopes!(%Application{} = application, scopes) when is_list(scopes) do
    application
    |> Repo.preload(:scopes)
    |> Application.changeset_scopes(scopes)
    |> Repo.update!()
  end

  @doc """
  Preloads the application data by the given fields.

  ## Exemples:
    ```elixir
    AuthShield.Resources.Applications.preload(application, [:scopes])
    ```
  """
  @spec preload(application :: Application.t(), fields :: keyword()) :: Application.t()
  def preload(%Application{} = application, fields) when is_list(fields),
    do: Repo.preload(application, fields)
end
