defmodule AuthShield.Credentials.Schemas.Password do
  @moduledoc """
  Password schema model.

  We do not save users password, only the encripted hash that will
  be used to authenticate.

  To see more about how we hash the password check `Argon2`.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias AuthShield.Resources.Schemas.User

  @typedoc """
  Abstract password module type.
  """
  @type t :: %__MODULE__{
          id: binary(),
          user: User.t(),
          algorithm: String.t(),
          password_hash: String.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @required_fields [:password, :user_id]
  @optional_fields [:algorithm]
  schema "password_credentials" do
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    field(:algorithm, :string, default: "argon2")

    belongs_to(:user, User)

    timestamps()
  end

  @doc """
  Generates an `Ecto.Changeset` struct with the changes.

  It defines validations and also generates the password hash if
  necessary.
  """
  @spec changeset(model :: t(), params :: map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = model, params) when is_map(params) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:password, min: 6, max: 150)
    |> unique_constraint(:user_id)
    |> put_pass_hash()
  end

  @doc """
  Generates an `Ecto.Changeset` to be used on assoc with the user.

  It defines validations and also generates the password hash if
  necessary.
  """
  @spec changeset_assoc(model :: t(), params :: map()) :: Ecto.Changeset.t()
  def changeset_assoc(%__MODULE__{} = model, params) when is_map(params) do
    model
    |> cast(params, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 6, max: 150)
    |> unique_constraint(:user_id)
    |> put_pass_hash()
  end

  defp put_pass_hash(%{valid?: true, changes: %{password: pwd}} = changeset) do
    # Append the password hash to the changeset
    # We use `Argon2` to hash and verify the password
    #
    # See more in https://hexdocs.pm/argon2_elixir/Argon2.html

    change(changeset, %{password_hash: Argon2.hash_pwd_salt(pwd), password: nil})
  end

  defp put_pass_hash(changeset), do: changeset
end
