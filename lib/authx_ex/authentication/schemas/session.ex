defmodule AuthX.Authentication.Schemas.Session do
  @moduledoc """
  User authenticated session.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias AuthX.Resources.Schemas.User

  @typedoc """
  Abstract session module type.
  """
  @type t :: %__MODULE__{
          id: binary(),
          user: User.t(),
          ip_address: String.t(),
          user_agent: String.t(),
          expiration: String.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @required_fields [:ip_address, :expiration, :login_at, :user_id]
  schema "sessions" do
    field(:ip_address, :string)
    field(:user_agent, :string)
    field(:expiration, :naive_datetime)
    field(:login_at, :naive_datetime)
    field(:logout_at, :naive_datetime)

    belongs_to(:user, User)

    timestamps()
  end

  @doc "Generates an `Ecto.Changeset` struct with the changes."
  @spec insert_changeset(model :: t(), params :: map()) :: Ecto.Changeset.t()
  def insert_changeset(%__MODULE__{} = model, params) when is_map(params) do
    model
    |> cast(params, @required_fields ++ [:user_agent])
    |> validate_required(@required_fields)
  end

  @doc "Generates an `Ecto.Changeset` struct with the changes."
  @spec update_changeset(model :: t(), params :: map()) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = model, params) when is_map(params) do
    cast(model, params, [:expiration, :logout_at])
  end
end
