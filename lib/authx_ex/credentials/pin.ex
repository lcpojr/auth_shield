defmodule AuthX.Credentials.PIN do
  @moduledoc """
  A personal identification number (PIN), or sometimes redundantly a PIN number,
  is a numeric or alpha-numeric password used in the process of authenticating a user accessing a system.

  It is usually used in ATM oe POS transactions to authenticate identities and
  secure access control.

  This module implements an interface to deal with database transactions
  as inserts, updates, deletes, etc.
  """

  alias AuthX.Credentials.Schemas.PIN
  alias AuthX.Repo

  @typedoc "Transactional responses of success"
  @type success_response :: {:ok, PIN.t()}

  @typedoc "Transactional responses of failed"
  @type failed_response :: {:error, Ecto.Changeset.t()}

  @doc "Creates a new `PIN` register."
  @spec insert(params :: map()) :: success_response() | failed_response()
  def insert(params) when is_map(params) do
    %PIN{}
    |> PIN.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Creates a new `PIN` register.

  Similar to `insert/1` but raises if the changeset is invalid.
  """
  @spec insert!(params :: map()) :: success_response() | no_return()
  def insert!(params) when is_map(params) do
    %PIN{}
    |> PIN.changeset(params)
    |> Repo.insert!()
  end

  @doc "Gets a `PIN` register by its filters."
  @spec get_by(filters :: keyword()) :: PIN.t() | nil
  def get_by(filters) when is_list(filters), do: Repo.get_by(PIN, filters)

  @doc """
  Gets a `PIN` register by its filters.

  Similar to `get_by/1` but raises `Ecto.NoResultsError` if no record was found.
  Raises if more than one entry.
  """
  @spec get_by!(filters :: keyword()) :: PIN.t() | no_return()
  def get_by!(filters) when is_list(filters), do: Repo.get_by(PIN, filters)

  @doc "Deletes a `PIN` register."
  @spec delete(pin :: PIN.t()) :: success_response() | failed_response()
  def delete(%PIN{} = pin), do: Repo.delete(pin)

  @doc """
  Deletes a `PIN` register.

  Similar to `delete/1` but raises `Ecto.NoResultsError` if no record was found.
  Raises if changeset is invalid.
  """
  @spec delete!(pin :: PIN.t()) :: success_response() | no_return()
  def delete!(%PIN{} = pin), do: Repo.delete!(pin)

  @doc """
  Checks if the given PIN matches with the credential pin_hash

  It calls the `Argon2` to verify and returns `true` if the PIN
  matches and `false` if the PIN doesn't match.
  """
  @spec check_pin?(pin :: PIN.t(), pin_code :: String.t()) :: boolean()
  def check_pin?(%PIN{} = pin, code) when is_binary(code),
    do: Argon2.verify_pass(code, pin.pin_hash)
end
