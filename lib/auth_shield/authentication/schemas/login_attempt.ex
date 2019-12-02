defmodule AuthShield.Authentication.Schemas.LoginAttempt do
  @moduledoc """
  User login attempts.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias AuthShield.Resources.Schemas.User

  @typedoc """
  Abstract loggin attempt module type.
  """
  @type t :: %__MODULE__{
          id: binary(),
          user: User.t(),
          remote_ip: String.t(),
          user_agent: String.t(),
          status: String.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @required_fields [:status, :user_id]
  @optional_fields [:remote_ip, :user_agent]
  schema "login_attempts" do
    field(:remote_ip, :string)
    field(:user_agent, :string)
    field(:status, :string)

    belongs_to(:user, User)

    timestamps()
  end

  @doc "Generates an `Ecto.Changeset` struct with the changes."
  @spec changeset(model :: t(), params :: map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = model, params) when is_map(params) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_inclusion(:status, ["succeed", "failed"])
    |> validate_required(@required_fields)
  end
end
