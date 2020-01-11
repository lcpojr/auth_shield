defmodule AuthShield.Resources.Schemas.Scopes do
  @moduledoc """
  Defines all scopes that an application can have.

  We use it in the Oauth2 authentication flows.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias AuthShield.Resources.Schemas.{Application, ApplicationScopes}

  @typedoc "Abstract scope module type."
  @type t :: %__MODULE__{
          id: binary(),
          name: String.t(),
          description: String.t(),
          applications: list(Application.t()),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "scopes" do
    field(:name, :string)
    field(:description, :string)

    many_to_many(:applications, Application, join_through: ApplicationScopes)

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

  It changes the related applications list.
  """
  @spec changeset_applications(model :: t(), applications :: list(Application.t())) ::
          Ecto.Changeset.t()
  def changeset_applications(%__MODULE__{} = model, applications) do
    model
    |> cast(%{}, [])
    |> put_assoc(:applications, applications)
  end
end
