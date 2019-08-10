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

  alias AuthX.Credentials.Schemas.{PIN, TOTP}
  alias AuthX.Resources.Schemas.{Role, UsersRoles}

  @typedoc "Abstract user module type."
  @type t :: %__MODULE__{
          id: binary(),
          first_name: String.t(),
          last_name: String.t(),
          email: String.t(),
          password: String.t(),
          password_hash: String.t(),
          is_active: boolean(),
          pin_credential: PIN.t(),
          totp_credential: TOTP.t(),
          roles: list(Role.t()),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @email_regex ~r/@/
  @password_regex ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]+$/

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    field(:is_active, :boolean, default: true)

    # Credentials
    has_one(:pin_credential, PIN)
    has_one(:totp_credential, TOTP)

    # Authorizations
    many_to_many(:roles, Role, join_through: UsersRoles)

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
    |> validate_format(:email, @email_regex)
    |> unique_constraint(:email)
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

  defp validate_password(%{valid?: true, changes: %{password: pwd}} = changeset) do
    # In order to pass the validation the password should fit the requirements bellow:
    # - at least 1 upper case letter
    # - at least 1 lower case letter
    # - at least one special character
    # - at least 8 characters in length

    if Regex.match?(@password_regex, pwd) do
      changeset
    else
      add_error(changeset, :password, "Password does not match the minimun requirements")
    end
  end

  defp validate_password(changeset), do: changeset

  defp put_pass_hash(%{valid?: true, changes: %{password: pwd}} = changeset) do
    # Append the password hash to the changeset
    # We use `Argon2 to hash and verify the password
    #
    # See more in https://hexdocs.pm/argon2_elixir/Argon2.html

    change(changeset, %{password_hash: Argon2.hash_pwd_salt(pwd), password: nil})
  end

  defp put_pass_hash(changeset), do: changeset
end
