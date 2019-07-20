defmodule AuthX.Authentication do
  @moduledoc """
  """

  alias AuthX.{Credentials, Users}

  @typedoc "Authentication possible responses"
  @type possible_responses :: {:ok, :authenticated} | {:error, :unauthenticated}

  @doc "Authenticate the user by its email and password"
  @spec authenticate(%{email: email :: String.t(), password: password :: String.t()}) ::
          possible_responses()
  def authenticate(%{email: email, password: pwd}) when is_binary(email) and is_binary(pwd) do
    with {:user, user} when not is_nil(user) <- {:user, Users.get_by(email: email)},
         {:active?, true} <- {:active?, user.is_active},
         {:pass?, true} <- {:pass?, Users.check_password?(user, pwd)} do
      {:ok, :authenticated}
    else
      {:user, nil} -> {:error, :unauthenticated}
      {:active?, false} -> {:error, :unauthenticated}
      {:pass?, false} -> {:error, :unauthenticated}
    end
  end

  @doc "Authenticate the user by its email and pin credential"
  @spec authenticate(%{email: email :: String.t(), pin: pin :: String.t()}) ::
          possible_responses()
  def authenticate(%{email: email, pin: code}) when is_binary(email) and is_binary(code) do
    with {:user, user} when not is_nil(user) <- {:user, Users.get_by(email: email)},
         {:active?, true} <- {:active?, user.is_active},
         {:pin, pin} when not is_nil(pin) <- {:pin, Credentials.get_pin_by(user_id: user.id)},
         {:pass?, true} <- {:pass?, Credentials.check_pin?(pin, code)} do
      {:ok, :authenticated}
    else
      {:user, nil} -> {:error, :unauthenticated}
      {:active?, false} -> {:error, :unauthenticated}
      {:pin, nil} -> {:error, :unauthenticated}
      {:pass?, false} -> {:error, :unauthenticated}
    end
  end
end
