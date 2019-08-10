defmodule AuthX.Authorization do
  @moduledoc """
  Implements a set of functions to deal with authorization requests.
  """

  alias AuthX.Resources.Users

  @typedoc "Authorization possible responses"
  @type responses :: {:ok, :authorized} | {:error, :unauthorized}

  @typedoc "Authorization by role"
  @type auth_role :: %{email: String.t(), roles: list(String.t())}

  @typedoc "Authorization by permission"
  @type auth_perm :: %{email: String.t(), permissions: list(String.t())}

  @doc "Authorize the user by its resources"
  @spec authorize(params :: auth_role() | auth_perm()) :: responses()
  def authorize(%{email: email} = params) when is_map(params) do
    with {:user, user} when not is_nil(user) <- {:user, Users.get_by(email: email)},
         {:active?, true} <- {:active?, user.is_active} do
      do_authorize(user, params)
    else
      {:user, nil} -> {:error, :unauthorized}
      {:active?, false} -> {:error, :unauthorized}
    end
  end

  defp do_authorize(user, %{roles: roles}) when is_list(roles) do
    user = Users.preload(user, [:roles])

    user.roles
    |> Enum.any?(&(&1.name in roles))
    |> case do
      true -> {:ok, :authorized}
      false -> {:error, :unauthorized}
    end
  end

  defp do_authorize(user, %{permissions: permissions}) when is_list(permissions) do
    user = Users.preload(user, roles: :permissions)

    user.roles
    |> Enum.any?(fn role ->
      Enum.any?(role.permissions, &(&1.name in permissions))
    end)
    |> case do
      true -> {:ok, :authorized}
      false -> {:error, :unauthorized}
    end
  end
end
