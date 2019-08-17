defmodule AuthX.Resources.Schemas.UsersRoles do
  @moduledoc """
  Defines the association between users and roles.

  This is only used to create the many to many relations on
  the tables.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias AuthX.Resources.Schemas.{Role, User}

  @typedoc """
  Abstract role module type.
  """
  @type t :: %__MODULE__{
          user: User.t(),
          role: Role.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @primary_key false
  @foreign_key_type :binary_id
  @required_fields [:user_id, :role_id]
  schema "users_roles" do
    belongs_to(:user, User, primary_key: true)
    belongs_to(:role, Role, primary_key: true)

    timestamps()
  end

  @doc "Generates an `%Ecto.Changeset{}` struct with the changes."
  @spec changeset(model :: t(), params :: map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = model, params) when is_map(params) do
    model
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:role_id)
    |> unique_constraint(:user, name: :user_id_role_id_unique_index)
    |> unique_constraint(:role, name: :user_id_role_id_unique_index)
  end
end
