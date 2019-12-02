defmodule AuthShield do
  @moduledoc """
  AuthShield is an simple implementation that was created to be used
  with other frameworks (as Phoenix) or applications in order to provide
  an simple authentication and authorization management to the services.

  ## Installation

  AuthShield is published on Hex. Add `{:auth_shield, "~> 0.0.3"}` to your list of dependencies in mix.exs.

  Then run `mix deps.get` to install AuthShield and its dependencies, including Ecto, Plug and Argon2.

  After the packages are installed you must configure your database and generates an migration to add the AuthShield tables to it.

  On your `config.exs` set the configuration bellow:

  ```elixir
  # This is the default auth_shield database configuration
  # but its highly recomendate that you configure it to be in
  # the same database if you want to extend the identity to
  # your on custom tables.

  config :auth_shield, ecto_repos: [AuthShield.Repo]

  config :auth_shield, AuthShield.Repo,
    database: "authshield_dev",
    username: "postgres",
    password: "postgres",
    hostname: "localhost",
    port: 5432

  # You can set the session expiration and block attempts by changing this config
  # The default expiration is 15 minutes (in seconds)
  # The default max attempts before block is 10
  # The default block time is 30 minutes
  config :auth_shield, AuthShield,
    session_expiration: 60 * 15,
    block_attempts: 10,
    block_time: 60 * 15
  ```

  In your `test.exs` use the configuration bellow to run it in sandbox mode:

  ```elixir
  config :auth_shield, AuthShield.Repo, pool: Ecto.Adapters.SQL.Sandbox
  ```

  After you finish the configurations use `mix ecto.gen.migration create_auth_shield_tables` to generate the migration that will be use on database and tables criation.

  Go to the generated migration and call the AuthShield `up` and `down` migration functions as the exemple bellow:

  ```elixir
  defmodule AuthShield.Repo.Migrations.CreateAuthShieldTables do
    use Ecto.Migration

    def up do
      AuthShield.Migrations.up()
    end

    def down do
      AuthShield.Migrations.down()
    end
  end
  ```

  Create the database database (if its not created yet) by using `mix ecto.migrate` and
  then run the migrations with `mix ecto.migrate`.
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
    AuthShield.login(%Plug.Conn%{
      body_params: %{
        "email" => "lucas@gmail.com",
        "password" => "Mypass@rd23"
      }
    )
    ```
  """
  @spec login(conn :: Plug.Conn.t()) ::
          {:ok, Session.t()} | {:error, :unauthenticated | Ecto.Changeset.t()}
  def login(%Plug.Conn{} = conn) do
    with remote_ip when is_binary(remote_ip) <- get_remote_ip(conn),
         user_agent when is_binary(user_agent) <- get_user_agent(conn),
         params when is_map(params) <- conn.body_params do
      login(params, remote_ip: remote_ip, user_agent: user_agent)
    end
  end

  defp get_remote_ip(%Plug.Conn{} = conn) do
    conn.remote_ip
    |> :inet_parse.ntoa()
    |> to_string()
  end

  defp get_user_agent(%Plug.Conn{} = conn) do
    conn
    |> Plug.Conn.get_req_header("user-agent")
    |> hd()
  end

  @doc """
  Login the user by its password credential.

  If the user and its credential is authenticated it will return `{:ok, AuthShield.Authentication.Schemas.Session.t()}`.

  This session should be stored and used on authentication to keep users logged.

  ## Exemples:
    ```elixir
    AuthShield.login(%{"email" => "lucas@gmail.com", "password" => "Mypass@rd23"})
    ```
  """
  @spec login(params :: Login.t(), opts :: session_options()) ::
          {:ok, Session.t()} | {:error, :unauthenticated | Ecto.Changeset.t()}
  def login(params, opts \\ []) when is_map(params) and is_list(opts) do
    with {:ok, input} <- Login.validate(params),
         {:user, %User{} = user} <- {:user, Resources.get_user_by(email: input.email)},
         {:login, {:ok, :authenticated}, _user} <-
           {:login, Authentication.authenticate_password(user, input.password), user} do
      user
      |> build_session(opts)
      |> Authentication.create_session()
    else
      {:user, nil} -> {:error, :unauthenticated}
      {:login, {:error, :unauthenticated}, user} -> try_to_block_user(user)
      {:error, error} -> {:error, error}
    end
  end

  defp try_to_block_user(%User{} = user) do
    attempts = Authentication.list_failure_login_attempts(user.id, get_login_attempt_time())

    if length(attempts) >= block_attempts() do
      # Blocking user temporarily
      {:error, :unauthenticated}
    else
      {:error, :unauthenticated}
    end
  end

  defp build_session(user, opts) do
    %{
      user_id: user.id,
      remote_ip: opts[:remote_ip] || nil,
      user_agent: opts[:user_agent] || nil,
      expiration: get_session_expiration(),
      login_at: NaiveDateTime.utc_now()
    }
  end

  @doc """
  Refresh the authenticated user session by a given `session` or `session_id`

  If the user is authenticated and has an active session it will
  return `{:ok, AuthShield.Authentication.Schemas.Session.t()}`.

  This session should be stored and used on authentication to keep users logged.

  ## Exemples:
    ```elixir
    AuthShield.refresh_session(session)
    AuthShield.refresh_session("ecb4c67d-6380-4984-ae04-1563e885d59e")
    ```
  """
  @spec refresh_session(session :: Session.t() | String.t()) ::
          {:ok, Session.t()}
          | {:error, :session_expired}
          | {:error, :session_not_exist}
          | {:error, Ecto.Changeset.t()}
  def refresh_session(%Session{} = session) do
    case Sessions.is_expired?(session) do
      false -> Authentication.update_session(session, %{expiration: get_session_expiration()})
      true -> {:error, :session_expired}
    end
  end

  def refresh_session(session_id) when is_binary(session_id) do
    case Authentication.get_session_by(id: session_id) do
      %Session{} = session -> refresh_session(session)
      nil -> {:error, :session_not_found}
    end
  end

  @doc """
  Logout the authenticated user session by a given `session` or `session_id`.

  If the user is authenticated and has an active session it will
  return `{:ok, AuthShield.Authentication.Schemas.Session.t()}`.

  This session can be ignored because use is not active anymore.

  ## Exemples:
    ```elixir
    AuthShield.logout("ecb4c67d-6380-4984-ae04-1563e885d59e")
    ```
  """
  @spec logout(session :: Session.t() | String.t()) ::
          {:ok, Session.t()}
          | {:error, :session_not_exist}
          | {:error, Ecto.Changeset.t()}
  def logout(%Session{} = session) do
    case Sessions.is_expired?(session) do
      false -> Authentication.update_session(session, %{logout_at: NaiveDateTime.utc_now()})
      true -> {:error, :session_expired}
    end
  end

  def logout(session_id) when is_binary(session_id) do
    case Authentication.get_session_by(id: session_id) do
      %Session{} = session -> logout(session)
      nil -> {:error, :session_not_found}
    end
  end

  # Default timestamps
  defp get_session_expiration,
    do: NaiveDateTime.add(NaiveDateTime.utc_now(), session_expiration(), :second)

  defp get_block_time,
    do: NaiveDateTime.add(NaiveDateTime.utc_now(), block_time(), :second)

  defp get_login_attempt_time,
    do: NaiveDateTime.add(NaiveDateTime.utc_now(), -block_time(), :second)

  # Configs
  defp block_time, do: config() |> Keyword.get(:block_time)
  defp block_attempts, do: config() |> Keyword.get(:block_attempts)
  defp session_expiration, do: config() |> Keyword.get(:session_expiration)
  defp config, do: Application.get_env(:auth_shield, AuthShield)
end
