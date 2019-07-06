defmodule AuthX.Schemas.User do
  @moduledoc """
  This module defines the all the user field and its relations.

  The user is an subject that makes requests to the systems and
  is used on authentication and authorization request on services.

  We do not save users password, only the encripted hash that will
  be used to authenticate in password based forms.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias AuthX.Repo

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

  @required [:first_name, :email, :password]
  @optional [:last_name, :is_active]
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

  The changeset is used to perform transactions on database
  updating or inserting new data.

  It defines validations and also generates the password hash if
  necessary.
  """
  @spec changeset(model :: __MODULE__.t(), params :: map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = model, params) when is_map(params) do
    model
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> validate_length(:first_name, min: 2, max: 150)
    |> validate_length(:email, min: 7, max: 150)
    |> validate_length(:password, min: 6, max: 150)
    |> validate_email()
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
      {:regex, false} -> add_error(changeset, :email, "invalid_format")
      {:burner, true} -> add_error(changeset, :email, "forbidden_provider")
    end
  end

  defp validate_email(changeset), do: changeset

  defp validate_password(%{changes: %{password: pwd}} = changeset) do
    # The password should have at least:
    #  - 6 characters length
    #  - 1 letters in Upper Case
    #  - 1 Special Character (!@#$&*)
    #  - 1 numerals (0-9)
    #  - 1 letters in Lower Case

    regex = ~r/^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{6}$/

    if Regex.match?(regex, pwd) do
      changeset
    else
      add_error(changeset, :password, "not_strong")
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

  @doc """
  Creates a new `__MODULE__` register.

  It returns `{:ok, %__MODULE__{}} if the struct has been successfully
  inserted or `{:error, %Ecto.Changeset{}}` if there was a validation or
  a known constraint error.
  """
  @spec insert(params :: map()) :: {:ok, __MODULE__.t()} | {:error, Ecto.Changeset.t()}
  def insert(params) do
    %__MODULE__{}
    |> changeset(params)
    |> Repo.insert()
  end

  @doc """
  Creates a new `__MODULE__` register.

  Similar to `insert/1` but raises if the changeset is invalid.
  """
  @spec insert!(params :: map()) :: {:ok, __MODULE__.t()}
  def insert!(params) do
    %__MODULE__{}
    |> changeset(params)
    |> Repo.insert!()
  end

  @doc """
  Updates a `__MODULE__` register.

  It returns `{:ok, %__MODULE__{}} if the struct has been successfully
  updated or `{:error, %Ecto.Changeset{}}` if there was a validation or
  a known constraint error.
  """
  @spec update(model :: __MODULE__.t(), params :: map()) ::
          {:ok, %__MODULE__{}} | {:error, Ecto.Changeset.t()}
  def update(model, params) do
    model
    |> changeset(params)
    |> Repo.update()
  end

  @doc """
  Updates a `__MODULE__` register.

  Similar to `update/2` but raises if the changeset is invalid.
  """
  @spec update!(model :: __MODULE__.t(), params :: map()) :: {:ok, %__MODULE__{}}
  def update!(model, params) do
    model
    |> changeset(params)
    |> Repo.update()
  end

  @doc """
  Gets a `__MODULE__` register by its filters.

  Returns nil if no result was found. Raises if more than one entry.
  """
  @spec get_by(filters :: keyword()) :: __MODULE__.t() | nil
  def get_by(filters), do: Repo.get_by(__MODULE__, filters)

  @doc """
  Gets a `__MODULE__` register by its filters.

  Similar to `get_by/1` but raises `Ecto.NoResultsError` if no record was found.
  Raises if more than one entry.
  """
  @spec get_by!(filters :: keyword()) :: __MODULE__.t()
  def get_by!(filters), do: Repo.get_by(__MODULE__, filters)
end
