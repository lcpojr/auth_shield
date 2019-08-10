defmodule AuthX.Authentication do
  @moduledoc """
  Implements a set of functions to deal with authentication requests.
  """

  alias AuthX.Credentials.{PIN, TOTP}
  alias AuthX.Resources.Users

  @typedoc "Authentication possible responses"
  @type responses :: {:ok, :authenticated} | {:error, :unauthenticated}

  @typedoc "Authentication by password params"
  @type auth_pass :: %{email: String.t(), password: String.t()}

  @typedoc "Authentication by pin params"
  @type auth_pin :: %{email: String.t(), pin: String.t()}

  @typedoc "Authentication by totp params"
  @type auth_totp :: %{email: String.t(), totp: String.t()}

  @doc "Authenticate the user by its credentials"
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
    if Users.check_password?(user, password) do
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
