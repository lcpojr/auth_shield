defmodule AuthShield.Credentials.PIN do
  @moduledoc """
  A personal identification number (PIN), or sometimes redundantly a PIN number,
  is a numeric or alpha-numeric password used in the process of authenticating a user accessing a system.

  It is usually used in ATM oe POS transactions to authenticate identities and
  secure access control.

  This module implements an interface to deal with database transactions
  as inserts, updates, deletes, etc.
  """

  alias AuthShield.Credentials.Schemas.PIN
  alias AuthShield.Repo

  require Ecto.Query

  @behaviour AuthShield.Credentials.Behaviour

  @doc """
  Creates a new `AuthShield.Credentials.Schemas.PIN` register.

  ## Exemples:
    ```elixir
    AuthShield.Credentials.PIN.insert(%{
      user_id: "ecb4c67d-6380-4984-ae04-1563e885d59e",
      pin: "332456"
    })
    ```
  """
  @impl true
  def insert(params) when is_map(params) do
    %PIN{}
    |> PIN.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Creates a new `AuthShield.Credentials.Schemas.PIN` register.

  Similar to `insert/1` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def insert!(params) when is_map(params) do
    %PIN{}
    |> PIN.changeset(params)
    |> Repo.insert!()
  end

  @doc """
  Returns a list of `AuthShield.Credentials.Schemas.PIN` by its filters

  ## Exemples:
    ```elixir
    # Getting the all list
    AuthShield.Credentials.PIN.list()

    # Filtering the list by field
    AuthShield.Credentials.PIN.list(user_id: "ecb4c67d-6380-4984-ae04-1563e885d59e")
    ```
  """
  @impl true
  def list(filters \\ []) when is_list(filters) do
    PIN
    |> Ecto.Query.where([p], ^filters)
    |> Repo.all()
  end

  @doc """
  Gets a `AuthShield.Credentials.Schemas.PIN` register by its filters.

  ## Exemples:
    ```elixir
    AuthShield.Credentials.PIN.get_by(user_id: "ecb4c67d-6380-4984-ae04-1563e885d59e")
    ```
  """
  @impl true
  def get_by(filters) when is_list(filters), do: Repo.get_by(PIN, filters)

  @doc """
  Gets a `AuthShield.Credentials.Schemas.PIN` register by its filters.

  Similar to `get_by/1` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def get_by!(filters) when is_list(filters), do: Repo.get_by!(PIN, filters)

  @doc """
  Deletes a `AuthShield.Credentials.Schemas.PIN` register.

  ## Exemples:
    ```elixir
    AuthShield.Credentials.PIN.delete(pin)
    ```
  """
  @impl true
  def delete(%PIN{} = pin), do: Repo.delete(pin)

  @doc """
  Deletes a `AuthShield.Credentials.Schemas.PIN` register.

  Similar to `delete/1` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def delete!(%PIN{} = pin), do: Repo.delete!(pin)

  @doc """
  Checks if the given PIN code matches with the credential pin_hash

  It calls the `Argon2` to verify and returns `true` if the PIN
  matches and `false` if the PIN doesn't match.

  ## Exemples:
    ```elixir
    AuthShield.Credentials.PIN.check_pin?(pin, "332456")
    ```
  """
  @spec check_pin?(pin :: PIN.t(), pin_code :: String.t()) :: boolean()
  def check_pin?(%PIN{} = pin, code) when is_binary(code),
    do: Argon2.verify_pass(code, pin.pin_hash)
end
