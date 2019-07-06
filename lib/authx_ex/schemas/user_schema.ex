defmodule AuthX.Schemas.User do
  @moduledoc """
  Defines the all the user field and its relations.

  The user is an subject that makes requests to the systems and
  is used on authentication and authorization request on services.

  We do not save users password, only the encripted hash that will
  be used to authenticate in password based forms.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @typedoc """
  Abstract user module type.
  """
  @type t :: %__MODULE__{
          id: binary(),
          first_name: String.t(),
          last_name: String.t(),
          email: String.t(),
          password: String.t(),
          password_hash: String.t(),
          is_active: boolean(),
          last_login: NaiveDateTime.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    field(:is_active, :boolean, default: true)
    field(:last_login, :naive_datetime_usec)

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
    |> cast(params, [:first_name, :last_name, :email, :password])
    |> validate_required([:first_name, :email, :password])
    |> validate_length(:first_name, min: 2, max: 150)
    |> validate_length(:last_name, min: 2, max: 150)
    |> validate_length(:email, min: 7, max: 150)
    |> validate_length(:password, min: 6, max: 150)
    |> unique_constraint(:email)
    |> validate_email()
    |> validate_password()
    |> put_pass_hash()
  end

  @doc """
  Generates an `%Ecto.Changeset{}` struct with the changes.

  THIS DOES NOT CHANGE THE `password` and `is_active`.
  """
  @spec changeset_update(model :: t(), params :: map()) :: Ecto.Changeset.t()
  def changeset_update(%__MODULE__{} = model, params) when is_map(params) do
    model
    |> cast(params, [:first_name, :last_name, :email])
    |> validate_length(:first_name, min: 2, max: 150)
    |> validate_length(:last_name, min: 2, max: 150)
    |> validate_length(:email, min: 7, max: 150)
    |> unique_constraint(:email)
    |> validate_email()
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

  @doc """
  Generates an `%Ecto.Changeset{}` struct with the changes.

  THIS ONLY ACCEPTS the `password` field.
  """
  @spec changeset_password(model :: t(), params :: map()) :: Ecto.Changeset.t()
  def changeset_password(%__MODULE__{} = model, params) when is_map(params) do
    model
    |> cast(params, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 6, max: 150)
    |> validate_password()
    |> put_pass_hash()
  end

  defp validate_email(%{changes: %{email: email}} = changeset) do
    # The email should have valid format and domain.
    # We use `Burnex` to check if the provider is an known temporary email domain.
    #
    # See more in https://hexdocs.pm/burnex/Burnex.html

    regex = ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]+$/

    with {:regex, true} <- {:regex, Regex.match?(regex, email)},
         {:burner, false} <- {:burner, Burnex.is_burner?(email)} do
      changeset
    else
      {:regex, false} -> add_error(changeset, :email, "Invalid email format")
      {:burner, true} -> add_error(changeset, :email, "Invalid email provider")
    end
  end

  defp validate_email(changeset), do: changeset

  defp validate_password(%{changes: %{password: pwd}} = changeset) do
    # In order to pass the validation the password should fit the requirements bellow:
    # - at least 1 upper case letter
    # - at least 1 lower case letter
    # - at least 1 number or special character
    # - at least 8 characters in length

    regex = ~r/^(?=^.{8,}$)((?=.*\d)|(?=.*\W+))(?=.[!@#\$%\^&])(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$/

    if Regex.match?(regex, pwd) do
      changeset
    else
      add_error(changeset, :password, "Password not strong enough")
    end
  end

  defp validate_password(changeset), do: changeset

  defp put_pass_hash(%{valid?: true, changes: %{password: pwd}} = changeset) do
    # Append the password hash to the changeset
    # We use `Argon2 to hash and verify the password
    #
    # See more in https://hexdocs.pm/argon2_elixir/Argon2.html

    change(changeset, Argon2.add_hash(pwd))
  end

  defp put_pass_hash(changeset), do: changeset
end
