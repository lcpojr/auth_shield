defmodule AuthShield do
  @moduledoc """
  Elixir authentication and authorization framework
  """

  alias AuthShield.Authentication
  alias AuthShield.Authentication.Schemas.Session
  alias AuthShield.Authentication.Sessions
  alias AuthShield.Resources
  alias AuthShield.Resources.Schemas.User
  alias AuthShield.Validations.{Login, SignUp}

  @typedoc "Session options used on authentication plug"
  @type session_options :: [user_agent: String.t(), remote_ip: String.t()]

  @doc """
  Creates a new user on the system.

  ## Exemples:
    ```elixir
    AuthShield.signup(%{
      first_name: "Lucas",
      last_name: "Mesquita",
      email: "lucas@gmail.com",
      password: "My_passw@rd2"
    })
    ```
  """
  @spec signup(params :: SignUp.t()) ::
          {:ok, User.t()}
          | {:error, map()}
          | {:error, Ecto.Changeset.t()}
  def signup(params) when is_map(params) do
    with {:ok, input} <- SignUp.validate(params) do
      Resources.create_user(input)
    end
  end

  @doc """
  Login the user by its password credential.

  If the user and its credential is authenticated it will return `{:ok, AuthShield.Authentication.Schemas.Session.t()}`.

  This session should be stored and used on authentication to keep users logged.

  ## Exemples:
    ```elixir
    AuthShield.login(
      %{"email" => "lucas@gmail.com", "password" => "Mypass@rd23"},
      remote_ip: "172.31.4.1",
      user_agent: "Mozilla/5.0 (Windows NT x.y; rv:10.0) Gecko/20100101 Firefox/10.0"
    )
    ```
  """
  @spec login(params :: Login.t(), opts :: session_options()) ::
          {:ok, Session.t()}
          | {:error, :user_not_found}
          | {:error, :unauthenticated}
          | {:error, Ecto.Changeset.t()}
  def login(params, opts \\ []) when is_map(params) and is_list(opts) do
    with {:ok, input} <- Login.validate(params),
         {:user, %User{} = user} <- {:user, Resources.get_user_by(email: input.email)},
         {:ok, :authenticated} <- Authentication.authenticate_password(user, input.password) do
      user
      |> build_session(opts)
      |> Authentication.create_session()
    else
      {:user, nil} -> {:error, :user_not_found}
      {:error, :unauthenticated} -> {:error, :unauthenticated}
      {:error, error} -> {:error, error}
    end
  end

  defp build_session(user, opts) do
    %{
      user_id: user.id,
      remote_ip: opts[:remote_ip] || nil,
      user_agent: opts[:user_agent] || nil,
      expiration: get_default_expiration(),
      login_at: NaiveDateTime.utc_now()
    }
  end

  @doc """
  Refresh the authenticated user session.

  If the user is authenticated and has an active session it will
  return `{:ok, AuthShield.Authentication.Schemas.Session.t()}`.

  This session should be stored and used on authentication to keep users logged.

  ## Exemples:
    ```elixir
    AuthShield.refresh_session("ecb4c67d-6380-4984-ae04-1563e885d59e")
    ```
  """
  @spec refresh_session(session_id :: String.t() | Session.t()) ::
          {:ok, Session.t()}
          | {:error, :session_expired}
          | {:error, :session_not_exist}
          | {:error, Ecto.Changeset.t()}
  def refresh_session(session_id) when is_binary(session_id) do
    case Authentication.get_session_by(id: session_id) do
      %Session{} = session -> refresh_session(session)
      nil -> {:error, :session_not_found}
    end
  end

  def refresh_session(%Session{} = session) do
    case Sessions.is_expired?(session) do
      false -> Authentication.update_session(session, %{expiration: get_default_expiration()})
      true -> {:error, :session_expired}
    end
  end

  @doc """
  Logout the authenticated user session.

  If the user is authenticated and has an active session it will
  return `{:ok, AuthShield.Authentication.Schemas.Session.t()}`.

  This session can be ignored because use is not active anymore.

  ## Exemples:
    ```elixir
    AuthShield.logout("ecb4c67d-6380-4984-ae04-1563e885d59e")
    ```
  """
  @spec logout(session_id :: String.t() | Session.t()) ::
          {:ok, Session.t()}
          | {:error, :session_not_exist}
          | {:error, Ecto.Changeset.t()}
  def logout(session_id) when is_binary(session_id) do
    case Authentication.get_session_by(id: session_id) do
      %Session{} = session -> logout(session)
      nil -> {:error, :session_not_found}
    end
  end

  def logout(%Session{} = session) do
    case Sessions.is_expired?(session) do
      false -> Authentication.update_session(session, %{logout_at: NaiveDateTime.utc_now()})
      true -> {:error, :session_expired}
    end
  end

  defp get_default_expiration do
    expiration =
      :auth_shield
      |> Application.get_env(AuthShield)
      |> Keyword.get(:session_expiration)

    NaiveDateTime.utc_now()
    |> NaiveDateTime.add(expiration, :second)
  end
end
