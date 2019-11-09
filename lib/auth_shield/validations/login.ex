defmodule AuthShield.Validations.Login do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @typedoc "Abstract user validation module type."
  @type t :: %{
          email: String.t(),
          password: String.t()
        }

  @required_fields [:email, :password]
  schema "login" do
    field(:email, :string, virtual: true)
    field(:password, :string, virtual: true)
  end

  @doc "Validates if the given params are valid"
  @spec validate(params :: map()) :: {:ok, __MODULE__.t()}
  def validate(params, opts \\ []) when is_map(params) when is_list(opts) do
    %__MODULE__{}
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_length(:email, min: 7, max: 150)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 6, max: 150)
    |> check_validation()
  end

  defp check_validation(%{valid?: true, changes: changes}), do: {:ok, changes}

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
