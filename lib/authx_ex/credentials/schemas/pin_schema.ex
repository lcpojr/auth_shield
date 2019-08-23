defmodule AuthX.Credentials.Schemas.PIN do
  @moduledoc """
  PIN (Personal Identification Number) schema model.

  We do not save users pin, only the encripted hash that will
  be used to authenticate.

  To see more about how we hash the pin check `Argon2`.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias AuthX.Resources.Schemas.User

  @typedoc """
  Abstract pin module type.
  """
  @type t :: %__MODULE__{
          id: binary(),
          user: User.t(),
          pin_hash: String.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @required_fields [:pin, :user_id]
  schema "pin_credentials" do
    field(:pin, :string, virtual: true)
    field(:pin_hash, :string)

    belongs_to(:user, User)

    timestamps()
  end

  @doc """
  Generates an `Ecto.Changeset` struct with the changes.

  It defines validations and also generates the pin hash if
  necessary.
  """
  @spec changeset(model :: t(), params :: map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = model, params) when is_map(params) do
    model
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_length(:pin, min: 4, max: 6)
    |> unique_constraint(:user_id)
    |> validate_pin()
    |> put_pin_hash()
  end

  defp validate_pin(%{changes: %{pin: pin}} = changeset) do
    # In order to pass the validation the PIN should fit the requirements bellow:
    # - at least 4 or 6 digits
    # - all digits should be numbers

    regex = ~r/^(\d{4}|\d{6})$/

    if Regex.match?(regex, pin) do
      changeset
    else
      add_error(changeset, :pin, "PIN does not match the requirements")
    end
  end

  defp validate_pin(changeset), do: changeset

  defp put_pin_hash(%{valid?: true, changes: %{pin: pin}} = changeset) do
    # Append the PIN hash to the changeset
    # We use `Argon2` to hash and verify the PIN
    #
    # See more in https://hexdocs.pm/argon2_elixir/Argon2.html

    change(changeset, %{pin_hash: Argon2.hash_pwd_salt(pin), pin: nil})
  end

  defp put_pin_hash(changeset), do: changeset
end
