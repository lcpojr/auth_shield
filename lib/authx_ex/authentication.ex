defmodule AuthX.Authentication do
  @moduledoc """
  Implements a set of functions to deal with authentication requests.

  Authentication is the process of determining whether someone or something is,
  in fact, who or what it declares itself to be, in other word it's the action
  of check if the user's credentials match the credentials in a database of
  authorized users or in a data authentication server.
  """

  alias AuthX.Authentication.Sessions
  alias AuthX.Credentials
  alias AuthX.Credentials.Schemas.{Password, PIN, TOTP}
  alias AuthX.Resources.Schemas.User

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

  @doc """
  Authenticates the user by password credential.

  If the user is active and the password credentials are right it
  will return `{:ok, :authenticated}` otherwiese `{:error, :unauthorized}`.

  ## Exemples:
    ```elixir
    AuthX.Authentication.authenticate_password(user, "Mypass@rd23")
    ```
  """
  @spec authenticate_password(user :: User.t(), pass_code :: String.t()) :: responses()
  def authenticate_password(%User{} = user, pass_code) when is_binary(pass_code) do
    with {:active?, true} <- {:active?, user.is_active},
         {:cred, %Password{} = pass} <- {:cred, Credentials.get_password_by(user_id: user.id)},
         {:pass?, true} <- {:pass?, Credentials.check_password?(pass, pass_code)} do
      {:ok, :authenticated}
    else
      {:active?, false} -> {:error, :unauthenticated}
      {:cred, nil} -> {:error, :unauthenticated}
      {:pass?, false} -> {:error, :unauthenticated}
    end
  end

  @doc """
  Authenticates the user by PIN credential.

  If the user is active and the password credentials are right it
  will return `{:ok, :authenticated}` otherwiese `{:error, :unauthorized}`.

  ## Exemples:
    ```elixir
    AuthX.Authentication.authenticate_pin(user, "332145")
    ```
  """
  @spec authenticate_pin(user :: User.t(), pin_code :: String.t()) :: responses()
  def authenticate_pin(%User{} = user, pin_code) when is_binary(pin_code) do
    with {:active?, true} <- {:active?, user.is_active},
         {:cred, %PIN{} = pin} <- {:cred, Credentials.get_pin_by(user_id: user.id)},
         {:pass?, true} <- {:pass?, Credentials.check_pin?(pin, pin_code)} do
      {:ok, :authenticated}
    else
      {:active?, false} -> {:error, :unauthenticated}
      {:cred, nil} -> {:error, :unauthenticated}
      {:pass?, false} -> {:error, :unauthenticated}
    end
  end

  @doc """
  Authenticates the user by TOTP credential.

  If the user is active and the password credentials are right it
  will return `{:ok, :authenticated}` otherwiese `{:error, :unauthorized}`.

  ## Exemples:
    ```elixir
    AuthX.Authentication.authenticate_totp(user, "332145")
    ```
  """
  @spec authenticate_totp(user :: User.t(), totp_code :: String.t()) :: responses()
  def authenticate_totp(%User{} = user, totp_code) when is_binary(totp_code) do
    with {:active?, true} <- {:active?, user.is_active},
         {:cred, %TOTP{} = totp} <- {:cred, Credentials.get_totp_by(user_id: user.id)},
         {:pass?, true} <- {:pass?, Credentials.check_totp?(totp, totp_code)} do
      {:ok, :authenticated}
    else
      {:active?, false} -> {:error, :unauthenticated}
      {:cred, nil} -> {:error, :unauthenticated}
      {:pass?, false} -> {:error, :unauthenticated}
    end
  end
end
