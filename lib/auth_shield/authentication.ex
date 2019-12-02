defmodule AuthShield.Authentication do
  @moduledoc """
  Implements a set of functions to deal with authentication requests.

  Authentication is the process of determining whether someone or something is,
  in fact, who or what it declares itself to be, in other word it's the action
  of check if the user's credentials match the credentials in a database of
  authorized users or in a data authentication server.
  """

  use Delx, otp_app: :auth_shield

  require Logger

  alias AuthShield.Authentication.{LoginAttempts, Sessions}
  alias AuthShield.Credentials
  alias AuthShield.Credentials.Schemas.{Password, PIN, TOTP}
  alias AuthShield.Resources.Schemas.User

  @typedoc "Authentication possible responses"
  @type responses :: {:ok, :authenticated} | {:error, :unauthenticated}

  # Session
  defdelegate create_session(params), to: Sessions, as: :insert
  defdelegate create_session!(params), to: Sessions, as: :insert!

  defdelegate update_session(session, params), to: Sessions, as: :update
  defdelegate update_session!(session, params), to: Sessions, as: :update!

  defdelegate list_session(filters), to: Sessions, as: :list

  defdelegate get_session_by(params), to: Sessions, as: :get_by
  defdelegate get_session_by!(params), to: Sessions, as: :get_by!

  # Login Attempts
  defdelegate create_login_attempt(params), to: LoginAttempts, as: :insert
  defdelegate create_login_attempt!(params), to: LoginAttempts, as: :insert!

  defdelegate list_login_attempt(filters), to: LoginAttempts, as: :list

  defdelegate get_login_attempt_by(params), to: LoginAttempts, as: :get_by
  defdelegate get_login_attempt_by!(params), to: LoginAttempts, as: :get_by!

  @doc """
  Gets an user password and calls `AuthShield.Authentication.authenticate_password/3`
  to authenticates user given a password code.

  ## Exemples:
    ```elixir
    AuthShield.Authentication.authenticate_password(user, "Mypass@rd23")
    ```
  """
  @spec authenticate_password(user :: User.t(), pass_code :: String.t()) :: responses()
  def authenticate_password(%User{} = user, pass_code) when is_binary(pass_code) do
    [user_id: user.id]
    |> Credentials.get_password_by()
    |> case do
      nil ->
        Logger.info("[#{__MODULE__}] failed because Password credential was not found.")
        {:error, :unauthenticated}

      %Password{} = password ->
        authenticate_password(user, password, pass_code)
    end
  end

  @doc """
  Authenticates the user by password credential.

  If the user is active and the password credentials are right it
  will return `{:ok, :authenticated}` otherwiese `{:error, :unauthorized}`.

  ## Exemples:
    ```elixir
    AuthShield.Authentication.authenticate_password(user, password, "Mypass@rd23")
    ```
  """
  @spec authenticate_password(
          user :: User.t(),
          password :: Password.t(),
          code :: String.t()
        ) :: responses()
  def authenticate_password(%User{} = user, %Password{} = pass, code) when is_binary(code) do
    with {:active?, true} <- {:active?, user.is_active},
         {:locked?, false} <- {:locked?, not is_nil(user.locked_until)},
         {:pass?, true} <- {:pass?, Credentials.check_password?(pass, code)} do
      {:ok, :authenticated}
    else
      {:active?, false} ->
        Logger.info("[#{__MODULE__}] failed because user is inactive")
        {:error, :unauthenticated}

      {:locked?, true} ->
        Logger.info("[#{__MODULE__}] failed because user is locked")
        {:error, :unauthenticated}

      {:pass?, false} ->
        Logger.info("[#{__MODULE__}] failed because Password was wrong")
        {:error, :unauthenticated}
    end
  end

  @doc """
  Gets an user pin and calls `AuthShield.Authentication.authenticate_pin/3`
  to authenticates user given a pin code.

  ## Exemples:
    ```elixir
    AuthShield.Authentication.authenticate_pin(user, "332145")
    ```
  """
  @spec authenticate_pin(user :: User.t(), pin_code :: String.t()) :: responses()
  def authenticate_pin(%User{} = user, pin_code) when is_binary(pin_code) do
    [user_id: user.id]
    |> Credentials.get_pin_by()
    |> case do
      nil ->
        Logger.info("[#{__MODULE__}] failed because PIN credential was not found")
        {:error, :unauthenticated}

      %PIN{} = pin ->
        authenticate_pin(user, pin, pin_code)
    end
  end

  @doc """
  Authenticates the user by PIN credential.

  If the user is active and the password credentials are right it
  will return `{:ok, :authenticated}` otherwiese `{:error, :unauthorized}`.

  ## Exemples:
    ```elixir
    AuthShield.Authentication.authenticate_pin(user, "332145")
    ```
  """
  @spec authenticate_pin(user :: User.t(), pin :: PIN.t(), pin_code :: String.t()) :: responses()
  def authenticate_pin(%User{} = user, %PIN{} = pin, code) when is_binary(code) do
    with {:active?, true} <- {:active?, user.is_active},
         {:locked?, false} <- {:locked?, not is_nil(user.locked_until)},
         {:pass?, true} <- {:pass?, Credentials.check_pin?(pin, code)} do
      {:ok, :authenticated}
    else
      {:active?, false} ->
        Logger.info("[#{__MODULE__}] failed because user is inactive")
        {:error, :unauthenticated}

      {:locked?, true} ->
        Logger.info("[#{__MODULE__}] failed because user is locked")
        {:error, :unauthenticated}

      {:pass?, false} ->
        Logger.info("[#{__MODULE__}] failed because PIN was wrong")
        {:error, :unauthenticated}
    end
  end

  @doc """
  Gets an user totp and calls `AuthShield.Authentication.authenticate_totp/3`
  to authenticates user given a totp code.

  ## Exemples:
    ```elixir
    AuthShield.Authentication.authenticate_totp(user, "332145")
    ```
  """
  @spec authenticate_totp(user :: User.t(), totp_code :: String.t()) :: responses()
  def authenticate_totp(%User{} = user, totp_code) when is_binary(totp_code) do
    [user_id: user.id]
    |> Credentials.get_totp_by()
    |> case do
      nil ->
        Logger.info("[#{__MODULE__}] failed because TOTP credential was not found")
        {:error, :unauthenticated}

      %TOTP{} = totp ->
        authenticate_totp(user, totp, totp_code)
    end
  end

  @doc """
  Authenticates the user by TOTP credential.

  If the user is active and the password credentials are right it
  will return `{:ok, :authenticated}` otherwiese `{:error, :unauthorized}`.

  ## Exemples:
    ```elixir
    AuthShield.Authentication.authenticate_totp(user, "332145")
    ```
  """
  @spec authenticate_totp(user :: User.t(), totp :: TOTP.t(), code :: String.t()) :: responses()
  def authenticate_totp(%User{} = user, %TOTP{} = totp, code) when is_binary(code) do
    with {:active?, true} <- {:active?, user.is_active},
         {:locked?, false} <- {:locked?, not is_nil(user.locked_until)},
         {:pass?, true} <- {:pass?, Credentials.check_totp?(totp, code)} do
      {:ok, :authenticated}
    else
      {:active?, false} ->
        Logger.info("[#{__MODULE__}] failed because user is inactive")
        {:error, :unauthenticated}

      {:locked?, true} ->
        Logger.info("[#{__MODULE__}] failed because user is locked")
        {:error, :unauthenticated}

      {:pass?, false} ->
        Logger.info("[#{__MODULE__}] failed because TOTP was wrong")
        {:error, :unauthenticated}
    end
  end
end
