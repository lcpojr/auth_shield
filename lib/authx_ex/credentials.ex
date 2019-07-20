defmodule AuthX.Credentials do
  @moduledoc """
  Implements an interface to deal with credential requests.
  """

  alias AuthX.Credentials.PIN

  # PIN credential
  defdelegate insert_pin_credential(params), to: PIN, as: :insert
  defdelegate insert_pin_credential!(params), to: PIN, as: :insert!

  defdelegate get_pin_credential_by(filters), to: PIN, as: :get_by
  defdelegate get_pin_credential_by!(filters), to: PIN, as: :get_by!

  defdelegate delete_pin_credetial(model), to: PIN, as: :delete
  defdelegate delete_pin_credetial!(model), to: PIN, as: :delete!

  defdelegate check_pin_credential?(model, pin), to: PIN, as: :check_pin?
end
