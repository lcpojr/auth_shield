defmodule AuthX do
  @moduledoc """
  Elixir authentication and authorization framework
  """

  alias AuthX.Authentication
  alias AuthX.Authentication.Schemas.Session
  alias AuthX.Resources
  alias AuthX.Resources.Schemas.User
  alias AuthX.Validations.{Login, SignUp}

  @doc """
  Creates a new user on the system.

  ## Exemples:
    ```elixir
    AuthX.signup(%{
      first_name: "Lucas",
      last_name: "Mesquita",
      email: "lucas@gmail.com",
      password: "My_passw@rd2"}
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

  If the user and its credential is authenticated it will return `{:ok, AuthX.Authentication.Schemas.Session.t()}`.

  This session should be stored and used on authentication to keep users logged.

  ## Exemples:
    ```elixir
    AuthX.login(
      "lucas@gmail.com",
      "Mypass@rd23",
      ip_address: "172.31.4.1",
      user_agent: "Mozilla/5.0 (Windows NT x.y; rv:10.0) Gecko/20100101 Firefox/10.0"
    )
    ```
  """
  @spec login(params :: Login.t(), opts :: keyword()) ::
          {:ok, Session.t()}
          | {:error, :user_not_found}
          | {:error, :unauthenticated}
          | {:error, Ecto.Changeset.t()}
          | {:error, map()}
  def login(params, opts \\ []) when is_map(params) do
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
      ip_address: opts[:ip_address],
      user_agent: opts[:user_agent],
      expiration: get_default_expiration(),
      login_at: Timex.now()
    }
  end

  @doc """
  Refresh the authenticated user session.

  If the user is authenticated and has an active session it will
  return `{:ok, AuthX.Authentication.Schemas.Session.t()}`.

  This session should be stored and used on authentication to keep users logged.

  ## Exemples:
    ```elixir
    AuthX.refresh_session("ecb4c67d-6380-4984-ae04-1563e885d59e")
    ```
  """
  @spec refresh_session(session_id :: String.t()) ::
          {:ok, Session.t()}
          | {:error, :session_expired}
          | {:error, :session_not_exist}
          | {:error, Ecto.Changeset.t()}
  def refresh_session(session_id) when is_binary(session_id) do
    with {:sess, %Session{} = session} <- {:sess, Authentication.get_session_by(id: session_id)},
         {:expired?, true} <- {:expired?, Timex.after?(session.expiration, Timex.now())} do
      Authentication.update_session(session, %{expiration: get_default_expiration()})
    else
      {:sess, nil} -> {:error, :session_not_found}
      {:expired?, false} -> {:error, :session_expired}
    end
  end

  @doc """
  Logout the authenticated user session.

  If the user is authenticated and has an active session it will
  return `{:ok, AuthX.Authentication.Schemas.Session.t()}`.

  This session can be ignored because use is not active anymore.

  ## Exemples:
    ```elixir
    AuthX.logout("ecb4c67d-6380-4984-ae04-1563e885d59e")
    ```
  """
  @spec logout(session_id :: String.t()) ::
          {:ok, Session.t()}
          | {:error, :session_not_exist}
          | {:error, Ecto.Changeset.t()}
  def logout(session_id) when is_binary(session_id) do
    with {:sess, %Session{} = session} <- {:sess, Authentication.get_session_by(id: session_id)},
         {:expired?, true} <- {:expired?, Timex.after?(session.expiration, Timex.now())} do
      Authentication.update_session(session, %{logout_at: Timex.now()})
    else
      {:sess, nil} -> {:error, :session_not_found}
      {:expired?, false} -> {:error, :session_expired}
    end
  end

  defp get_default_expiration do
    Timex.now() |> Timex.add(Timex.Duration.from_minutes(15))
  end
end
