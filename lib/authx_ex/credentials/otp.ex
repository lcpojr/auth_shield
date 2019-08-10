defmodule AuthX.Credentials.TOTP do
  @moduledoc """
  Implements an interface to deal with database transactions as inserts, updates, deletes, etc.

  It will also be used to verify user credentials on authentication and permissions on
  authorization.
  """

  alias AuthX.Credentials.Schemas.TOTP
  alias AuthX.Repo

  @typedoc "Transactional responses of success"
  @type success_response :: {:ok, TOTP.t()}

  @typedoc "Transactional responses of failed"
  @type failed_response :: {:error, Ecto.Changeset.t()}

  @doc "Creates a new `TOTP` register."
  @spec insert(params :: map()) :: success_response() | failed_response()
  def insert(params) when is_map(params) do
    %TOTP{}
    |> TOTP.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Creates a new `TOTP` register.

  Similar to `insert/1` but raises if the changeset is invalid.
  """
  @spec insert!(params :: map()) :: success_response() | no_return()
  def insert!(params) when is_map(params) do
    %TOTP{}
    |> TOTP.changeset(params)
    |> Repo.insert!()
  end

  @doc "Gets a `TOTP` register by its filters."
  @spec get_by(filters :: keyword()) :: TOTP.t() | nil
  def get_by(filters) when is_list(filters), do: Repo.get_by(TOTP, filters)

  @doc """
  Gets a `TOTP` register by its filters.

  Similar to `get_by/1` but raises `Ecto.NoResultsError` if no record was found.
  Raises if more than one entry.
  """
  @spec get_by!(filters :: keyword()) :: TOTP.t() | no_return()
  def get_by!(filters) when is_list(filters), do: Repo.get_by(TOTP, filters)

  @doc "Deletes a `TOTP` register."
  @spec delete(totp :: TOTP.t()) :: success_response() | failed_response()
  def delete(%TOTP{} = totp), do: Repo.delete(totp)

  @doc """
  Deletes a `TOTP` register.

  Similar to `delete/1` but raises `Ecto.NoResultsError` if no record was found.
  Raises if changeset is invalid.
  """
  @spec delete!(totp :: TOTP.t()) :: success_response() | no_return()
  def delete!(%TOTP{} = totp), do: Repo.delete!(totp)

  @doc "Checks if the give TOTP matches the generated one."
  @spec check_totp?(totp :: TOTP.t(), totp_code :: String.t(), now :: DateTime.t()) :: boolean()
  def check_totp?(%TOTP{} = totp, code, datetime_now \\ Timex.now()) when is_binary(code) do
    credential_totp =
      generate_totp(totp.secret, totp.period, totp.digits, datetime_now) |> IO.inspect()

    if credential_totp == code, do: true, else: false
  end

  defp generate_totp(secret, period, digits, datetime) do
    secret
    |> generate_hmac(period, datetime)
    |> hmac_sha1_truncate()
    |> generate_hotp(digits)
  end

  defp generate_hmac(secret, period, datetime) do
    # Generates a HMAC encoded in SHA-1.
    #
    # HMAC (Hash-based Message Authentication Code) is a specific type of
    # message authentication code (MAC) involving a cryptographic hash
    # function and a secret cryptographic key.

    # Decodes the secret in `Base32`
    key =
      secret
      |> String.upcase()
      |> Base.decode32!(padding: false)

    # Generating time factor
    moving_factor =
      datetime
      |> DateTime.to_unix()
      |> Integer.floor_div(period)
      |> Integer.to_string(16)
      |> String.pad_leading(16, "0")
      |> String.upcase()
      |> Base.decode16!(padding: false)

    # Generate SHA-1
    :crypto.hmac(:sha, key, moving_factor)
  end

  defp hmac_sha1_truncate(hmac) do
    # Generate a digest and truncate it to obtain a password

    # Get the offset from last  4-bits
    <<_::19-binary, _::4, offset::4>> = hmac

    # Get the 4-bytes starting from the offset
    <<_::size(offset)-binary, p::4-binary, _::binary>> = hmac

    # Return the last 31-bits
    <<_::1, truncated_hmac::31>> = p

    truncated_hmac
  end

  defp generate_hotp(truncated_hmac, digits) do
    truncated_hmac
    |> rem(1_000_000)
    |> Integer.to_string()
    |> String.pad_leading(digits, ["0"])
  end
end
