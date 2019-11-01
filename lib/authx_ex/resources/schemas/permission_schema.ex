defmodule AuthShield.Resources.Schemas.Permission do
  @moduledoc """
  Defines all permissions that an role can have.

  We use it to create a role-based access control (RBAC) in order to
  restrict system access to users that has specif roles.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias AuthShield.Resources.Schemas.{Role, RolesPermissions}

  @typedoc """
  Abstract permission module type.
  """
  @type t :: %__MODULE__{
          id: binary(),
          name: String.t(),
          description: String.t(),
          roles: list(Role.t()),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "permissions" do
    field(:name, :string)
    field(:description, :string)

    many_to_many(:roles, Role, join_through: RolesPermissions)

    timestamps()
  end

  @doc "Generates an `Ecto.Changeset` struct with the changes."
  @spec changeset(model :: t(), params :: map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = model, params) when is_map(params) do
    model
    |> cast(params, [:name, :description])
    |> validate_required([:name])
    |> validate_length(:name, min: 1)
    |> unique_constraint(:name)
  end
end
