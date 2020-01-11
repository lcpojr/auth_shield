defmodule AuthShield.Resources.Schemas.Application do
  @moduledoc """
  Defines all the application fields and its relations.

  The application is a resource and an subject that makes requests to the systems and
  is used on authentication and authorization request.

  It requires an application key but we do not save applications private keys,
  only the the public ones in order to decrypt the tokens.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias AuthShield.Credentials.Schemas.PublicKey
  alias AuthShield.Resources.Schemas.{ApplicationScopes, Scope}

  @typedoc "Abstract application module type."
  @type t :: %__MODULE__{
          id: binary(),
          name: String.t(),
          description: String.t(),
          is_active: boolean(),
          direct_access_grants_enabled: boolean(),
          scopes: list(Scopes.t()),
          public_key_credential: PublicKey.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @required_fields [:name, :public_key_credential]
  @optional_fields [:description, :is_active, :direct_access_grants_enabled]
  schema "applications" do
    field(:name, :string)
    field(:description, :string)
    field(:is_active, :boolean, default: false)
    field(:direct_access_grants_enabled, :boolean, default: true)

    # Authorizations
    many_to_many(:scopes, Scope, join_through: ApplicationScopes)

    # Credentials
    has_one(:public_key_credential, PublicKey)

    timestamps()
  end

  @doc """
  Generates an `Ecto.Changeset` struct with the changes.

  It defines validations and also generates the public key hash if
  necessary.
  """
  @spec changeset_insert(model :: t(), params :: map()) :: Ecto.Changeset.t()
  def changeset_insert(%__MODULE__{} = model, params) when is_map(params) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:name, min: 2, max: 150)
    |> cast_assoc(:public_key_credential, required: true, with: &PublicKey.changeset_assoc/2)
    |> unique_constraint(:name)
  end

  @doc """
  Generates an `Ecto.Changeset` struct with the changes.

  THIS DOES NOT CHANGE THE `public_key` and `is_active`.
  """
  @spec changeset_update(model :: t(), params :: map()) :: Ecto.Changeset.t()
  def changeset_update(%__MODULE__{} = model, params) when is_map(params) do
    model
    |> cast(params, [:name, :description])
    |> validate_length(:name, min: 2, max: 150)
    |> unique_constraint(:name)
  end

  @doc """
  Generates an `Ecto.Changeset` struct with the changes.

  It changes the related scopes list.
  """
  @spec changeset_scopes(model :: t(), scopes :: list(Scope.t())) :: Ecto.Changeset.t()
  def changeset_scopes(%__MODULE__{} = model, scopes) do
    model
    |> cast(%{}, [])
    |> put_assoc(:scopes, scopes)
  end

  @doc """
  Generates an `Ecto.Changeset` struct with the changes.

  THIS ONLY ACCEPTS the `is_active` field.
  """
  @spec changeset_status(model :: t(), params :: map()) :: Ecto.Changeset.t()
  def changeset_status(%__MODULE__{} = model, params) when is_map(params) do
    model
    |> cast(params, [:is_active])
    |> validate_required([:is_active])
  end
end
