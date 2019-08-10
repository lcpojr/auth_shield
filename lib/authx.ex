defmodule AuthX do
  @moduledoc """
  Elixir authentication and authorization framework
  """

  alias AuthX.Authentication
  alias AuthX.Resources.{Roles, Users}
  alias AuthX.Credentials.{PIN, TOTP}

  # Authentication
  defdelegate authenticate(params), to: Authentication

  # Resources Users
  defdelegate create_user(params), to: Users, as: :insert
  defdelegate create_user!(params), to: Users, as: :insert!

  defdelegate update_user(user, params), to: Users, as: :update
  defdelegate update_user!(user, params), to: Users, as: :update!

  defdelegate get_user_by(filters), to: Users, as: :get_by
  defdelegate get_user_by!(filters), to: Users, as: :get_by!

  defdelegate delete_user(user), to: Users, as: :delete
  defdelegate delete_user!(user), to: Users, as: :delete!

  defdelegate change_status_user(user, status), to: Users, as: :status
  defdelegate change_status_user!(user, status), to: Users, as: :status!

  defdelegate change_password_user(user, password), to: Users, as: :change_password
  defdelegate change_password_user!(user, password), to: Users, as: :change_password!

  defdelegate check_password_user?(user, password), to: Users, as: :check_password?

  # Resources Roles
  defdelegate create_role(params), to: Roles, as: :insert
  defdelegate create_role!(params), to: Roles, as: :insert!

  defdelegate update_role(user, params), to: Roles, as: :update
  defdelegate update_role!(user, params), to: Roles, as: :update!

  defdelegate get_role_by(filters), to: Roles, as: :get_by
  defdelegate get_role_by!(filters), to: Roles, as: :get_by!

  defdelegate delete_role(user), to: Roles, as: :delete
  defdelegate delete_role!(user), to: Roles, as: :delete!

  # Credentials PIN
  defdelegate create_pin(params), to: PIN, as: :insert
  defdelegate create_pin!(params), to: PIN, as: :insert!

  defdelegate get_pin_by(filters), to: PIN, as: :get_by
  defdelegate get_pin_by!(filters), to: PIN, as: :get_by!

  defdelegate delete_pin(pin), to: PIN, as: :delete
  defdelegate delete_pin!(pin), to: PIN, as: :delete!

  defdelegate check_pin?(pin, pin_code), to: PIN, as: :check_pin?

  # Credentials TOTP
  defdelegate create_totp(params), to: TOTP, as: :insert
  defdelegate create_totp!(params), to: TOTP, as: :insert!

  defdelegate get_totp_by(filters), to: TOTP, as: :get_by
  defdelegate get_totp_by!(filters), to: TOTP, as: :get_by!

  defdelegate delete_totp(totp), to: TOTP, as: :delete
  defdelegate delete_totp!(totp), to: TOTP, as: :delete!

  defdelegate check_totp?(totp, totp_code), to: TOTP, as: :check_totp?
  defdelegate check_totp?(totp, totp_code, datetime), to: TOTP, as: :check_totp?
end
