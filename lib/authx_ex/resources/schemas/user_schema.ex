defmodule AuthX.Resources.Schemas.User do
  @moduledoc """
  Defines all the user fields and its relations.

  The user is a resource and an subject that makes requests to the systems and
  is used on authentication and authorization request.

  We do not save users password, only the encripted hash that will
  be used to authenticate in password based forms.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias AuthX.Credentials.Schemas.{Password, PIN, TOTP}
  alias AuthX.Resources.Schemas.{Role, UsersRoles}

  @typedoc "Abstract user module type."
  @type t :: %__MODULE__{
          id: binary(),
          first_name: String.t(),
          last_name: String.t(),
          email: String.t(),
          is_active: boolean(),
          roles: list(Role.t()),
          pin_credential: PIN.t(),
          totp_credential: TOTP.t(),
          password_credential: Password.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @email_regex ~r/@/

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @required_fields [:first_name, :email]
  schema "users" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:is_active, :boolean, default: false)

    # Authorizations
    many_to_many(:roles, Role, join_through: UsersRoles)

    # Credentials
    has_one(:pin_credential, PIN)
    has_one(:totp_credential, TOTP)
    has_one(:password_credential, Password)

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
    |> cast(params, @required_fields ++ [:last_name, :is_active])
    |> validate_required(@required_fields)
    |> validate_length(:first_name, min: 2, max: 150)
    |> validate_length(:last_name, min: 2, max: 150)
    |> validate_length(:email, min: 7, max: 150)
    |> validate_format(:email, @email_regex)
    |> unique_constraint(:email)
    |> cast_assoc(:password_credential, required: true, with: &Password.changeset_assoc/2)
  end

  @doc """
  Generates an `%Ecto.Changeset{}` struct with the changes.

  THIS DOES NOT CHANGE THE `password` and `is_active`.
  """
  @spec changeset_update(model :: t(), params :: map()) :: Ecto.Changeset.t()
  def changeset_update(%__MODULE__{} = model, params) when is_map(params) do
    model
    |> cast(params, @required_fields ++ [:last_name])
    |> validate_length(:first_name, min: 2, max: 150)
    |> validate_length(:last_name, min: 2, max: 150)
    |> validate_length(:email, min: 7, max: 150)
    |> validate_format(:email, @email_regex)
    |> unique_constraint(:email)
  end

  @doc """
  Generates an `%Ecto.Changeset{}` struct with the changes.

  It changes the related roles list.
  """
  @spec changeset_roles(model :: t(), roles :: list(Role.t())) :: Ecto.Changeset.t()
  def changeset_roles(%__MODULE__{} = model, roles) do
    model
    |> cast(%{}, [])
    |> put_assoc(:roles, roles)
  end

  @doc """
  Generates an `%Ecto.Changeset{}` struct with the changes.

  THIS ONLY ACCEPTS the `is_active` field.
  """
  @spec changeset_status(model :: t(), params :: map()) :: Ecto.Changeset.t()
  def changeset_status(%__MODULE__{} = model, params) when is_map(params) do
    model
    |> cast(params, [:is_active])
    |> validate_required([:is_active])
  end
end
