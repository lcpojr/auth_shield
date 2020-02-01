defmodule AuthShield.Credentials.PublicKey do
  @moduledoc """
  A public key is a non sensible key used in asymetric cryptography.

  In asymetric cryptography we use a pair of keys, a private that is stored by
  the owner application and a public that can be shared with any services
  that needs to authenticate the data.

  This module implements an interface to deal with database transactions
  as inserts, updates, deletes, etc.
  """

  require Ecto.Query

  alias AuthShield.Credentials.Schemas.PublicKey
  alias AuthShield.Repo

  @behaviour AuthShield.Credentials.Behaviour

  @doc """
  Creates a new `AuthShield.Credentials.Schemas.PublicKey` register.

  ## Exemples:
    ```elixir
    AuthShield.Credentials.PublicKey.insert(%{
      application_id: "ecb4c67d-6380-4984-ae04-1563e885d59e",
      format: "pem",
      key: "MY_PUBLIC_KEY"
    })
    ```
  """
  @impl true
  def insert(params) when is_map(params) do
    %PublicKey{}
    |> PublicKey.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Creates a new `AuthShield.Credentials.Schemas.PublicKey` register.

  Similar to `insert/1` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def insert!(params) when is_map(params) do
    %PublicKey{}
    |> PublicKey.changeset(params)
    |> Repo.insert!()
  end

  @doc """
  Returns a list of `AuthShield.Credentials.Schemas.PublicKey` by its filters

  ## Exemples:
    ```elixir
    # Getting the all list
    AuthShield.Credentials.PublicKey.list()

    # Filtering the list by field
    AuthShield.Credentials.PublicKey.list(application_id: "ecb4c67d-6380-4984-ae04-1563e885d59e")
    ```
  """
  @impl true
  def list(filters \\ []) when is_list(filters) do
    PublicKey
    |> Ecto.Query.where([p], ^filters)
    |> Repo.all()
  end

  @doc """
  Gets a `AuthShield.Credentials.Schemas.PublicKey` register by its filters.

  ## Exemples:
    ```elixir
    AuthShield.Credentials.PublicKey.get_by(application_id: "ecb4c67d-6380-4984-ae04-1563e885d59e")
    ```
  """
  @impl true
  def get_by(filters) when is_list(filters), do: Repo.get_by(PublicKey, filters)

  @doc """
  Gets a `AuthShield.Credentials.Schemas.PublicKey` register by its filters.

  Similar to `get_by/1` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def get_by!(filters) when is_list(filters), do: Repo.get_by!(PublicKey, filters)

  @doc """
  Deletes a `AuthShield.Credentials.Schemas.PublicKey` register.

  ## Exemples:
    ```elixir
    AuthShield.Credentials.PublicKey.delete(public_key)
    ```
  """
  @impl true
  def delete(%PublicKey{} = public_key), do: Repo.delete(public_key)

  @doc """
  Deletes a `AuthShield.Credentials.Schemas.PublicKey` register.

  Similar to `delete/1` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def delete!(%PublicKey{} = public_key), do: Repo.delete!(public_key)
end
