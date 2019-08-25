defmodule AuthX.Validations.SignUp do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @typedoc "Abstract user validation module type."
  @type t :: %{
          first_name: String.t(),
          last_name: String.t() | nil,
          email: String.t(),
          password: String.t()
        }

  @required_fields [:first_name, :email, :password]
  schema "signup" do
    field(:first_name, :string, virtual: true)
    field(:last_name, :string, virtual: true)
    field(:email, :string, virtual: true)
    field(:password, :string, virtual: true)
  end

  @doc "Validates if the given params are valid"
  @spec validate(params :: map()) :: {:ok, __MODULE__.t()}
  def validate(params) when is_map(params) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ [:last_name])
    |> validate_required(@required_fields)
    |> validate_length(:first_name, min: 2, max: 150)
    |> validate_length(:last_name, min: 2, max: 150)
    |> validate_length(:email, min: 7, max: 150)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 6, max: 150)
    |> check_validation()
  end

  defp check_validation(%{valid?: true, changes: changes}) do
    # Removing password value from map
    {password, changes} = Map.pop(changes, :password)

    # Parsing params
    input =
      changes
      |> Map.put(:password_credential, %{password: password})
      |> Map.put(:login_at, Timex.now())

    {:ok, input}
  end

  defp check_validation(%{valid?: false} = changeset) do
    errors =
      traverse_errors(changeset, fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)

    {:error, errors}
  end
end
