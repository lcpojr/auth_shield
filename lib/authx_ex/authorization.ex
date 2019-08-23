defmodule AuthX.Authorization do
  @moduledoc """
  Implements a set of functions to deal with authorization requests.

  Authorization is the function of specifying access rights/privileges to resources and
  checks if an authenticated subject can or not perform some action on the system.

  We use an Role-based access control (RBAC) authorization where we give or remove
  privileges for users changing his set of roles and its defined permissions.
  """

  alias AuthX.Resources.Users

  @typedoc "Authorization possible responses"
  @type responses :: {:ok, :authorized} | {:error, :unauthorized}

  @typedoc "Authorization by role"
  @type auth_role :: %{email: String.t(), roles: list(String.t())}

  @typedoc "Authorization by permission"
  @type auth_perm :: %{email: String.t(), permissions: list(String.t())}

  @doc """
  Authorize the user by its resources.

  ## Authorizing by role
    If the user is active and has one of the given roles it will return `{:ok, :authorized}`
    otherwiese `{:error, :unauthorized}`.

    ```elixir
    AuthX.Authentication.authorize(%{
      "email": "my-email@authx.com",
      roles: ["partner"]
    })
    ```

  ## Authorizing by permissions
    If the user is active and one of his roles has the required permissions `{:ok, :authorized}`
    otherwiese `{:error, :unauthorized}`.

    ```elixir
    AuthX.Authentication.authorize(%{
      "email": "my-email@authx.com",
      permissions: ["can_read_contacts"]
    })
    ```
  """
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
      Enum.all?(role.permissions, &(&1.name in permissions))
    end)
    |> case do
      true -> {:ok, :authorized}
      false -> {:error, :unauthorized}
    end
  end
end
