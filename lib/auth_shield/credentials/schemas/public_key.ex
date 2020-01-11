defmodule AuthShield.Credentials.Schemas.PublicKey do
  @moduledoc """
  Keys schema model.

  We only save public application keys in order to decrypt application token.
  You should never save private k=or confidential keys in this schema.
  """

  use Ecto.Schema

  import Ecto.Changeset

  use Ecto.Schema

  import Ecto.Changeset

  alias AuthShield.Resources.Schemas.Application

  @typedoc """
  Abstract public key module type.
  """
  @type t :: %__MODULE__{
          id: binary(),
          application: Application.t(),
          format: String.t(),
          key: String.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @required_fields [:key]
  @optional_fields [:application_id, :format]
  schema "public_key_credentials" do
    field(:format, :string, default: "pem")
    field(:key, :string)

    belongs_to(:application, Application)

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
    |> validate_length(:key, min: 1)
    |> unique_constraint(:application_id)
  end
end
