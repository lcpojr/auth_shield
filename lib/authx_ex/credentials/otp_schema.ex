defmodule AuthX.Schemas.Credentials.TOTP do
  @moduledoc """
  TOTP  (Time-based One Time Password) is an extension of the HOTP (HMAC-based One-time Password).

  We generates a one-time password from sharing a secret key randomly generated that should
  be known only for us and the client.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias AuthX.Schemas.User

  @typedoc """
  Abstract totp module type.
  """
  @type t :: %__MODULE__{
          id: binary(),
          user: User.t(),
          secret: String.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @characters String.split("AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz", "")

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "totp_credentials" do
    field(:secret, :string)

    belongs_to(:user, User)

    timestamps(type: :naive_datetime_usec)
  end

  @doc """
  Generates an `%Ecto.Changeset{}` struct with the changes.

  It defines validations and also generates the password hash if
  necessary.
  """
  @spec changeset_insert(model :: t(), params :: map()) :: Ecto.Changeset.t()
  def changeset_insert(%__MODULE__{} = model, params) when is_map(params) do
    model
    |> cast(params, [:user_id])
    |> validate_required([:user_id])
    |> unique_constraint(:user_id)
    |> put_random_secret()
  end

  defp put_random_secret(%{valid?: true, changes: _changes} = changeset) do
    # Generates and random string that contains the alphabet letters
    secret = Enum.reduce(1..20, "", fn _, acc -> acc <> Enum.random(@characters) end)
    change(changeset, %{secret: secret})
  end

  defp put_random_secret(changeset), do: changeset
end
