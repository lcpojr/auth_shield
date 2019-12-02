defmodule AuthShield.Authentication.LoginAttempts do
  @moduledoc """
  Every time an user try to log in its attempt is saved in order
  to check and temporary block after successive failed attempts.

  It's done to mitigate attacks and suspicios login attempts.
  """

  require Ecto.Query

  alias AuthShield.Authentication.Schemas.LoginAttempt
  alias AuthShield.Repo

  @typedoc "Transactional responses of success"
  @type success_response :: {:ok, LoginAttempt.t()}

  @typedoc "Transactional responses of failed"
  @type failed_response :: {:error, Ecto.Changeset.t()}

  @doc """
  Creates a new `AuthShield.Authentication.Schemas.LoginAttempt` register.

  ## Exemples:
    ```elixir
    AuthShield.Authentication.LoginAttempts.insert(%{
      user_id: "ecb4c67d-6380-4984-ae04-1563e885d59e",
      status: "success",
      remote_ip: "173.121.3.0",
      user_agent: "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0",
    })
    ```
  """
  @spec insert(params :: map()) :: success_response() | failed_response()
  def insert(params) when is_map(params) do
    %LoginAttempt{}
    |> LoginAttempt.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Creates a new `AuthShield.Authentication.Schemas.LoginAttempt` register.

  Similar to `insert/1` but returns the struct or raises if the changeset is invalid.
  """
  @spec insert!(params :: map()) :: LoginAttempt.t() | no_return()
  def insert!(params) when is_map(params) do
    %LoginAttempt{}
    |> LoginAttempt.changeset(params)
    |> Repo.insert!()
  end

  @doc """
  Returns a list of `AuthShield.Authentication.Schemas.LoginAttempt` by its filters

  ## Exemples:
    ```elixir
    # Getting the all list
    AuthShield.Authentication.LoginAttempts.list()

    # Filtering the list by field
    AuthShield.Authentication.LoginAttempts.list(user_id: "ecb4c67d-6380-4984-ae04-1563e885d59e")
    ```
  """
  @spec list(filters :: keyword()) :: list(LoginAttempt.t())
  def list(filters \\ []) when is_list(filters) do
    LoginAttempt
    |> Ecto.Query.where([a], ^filters)
    |> Repo.all()
  end

  @doc """
  Gets a `AuthShield.Authentication.Schemas.LoginAttempt` register by its filters.

  ## Exemples:
    ```elixir
    AuthShield.Authentication.LoginAttempts.get_by(user_id: "ecb4c67d-6380-4984-ae04-1563e885d59e")
    ```
  """
  @spec get_by(filters :: keyword()) :: LoginAttempt.t() | nil
  def get_by(filters) when is_list(filters), do: Repo.get_by(LoginAttempt, filters)

  @doc """
  Gets a `AuthShield.Authentication.Schemas.LoginAttempt` register by its filters.

  Similar to `get_by/1` but returns the struct or raises if the changeset is invalid.
  """
  @spec get_by!(filters :: keyword()) :: LoginAttempt.t() | no_return()
  def get_by!(filters) when is_list(filters), do: Repo.get_by!(LoginAttempt, filters)

  @doc """
  Returns a list of `AuthShield.Authentication.Schemas.LoginAttempt` by its user_id, status and start date.

  ## Exemples:
    ```elixir
    AuthShield.Authentication.LoginAttempts.list_failure(
      "ecb4c67d-6380-4984-ae04-1563e885d59e",
      ~N[2000-01-01 23:00:07]
    )
    ```
  """
  @spec list_failure(
          user_id :: String.t(),
          from_date :: NaiveDateTime.t()
        ) :: list(LoginAttempt.t())
  def list_failure(user_id, from_date) when is_binary(user_id) do
    LoginAttempt
    |> Ecto.Query.where(
      [a],
      a.user_id == ^user_id and a.status == "failed" and a.inserted_at >= ^from_date
    )
    |> Repo.all()
  end
end
