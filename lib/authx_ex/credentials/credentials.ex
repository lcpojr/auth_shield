defmodule AuthX.Credentials do
  @moduledoc """
  Credentials are means to proof that an identity is valid
  in authentications.

  There are multiple types of credentials and we implements
  three of them.

    - password (An sequence of digits that only the user known's);
    - pin (An code of 4 or 6 digits that usually are only numbers);
    - totp (An time based code generated in other factor or device);

  This module provides an interaface that delegates to the specific credential functions.
  """

  alias AuthX.Credentials.{PIN, TOTP}

  # PIN credential
  defdelegate insert_pin(params), to: PIN, as: :insert
  defdelegate insert_pin!(params), to: PIN, as: :insert!

  defdelegate get_pin_by(filters), to: PIN, as: :get_by
  defdelegate get_pin_by!(filters), to: PIN, as: :get_by!

  defdelegate delete_pin(pin), to: PIN, as: :delete
  defdelegate delete_pin!(pin), to: PIN, as: :delete!

  defdelegate check_pin?(pin, pin_code), to: PIN, as: :check_pin?

  # TOTP credential
  defdelegate insert_totp(params), to: TOTP, as: :insert
  defdelegate insert_totp!(params), to: TOTP, as: :insert!

  defdelegate get_totp_by(filters), to: TOTP, as: :get_by
  defdelegate get_totp_by!(filters), to: TOTP, as: :get_by!

  defdelegate delete_totp(totp), to: TOTP, as: :delete
  defdelegate delete_totp!(totp), to: TOTP, as: :delete!

  defdelegate check_totp?(totp, totp_code), to: TOTP, as: :check_totp?
  defdelegate check_totp?(totp, totp_code, datetime), to: TOTP, as: :check_totp?
end
