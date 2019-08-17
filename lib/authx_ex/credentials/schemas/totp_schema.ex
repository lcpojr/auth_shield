defmodule AuthX.Credentials.Schemas.TOTP do
  @moduledoc """
  TOTP (Time-based One Time Password) shema model.

  We generates a one-time password from sharing a secret key randomly generated that should
  be known only for us and the client.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias AuthX.Resources.Schemas.User

  @typedoc """
  Abstract totp module type.
  """
  @type t :: %__MODULE__{
          id: binary(),
          user: User.t(),
          issuer: String.t(),
          secret: String.t(),
          digits: integer(),
          period: integer(),
          qrcode_base64: String.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @characters String.split("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", "")
  @issuer "AuthX"
  @digits 6
  @period 30

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @required_fields [:user_id, :email]
  schema "totp_credentials" do
    field(:secret, :string)
    field(:email, :string, virtual: true)
    field(:issuer, :string, default: @issuer)
    field(:digits, :integer, default: @digits)
    field(:period, :integer, default: @period)
    field(:qrcode_base64, :string)

    belongs_to(:user, User)

    timestamps()
  end

  @doc """
  Generates an `%Ecto.Changeset{}` struct with the changes.

  It defines validations and also generates the secret if
  necessary.
  """
  @spec changeset(model :: t(), params :: map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = model, params) when is_map(params) do
    model
    |> cast(params, @required_fields ++ [:issuer, :digits, :period])
    |> validate_required(@required_fields)
    |> validate_number(:digits, greater_than_or_equal_to: 4)
    |> validate_number(:period, greater_than_or_equal_to: 30)
    |> unique_constraint(:user_id)
    |> put_random_secret()
    |> put_qrcode()
  end

  @doc """
  Generates and random string that contains the alphabet letters
  and is used as `__MODULE__` secret.
  """
  @spec generate_random_secret() :: String.t()
  def generate_random_secret do
    Enum.reduce(1..20, "", fn _, acc -> acc <> Enum.random(@characters) end)
  end

  defp put_random_secret(%{valid?: true} = changeset) do
    change(changeset, %{secret: generate_random_secret()})
  end

  defp put_random_secret(changeset), do: changeset

  defp put_qrcode(%{valid?: true, changes: %{secret: secret, email: email}} = changeset) do
    # The URI should be in the correct format
    # See more here: https://github.com/google/google-authenticator/wiki/Key-Uri-Format
    issuer = Map.get(changeset.changes, :issuer, @issuer)
    digits = Map.get(changeset.changes, :digits, @digits)
    period = Map.get(changeset.changes, :digits, @period)

    label = :http_uri.encode("#{issuer}:#{email}")

    # Generating QR code by OTP auth URI
    qrcode_base64 =
      "otpauth://totp/#{label}?secret=#{secret}&issuer=#{issuer}&digits=#{digits}&period=#{period}&algorithm=SHA1"
      |> EQRCode.encode()
      |> EQRCode.png()
      |> Base.encode64(padding: false)

    change(changeset, %{qrcode_base64: qrcode_base64})
  end

  defp put_qrcode(changeset), do: changeset
end
