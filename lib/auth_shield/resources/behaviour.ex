defmodule AuthShield.Resources.Behaviour do
  @moduledoc "AuthShield Resources behaviour."

  alias AuthShield.Resources.Schemas.{Application, Permission, Role, Scope, User}

  @typedoc "Resource schemas types"
  @type resource :: Application.t() | Permission.t() | Role.t() | Scope.t() | User.t()

  @typedoc "Transactional responses of success"
  @type success_response :: {:ok, resource()}

  @typedoc "Transactional responses of failed"
  @type failed_response :: {:error, Ecto.Changeset.t()}

  @callback insert(params :: map()) :: success_response() | failed_response()
  @callback insert!(params :: map()) :: resource() | no_return()

  @callback update(model :: resource(), params :: map()) :: success_response() | failed_response()
  @callback update!(model :: resource(), params :: map()) :: resource() | no_return()

  @callback list(filters :: keyword()) :: list(resource())

  @callback get_by(filters :: keyword()) :: resource() | nil
  @callback get_by!(filters :: keyword()) :: resource() | no_return()

  @callback delete(model :: resource()) :: success_response() | failed_response()
  @callback delete!(model :: resource()) :: resource() | no_return()
end
