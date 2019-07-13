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

  defdelegate update_user(model, params), to: Users, as: :update
  defdelegate update_user!(model, params), to: Users, as: :update!

  defdelegate get_user_by(filters), to: Users, as: :get_by
  defdelegate get_user_by!(filters), to: Users, as: :get_by!

  defdelegate delete_user(model), to: Users, as: :delete
  defdelegate delete_user!(model), to: Users, as: :delete!

  defdelegate change_status_user(model, status), to: Users, as: :status
  defdelegate change_status_user!(model, status), to: Users, as: :status!

  defdelegate change_password_user(model, password), to: Users, as: :change_password
  defdelegate change_password_user!(model, password), to: Users, as: :change_password!

  defdelegate check_password_user?(model, password), to: Users, as: :check_password?

  # Credentials
  defdelegate create_pin_credential(params), to: Credentials, as: :insert_pin_credential
  defdelegate create_pin_credential!(params), to: Credentials, as: :insert_pin_credential!

  defdelegate get_pin_credential_by(filters), to: Credentials, as: :get_pin_credential_by
  defdelegate get_pin_credential_by!(filters), to: Credentials, as: :get_pin_credential_by!

  defdelegate delete_pin_credetial(model), to: Credentials, as: :delete_pin_credetial
  defdelegate delete_pin_credetial!(model), to: Credentials, as: :delete_pin_credetial!

  defdelegate check_pin_credential?(model, pin), to: Credentials, as: :check_pin_credential?
end
