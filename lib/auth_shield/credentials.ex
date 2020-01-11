defmodule AuthShield.Credentials do
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

  use Delx, otp_app: :auth_shield

  alias AuthShield.Credentials.{Passwords, PIN, PublicKey, TOTP}

  # Password
  defdelegate create_password(params), to: Passwords, as: :insert
  defdelegate create_password!(params), to: Passwords, as: :insert!

  defdelegate update_password(password, pass_code), to: Passwords, as: :update
  defdelegate update_password!(password, pass_code), to: Passwords, as: :update!

  defdelegate list_password(filters \\ []), to: Passwords, as: :list

  defdelegate get_password_by(filters), to: Passwords, as: :get_by
  defdelegate get_password_by!(filters), to: Passwords, as: :get_by!

  defdelegate delete_password(password), to: Passwords, as: :delete
  defdelegate delete_password!(password), to: Passwords, as: :delete!

  defdelegate check_password?(password, pass_code), to: Passwords, as: :check_password?

  # PIN
  defdelegate create_pin(params), to: PIN, as: :insert
  defdelegate create_pin!(params), to: PIN, as: :insert!

  defdelegate list_pin(filters \\ []), to: PIN, as: :list

  defdelegate get_pin_by(filters), to: PIN, as: :get_by
  defdelegate get_pin_by!(filters), to: PIN, as: :get_by!

  defdelegate delete_pin(pin), to: PIN, as: :delete
  defdelegate delete_pin!(pin), to: PIN, as: :delete!

  defdelegate check_pin?(pin, pin_code), to: PIN, as: :check_pin?

  # TOTP
  defdelegate create_totp(params), to: TOTP, as: :insert
  defdelegate create_totp!(params), to: TOTP, as: :insert!

  defdelegate list_totp(filters \\ []), to: TOTP, as: :list

  defdelegate get_totp_by(filters), to: TOTP, as: :get_by
  defdelegate get_totp_by!(filters), to: TOTP, as: :get_by!

  defdelegate delete_totp(totp), to: TOTP, as: :delete
  defdelegate delete_totp!(totp), to: TOTP, as: :delete!

  defdelegate check_totp?(totp, totp_code, datetime \\ NaiveDateTime.utc_now()),
    to: TOTP,
    as: :check_totp?

  # Public Key
  defdelegate create_public_key(params), to: PublicKey, as: :insert
  defdelegate create_public_key!(params), to: PublicKey, as: :insert!

  defdelegate list_public_key(filters \\ []), to: PublicKey, as: :list

  defdelegate get_public_key_by(filters), to: PublicKey, as: :get_by
  defdelegate get_public_key_by!(filters), to: PublicKey, as: :get_by!

  defdelegate delete_public_key(public_key), to: PublicKey, as: :delete
  defdelegate delete_public_key!(public_key), to: PublicKey, as: :delete!
end
