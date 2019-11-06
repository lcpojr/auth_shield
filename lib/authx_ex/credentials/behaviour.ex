defmodule AuthShield.Credentials.Behaviour do
  @moduledoc "AuthShield Credentials behaviour."

  alias AuthShield.Credentials.Schemas.{Password, PIN, TOTP}

  @typedoc "Credential schemas types"
  @type credential :: Password.t() | PIN.t() | TOTP.t()

  @typedoc "Transactional responses of success"
  @type success_response :: {:ok, credential()}

  @typedoc "Transactional responses of failed"
  @type failed_response :: {:error, Ecto.Changeset.t()}

  @callback insert(params :: map()) :: success_response() | failed_response()
  @callback insert!(params :: map()) :: credential() | no_return()

  @callback list(filters :: keyword()) :: list(credential())

  @callback get_by(filters :: keyword()) :: credential() | nil
  @callback get_by!(filters :: keyword()) :: credential() | no_return()

  @callback delete(model :: credential()) :: success_response() | failed_response()
  @callback delete!(model :: credential()) :: credential() | no_return()
end
