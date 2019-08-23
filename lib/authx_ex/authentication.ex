defmodule AuthX.Authentication do
  @moduledoc """
  Implements a set of functions to deal with authentication requests.

  Authentication is the process of determining whether someone or something is,
  in fact, who or what it declares itself to be, in other word it's the action
  of check if the user's credentials match the credentials in a database of
  authorized users or in a data authentication server.
  """

  alias AuthX.Credentials.{Passwords, PIN, TOTP}
  alias AuthX.Resources.Users

  @typedoc "Authentication possible responses"
  @type responses :: {:ok, :authenticated} | {:error, :unauthenticated}

  @typedoc "Authentication by password params"
  @type auth_pass :: %{email: String.t(), password: String.t()}

  @typedoc "Authentication by pin params"
  @type auth_pin :: %{email: String.t(), pin: String.t()}

  @typedoc "Authentication by totp params"
  @type auth_totp :: %{email: String.t(), totp: String.t()}

  @doc """
  Authenticate the user by its credentials.

  ## Authenticating by Password:
    If the user is active and the password credentials are right it will return `{:ok, :authenticated}`
    otherwiese `{:error, :unauthorized}`.

    If you need to know more about how we deal with passwords check `AuthX.Credentials.Passwords`.

    ```elixir
    AuthX.Authentication.authenticate(%{
      email: "my-email@authx.com",
      password: "My_passw@rd2"
    })
    ```

  ## Authenticating by PIN:
  If the user is active and the pin credentials are right it will return `{:ok, :authenticated}`
  otherwiese `{:error, :unauthorized}`.

  If you need to know more about how we deal with pin check `AuthX.Credentials.PIN`.

  ```elixir
  AuthX.Authentication.authenticate(%{
    email: "my-email@authx.com",
    pin: "332145"
  })
  ```

  ## Authenticating by TOTP:
  If the user is active and the totp credentials are right it will return `{:ok, :authenticated}`
  otherwiese `{:error, :unauthorized}`.

  If you need to know more about how we deal with pin check `AuthX.Credentials.TOTP`.

  ```elixir
  AuthX.Authentication.authenticate(%{
    email: "my-email@authx.com",
    totp: "103245"
  })
  ```
  """
  @spec authenticate(params :: auth_pass() | auth_pin() | auth_totp()) :: responses()
  def authenticate(%{email: email} = params) when is_map(params) do
    with {:user, user} when not is_nil(user) <- {:user, Users.get_by(email: email)},
         {:active?, true} <- {:active?, user.is_active} do
      do_authenticate(user, params)
    else
      {:user, nil} -> {:error, :unauthenticated}
      {:active?, false} -> {:error, :unauthenticated}
    end
  end

  defp do_authenticate(user, %{password: password}) when is_binary(password) do
    pass = Passwords.get_by(user_id: user.id)

    if Passwords.check_password?(pass, password) do
      {:ok, :authenticated}
    else
      {:error, :unauthenticated}
    end
  end

  defp do_authenticate(user, %{pin: code}) when is_binary(code) do
    pin = PIN.get_by(user_id: user.id)

    if PIN.check_pin?(pin, code) do
      {:ok, :authenticated}
    else
      {:error, :unauthenticated}
    end
  end

  defp do_authenticate(user, %{totp: code}) when is_binary(code) do
    pin = TOTP.get_by(user_id: user.id)

    if TOTP.check_totp?(pin, code) do
      {:ok, :authenticated}
    else
      {:error, :unauthenticated}
    end
  end
end
