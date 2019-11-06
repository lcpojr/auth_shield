defmodule AuthShield.Authentication.Sessions do
  @moduledoc """
  Session is a temporary authentication information that is stored on server in order
  to keep the user logged in.
  """

  require Ecto.Query

  alias AuthShield.Authentication.Schemas.Session
  alias AuthShield.Repo

  @typedoc "Transactional responses of success"
  @type success_response :: {:ok, Session.t()}

  @typedoc "Transactional responses of failed"
  @type failed_response :: {:error, Ecto.Changeset.t()}

  @doc """
  Creates a new `AuthShield.Authentication.Schemas.Session` register.

  ## Exemples:
    ```elixir
    AuthShield.Authentication.Sessions.insert(%{
      user_id: "ecb4c67d-6380-4984-ae04-1563e885d59e",
      remote_ip: "173.121.3.0",
      user_agent: "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0",
      expiration: ~U[2019-08-23 23:06:50.424629Z]
    })
    ```
  """
  @spec insert(params :: map()) :: success_response() | failed_response()
  def insert(params) when is_map(params) do
    %Session{}
    |> Session.insert_changeset(params)
    |> Repo.insert()
  end

  @doc """
  Creates a new `AuthShield.Authentication.Schemas.Session` register.

  Similar to `insert/1` but returns the struct or raises if the changeset is invalid.
  """
  @spec insert!(params :: map()) :: Session.t() | no_return()
  def insert!(params) when is_map(params) do
    %Session{}
    |> Session.insert_changeset(params)
    |> Repo.insert!()
  end

  @doc """
  Updates a `AuthShield.Authentication.Schemas.Session` register.

  ## Exemples:
    ```elixir
    AuthShield.Authentication.Sessions.update(session, %{expiration: ~U[2019-08-30 23:06:50.424629Z]})
    ```
  """
  @spec update(session :: Session.t(), params :: map()) :: success_response() | failed_response()
  def update(%Session{} = session, params) when is_map(params) do
    session
    |> Session.update_changeset(params)
    |> Repo.update()
  end

  @doc """
  Updates a `AuthShield.Authentication.Schemas.Session` register.

  Similar to `update/2` but returns the struct or raises if the changeset is invalid.
  """
  @spec update!(password :: Session.t(), params :: map()) :: Session.t() | no_return()
  def update!(%Session{} = password, params) when is_map(params) do
    password
    |> Session.update_changeset(params)
    |> Repo.update!()
  end

  @doc """
  Returns a list of `AuthShield.Authentication.Schemas.Session` by its filters

  ## Exemples:
    ```elixir
    # Getting the all list
    AuthShield.Authentication.Sessions.list()

    # Filtering the list by field
    AuthShield.Authentication.Sessions.list(user_id: "ecb4c67d-6380-4984-ae04-1563e885d59e")
    ```
  """
  @spec list(filters :: keyword()) :: list(Session.t())
  def list(filters \\ []) when is_list(filters) do
    Session
    |> Ecto.Query.where([p], ^filters)
    |> Repo.all()
  end

  @doc """
  Gets a `AuthShield.Authentication.Schemas.Session` register by its filters.

  ## Exemples:
    ```elixir
    AuthShield.Authentication.Sessions.get_by(user_id: "ecb4c67d-6380-4984-ae04-1563e885d59e")
    ```
  """
  @spec get_by(filters :: keyword()) :: Session.t() | nil
  def get_by(filters) when is_list(filters), do: Repo.get_by(Session, filters)

  @doc """
  Gets a `AuthShield.Authentication.Schemas.Session` register by its filters.

  Similar to `get_by/1` but returns the struct or raises if the changeset is invalid.
  """
  @spec get_by!(filters :: keyword()) :: Session.t() | no_return()
  def get_by!(filters) when is_list(filters), do: Repo.get_by!(Session, filters)

  @doc "Checks if the give `AuthShield.Authentication.Schemas.Session` is expired"
  @spec is_expired?(session :: Session.t()) :: boolean()
  def is_expired?(session) do
    case NaiveDateTime.compare(session.expiration, NaiveDateTime.utc_now()) do
      :gt -> false
      :lt -> true
      :eq -> true
    end
  end
end
