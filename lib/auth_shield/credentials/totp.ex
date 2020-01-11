defmodule AuthShield.Credentials.TOTP do
  @moduledoc """
  Time-based One-Time Password (TOTP) is an extension of
  the HMAC-based One-time Password algorithm (HOTP) generating
  a one-time password by instead taking uniqueness from the current time.

  It is usually used with mobile applications that receives the secret key and
  generates the code to be used in authentications.

  Thi module implements an interface to deal with database transactions
  as inserts, updates, deletes, etc.
  """

  alias AuthShield.Credentials.Schemas.TOTP
  alias AuthShield.Repo

  require Ecto.Query

  @behaviour AuthShield.Credentials.Behaviour

  @doc """
  Creates a new `AuthShield.Credentials.Schemas.TOTP` register.

  ## Exemples:
    ```elixir
    # Simple insert
    AuthShield.Credentials.TOTP.insert(%{
      user_id: ecb4c67d-6380-4984-ae04-1563e885d59e",
      email: "lucas@gmail.com"
    })

    # All parameters
    AuthShield.Credentials.TOTP.insert(%{
      user_id: ecb4c67d-6380-4984-ae04-1563e885d59e",
      email: "lucas@gmail.com",
      issuer: "MyWebpage",
      digits: 4,
      period: 60
    })
    ```
  """
  @impl true
  def insert(params) when is_map(params) do
    %TOTP{}
    |> TOTP.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Creates a new `AuthShield.Credentials.Schemas.TOTP` register.

  Similar to `insert/1` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def insert!(params) when is_map(params) do
    %TOTP{}
    |> TOTP.changeset(params)
    |> Repo.insert!()
  end

  @doc """
  Returns a list of `AuthShield.Credentials.Schemas.TOTP` by its filters

  ## Exemples:
    ```elixir
    # Getting the all list
    AuthShield.Credentials.TOTP.list()

    # Filtering the list by field
    AuthShield.Credentials.TOTP.list(user_id: "ecb4c67d-6380-4984-ae04-1563e885d59e")
    ```
  """
  @impl true
  def list(filters \\ []) when is_list(filters) do
    TOTP
    |> Ecto.Query.where([t], ^filters)
    |> Repo.all()
  end

  @doc """
  Gets a `AuthShield.Credentials.Schemas.TOTP` register by its filters.

  ## Exemples:
    ```elixir
    AuthShield.Credentials.TOTP.get_by(user_id: "ecb4c67d-6380-4984-ae04-1563e885d59e")
    ```
  """
  @impl true
  def get_by(filters) when is_list(filters), do: Repo.get_by(TOTP, filters)

  @doc """
  Gets a `AuthShield.Credentials.Schemas.TOTP` register by its filters.

  Similar to `get_by/1` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def get_by!(filters) when is_list(filters), do: Repo.get_by!(TOTP, filters)

  @doc """
  Deletes a `AuthShield.Credentials.Schemas.TOTP` register.

  ## Exemples:
    ```elixir
    AuthShield.Credentials.TOTP.delete(totp)
    ```
  """
  @impl true
  def delete(%TOTP{} = totp), do: Repo.delete(totp)

  @doc """
  Deletes a `AuthShield.Credentials.Schemas.TOTP` register.

  Similar to `delete/1` but returns the struct or raises if the changeset is invalid.
  """
  @impl true
  def delete!(%TOTP{} = totp), do: Repo.delete!(totp)

  @doc """
  Checks if the given TOTP code matches the generated one.

  ## Exemples:
    ```elixir
    # Using default timestamp
    AuthShield.Credentials.TOTP.check_pin?(totp, "332456")

    # Defining timestamp
    AuthShield.Credentials.TOTP.check_pin?(totp, "332456", ~N[2000-01-01 23:00:07])
    ```
  """
  @spec check_totp?(totp :: TOTP.t(), totp_code :: String.t(), now :: DateTime.t()) :: boolean()
  def check_totp?(%TOTP{} = totp, code, now \\ NaiveDateTime.utc_now()) when is_binary(code) do
    credential_totp = TOTP.generate_totp(totp.secret, totp.period, totp.digits, now)
    if credential_totp == code, do: true, else: false
  end
end
