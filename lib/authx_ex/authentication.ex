defmodule AuthX.Authentication do
  @moduledoc """
  """

  alias AuthX.Users

  @doc "Authenticate the user by its email and password"
  @spec authenticate(params :: map()) :: {:ok, :authenticated} | {:error, :unauthenticated}
  def authenticate(%{email: email, password: pwd}) when is_binary(email) and is_binary(pwd) do
    with {:user, user} when not is_nil(user) <- {:user, Users.get_by(email: email)},
         {:active?, true} <- {:active?, user.is_active},
         {:pass?, true} <- {:pass?, Users.check_password(user, pwd)} do
      {:ok, :authenticated}
    else
      {:user, nil} -> {:error, :unauthenticated}
      {:active?, false} -> {:error, :unauthenticated}
      {:pass?, false} -> {:error, :unauthenticated}
    end
  end
end
