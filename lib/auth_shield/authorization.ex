defmodule AuthShield.Authorization do
  @moduledoc """
  Implements a set of functions to deal with authorization requests.

  Authorization is the function of specifying access rights/privileges to resources and
  checks if an authenticated subject can or not perform some action on the system.

  We use an Role-based access control (RBAC) authorization where we give or remove
  privileges for users changing his set of roles and its defined permissions.
  """

  require Logger

  alias AuthShield.Resources
  alias AuthShield.Resources.Schemas.User

  @typedoc "Authorization possible responses"
  @type responses :: {:ok, :authorized} | {:error, :unauthorized}

  @typedoc "The type of check that will be performed on role or permission resources"
  @type check_opts :: [rule: :all | :any]

  @doc """
  Authorize an resource user by its roles.

  If the user is active and has the given role or, depending of the options, one of the roles it
  will return `{:ok, :authorized}` otherwiese `{:error, :unauthorized}`.

  ## Exemples:
    ```elixir
    # Checking if the user has all the roles passed
    AuthShield.Authorization.authorize_roles(user, ["admin"], rule: :all)

    # Checking if the user one of the roles passed
    AuthShield.Authorization.authorize_roles(user, ["admin", "root"], rule: :any)
    ```
  """
  @spec authorize_roles(user :: User.t(), roles :: list(String.t()), opts :: check_opts()) ::
          responses()
  def authorize_roles(%User{} = user, roles, opts \\ []) when is_list(roles) do
    with {:active?, true} <- {:active?, user.is_active},
         {:user, %User{} = user} <- {:user, Resources.preload_user(user, [:roles])} do
      check_user_roles(user.roles, roles, opts[:rule] || :all)
    else
      {:active?, false} ->
        Logger.info("[#{__MODULE__}] failed because user is inactive")
        {:error, :unauthorized}

      {:user, nil} ->
        Logger.info("[#{__MODULE__}] failed because user could not preload roles")
        {:error, :unauthorized}
    end
  end

  defp check_user_roles(user_roles, roles, :all) do
    if Enum.all?(user_roles, &(&1.name in roles)) do
      {:ok, :authorized}
    else
      Logger.info("[#{__MODULE__}] failed because user does not have all required roles")
      {:error, :unauthorized}
    end
  end

  defp check_user_roles(user_roles, roles, :any) do
    if Enum.any?(user_roles, &(&1.name in roles)) do
      {:ok, :authorized}
    else
      Logger.info("[#{__MODULE__}] failed because user does not have any required roles")
      {:error, :unauthorized}
    end
  end

  @doc """
  Authorize an resource user by its role permissions.

  If the user is active and one of its roles has the given permission or, depending of the options,
  one of the permissions it will return `{:ok, :authorized}` otherwiese `{:error, :unauthorized}`.

  ## Exemples:
    ```elixir
    # Checking if the user has all the roles passed
    AuthShield.Authorization.authorize_permissions(user, ["can_create_user"], rule: :all)

    # Checking if the user one of the roles passed
    AuthShield.Authorization.authorize_permissions(user, ["can_create_role", "can_create_permission"], rule: :any)
    ```
  """
  @spec authorize_permissions(
          user :: User.t(),
          permissions :: list(String.t()),
          opts :: check_opts()
        ) :: responses()
  def authorize_permissions(%User{} = user, permissions, opts \\ []) when is_list(permissions) do
    with {:active?, true} <- {:active?, user.is_active},
         {:user, %User{} = user} <- {:user, Resources.preload_user(user, roles: :permissions)} do
      check_user_permissions(user.roles, permissions, opts[:rule] || :all)
    else
      {:active?, false} ->
        Logger.info("[#{__MODULE__}] failed because user is inactive")
        {:error, :unauthorized}

      {:user, nil} ->
        Logger.info("[#{__MODULE__}] failed because user could not preload permissions")
        {:error, :unauthorized}
    end
  end

  defp check_user_permissions(user_roles, permissions, :all) do
    user_roles
    |> Enum.all?(fn role -> Enum.all?(role.permissions, &(&1.name in permissions)) end)
    |> case do
      true ->
        {:ok, :authorized}

      false ->
        Logger.info("[#{__MODULE__}] failed because user does not have all required permission")
        {:error, :unauthorized}
    end
  end

  defp check_user_permissions(user_roles, permissions, :any) do
    user_roles
    |> Enum.any?(fn role -> Enum.all?(role.permissions, &(&1.name in permissions)) end)
    |> case do
      true ->
        {:ok, :authorized}

      false ->
        Logger.info("[#{__MODULE__}] failed because user does not have any required permission")
        {:error, :unauthorized}
    end
  end
end
