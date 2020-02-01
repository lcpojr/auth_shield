defmodule AuthShield.Resources.Schemas.ApplicationScopes do
  @moduledoc """
  Defines the association between applications and scopes.

  This is only used to create the many to many relations on
  the tables.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias AuthShield.Resources.Schemas.{Application, Scope}

  @typedoc "Abstract applications scopes module type."
  @type t :: %__MODULE__{
          scope: Scope.t(),
          application: Application.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @primary_key false
  @foreign_key_type :binary_id
  @required_fields [:scope_id, :application_id]
  schema "applications_scopes" do
    belongs_to(:application, Application, primary_key: true)
    belongs_to(:scope, Scope, primary_key: true)

    timestamps()
  end

  @doc "Generates an `Ecto.Changeset` struct with the changes."
  @spec changeset(model :: t(), params :: map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = model, params) when is_map(params) do
    model
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:scope_id)
    |> foreign_key_constraint(:application_id)
    |> unique_constraint(:scope, name: :application_id_scope_id_unique_index)
    |> unique_constraint(:application, name: :application_id_scope_id_unique_index)
  end
end
