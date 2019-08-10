defmodule AuthX.Resources.Schemas.RolesPermissions do
  @moduledoc """
  Defines the association between roles and permissions.

  This is only used to create the many to many relations on
  the tables.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias AuthX.Resources.Schemas.{Permission, Role}

  @typedoc """
  Abstract role module type.
  """
  @type t :: %__MODULE__{
          role: Role.t(),
          permission: Permission.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @primary_key false
  @required_fields [:role_id, :permission_id]
  schema "roles_permissions" do
    belongs_to(:role, Role, primary_key: true)
    belongs_to(:permission, Permission, primary_key: true)

    timestamps(type: :naive_datetime_usec)
  end

  @doc "Generates an `%Ecto.Changeset{}` struct with the changes."
  @spec changeset(model :: t(), params :: map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = model, params) when is_map(params) do
    model
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:role_id)
    |> foreign_key_constraint(:permission_id)
    |> unique_constraint([:role, :permission], name: :role_id_permission_id_unique_index)
  end
end
