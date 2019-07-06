defmodule AuthX do
  @moduledoc """
  Elixir authentication and authorization framework
  """

  alias AuthX.Authentication
  alias AuthX.Users

  defdelegate authenticate(params), to: Authentication

  defdelegate create_user(params), to: Users, as: :insert
  defdelegate create_user!(params), to: Users, as: :insert!

  defdelegate update_user(model, params), to: Users, as: :update
  defdelegate update_user!(model, params), to: Users, as: :update!

  defdelegate get_user_by(filters), to: Users, as: :get_by
  defdelegate get_user_by!(filters), to: Users, as: :get_by!

  defdelegate delete_user(params), to: Users, as: :delete
  defdelegate delete_user!(params), to: Users, as: :delete!

  defdelegate change_status_user(model, status), to: Users, as: :status
  defdelegate change_status_user!(model, status), to: Users, as: :status!

  defdelegate change_password_user(model, password), to: Users, as: :change_password
  defdelegate change_password_user!(model, password), to: Users, as: :change_password!

  defdelegate check_password_user?(model, password), to: Users, as: :check_password?
  defdelegate check_password_user?(model, password), to: Users, as: :check_password?
end
