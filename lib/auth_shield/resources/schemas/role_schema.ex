defmodule AuthShield.Resources.Schemas.Role do
  @moduledoc """
  Defines all roles that an user can have.

  We use it to create a role-based access control (RBAC) in order to
  restrict system access to users that has specif roles.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias AuthShield.Resources.Schemas.{Permission, RolesPermissions, User, UsersRoles}

  @typedoc """
  Abstract role module type.
  """
  @type t :: %__MODULE__{
          id: binary(),
          name: String.t(),
          description: String.t(),
          users: list(User.t()),
          permissions: list(Permission.t()),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "roles" do
    field(:name, :string)
    field(:description, :string)

    many_to_many(:users, User, join_through: UsersRoles)
    many_to_many(:permissions, Permission, join_through: RolesPermissions)

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

  @doc """
  Generates an `Ecto.Changeset` struct with the changes.

  It changes the related permissions list.
  """
  @spec changeset_permissions(model :: t(), permissions :: list(Permission.t())) ::
          Ecto.Changeset.t()
  def changeset_permissions(%__MODULE__{} = model, permissions) do
    model
    |> cast(%{}, [])
    |> put_assoc(:permissions, permissions)
  end
end
