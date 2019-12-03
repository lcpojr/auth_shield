defmodule AuthShield.Resources do
  @moduledoc """
  Resources can be used to definy many things but in authorization and authentication
  we use it as a form to declare something we need in order to deal with identities
  and access control.

  We use an Role-based access control architecture as an approach to restricting
  system access to authorized users, so our resources contains users, roles and permissions.

  This module provides an interaface that delegates to the specific resource functions.
  """

  use Delx, otp_app: :auth_shield

  alias AuthShield.Resources.{Permissions, Roles, Users}

  # Users
  defdelegate create_user(params), to: Users, as: :insert
  defdelegate create_user!(params), to: Users, as: :insert!

  defdelegate update_user(user, params), to: Users, as: :update
  defdelegate update_user!(user, params), to: Users, as: :update!

  defdelegate list_users(params \\ []), to: Users, as: :list

  defdelegate get_user_by(filters), to: Users, as: :get_by
  defdelegate get_user_by!(filters), to: Users, as: :get_by!

  defdelegate delete_user(user), to: Users, as: :delete
  defdelegate delete_user!(user), to: Users, as: :delete!

  defdelegate change_status_user(user, status), to: Users, as: :change_status
  defdelegate change_status_user!(user, status), to: Users, as: :change_status!

  defdelegate change_locked_user(user, locked_until), to: Users, as: :change_locked
  defdelegate change_locked_user!(user, locked_until), to: Users, as: :change_locked!

  defdelegate change_roles_user(user, roles), to: Users, as: :change_roles
  defdelegate change_roles_user!(user, roles), to: Users, as: :change_roles!

  defdelegate preload_user(user, fields), to: Users, as: :preload

  # Permissions
  defdelegate create_permission(params), to: Permissions, as: :insert
  defdelegate create_permission!(params), to: Permissions, as: :insert!

  defdelegate update_permission(permission, params), to: Permissions, as: :update
  defdelegate update_permission!(permission, params), to: Permissions, as: :update!

  defdelegate list_permissions(params \\ []), to: Permissions, as: :list

  defdelegate get_permission_by(filters), to: Permissions, as: :get_by
  defdelegate get_permission_by!(filters), to: Permissions, as: :get_by!

  defdelegate delete_permission(permission), to: Permissions, as: :delete
  defdelegate delete_permission!(permission), to: Permissions, as: :delete!

  # Roles
  defdelegate create_role(params), to: Roles, as: :insert
  defdelegate create_role!(params), to: Roles, as: :insert!

  defdelegate update_role(role, params), to: Roles, as: :update
  defdelegate update_role!(role, params), to: Roles, as: :update!

  defdelegate list_roles(params \\ []), to: Roles, as: :list

  defdelegate get_role_by(filters), to: Roles, as: :get_by
  defdelegate get_role_by!(filters), to: Roles, as: :get_by!

  defdelegate delete_role(role), to: Roles, as: :delete
  defdelegate delete_role!(role), to: Roles, as: :delete!

  defdelegate change_permissions_role(role, permission), to: Roles, as: :change_permissions
  defdelegate change_permissions_role!(role, permission), to: Roles, as: :change_permissions!
end
