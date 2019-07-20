defmodule AuthX do
  @moduledoc """
  Elixir authentication and authorization framework
  """

  alias AuthX.Authentication
  alias AuthX.{Credentials, Users}

  # Authentication
  defdelegate authenticate(params), to: Authentication

  # User
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

  # Credentials
  defdelegate create_pin(params), to: Credentials, as: :insert_pin
  defdelegate create_pin!(params), to: Credentials, as: :insert_pin!

  defdelegate get_pin_by(filters), to: Credentials, as: :get_pin_by
  defdelegate get_pin_by!(filters), to: Credentials, as: :get_pin_by!

  defdelegate delete_pin(pin), to: Credentials, as: :delete_pin
  defdelegate delete_pin!(pin), to: Credentials, as: :delete_pin!

  defdelegate check_pin?(pin, pin_code), to: Credentials, as: :check_pin?

  defdelegate create_totp(params), to: Credentials, as: :insert_totp
  defdelegate create_totp!(params), to: Credentials, as: :insert_totp!

  defdelegate get_totp_by(filters), to: Credentials, as: :get_totp_by
  defdelegate get_totp_by!(filters), to: Credentials, as: :get_totp_by!

  defdelegate delete_totp(totp), to: Credentials, as: :delete_totp
  defdelegate delete_totp!(totp), to: Credentials, as: :delete_totp!

  defdelegate check_totp?(totp, totp_code), to: Credentials, as: :check_totp?
  defdelegate check_totp?(totp, totp_code, datetime), to: Credentials, as: :check_totp?
end
