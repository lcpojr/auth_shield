defmodule AuthX.Resources.Roles do
  @moduledoc """
  Implements an interface to deal with database transactions as inserts, updates, deletes, etc.
  """

  alias AuthX.Resources.Schemas.Role
  alias AuthX.Repo

  @typedoc "Transactional responses of success"
  @type success_response :: {:ok, Role.t()}

  @typedoc "Transactional responses of failed"
  @type failed_response :: {:error, Ecto.Changeset.t()}

  @doc "Creates a new `Role` register."
  @spec insert(params :: map()) :: success_response() | failed_response()
  def insert(params) when is_map(params) do
    %Role{}
    |> Role.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Creates a new `__MODULE__` register.

  Similar to `insert/1` but raises if the changeset is invalid.
  """
  @spec insert!(params :: map()) :: success_response() | no_return()
  def insert!(params) when is_map(params) do
    %Role{}
    |> Role.changeset(params)
    |> Repo.insert!()
  end

  @doc "Updates a `Role` register."
  @spec update(role :: Role.t(), params :: map()) :: success_response() | failed_response()
  def update(%Role{} = role, params) when is_map(params) do
    role
    |> Role.changeset(params)
    |> Repo.update()
  end

  @doc """
  Updates a `Role` register.

  Similar to `update/2` but raises if the changeset is invalid.
  """
  @spec update!(role :: Role.t(), params :: map()) :: success_response() | no_return()
  def update!(%Role{} = role, params) when is_map(params) do
    role
    |> Role.changeset(params)
    |> Repo.update()
  end

  @doc "Gets a `Role` register by its filters."
  @spec get_by(filters :: keyword()) :: Role.t() | nil
  def get_by(filters) when is_list(filters), do: Repo.get_by(Role, filters)

  @doc """
  Gets a `Role` register by its filters.

  Similar to `get_by/1` but raises `Ecto.NoResultsError` if no record was found.
  Raises if more than one entry.
  """
  @spec get_by!(filters :: keyword()) :: Role.t() | no_return()
  def get_by!(filters) when is_list(filters), do: Repo.get_by(Role, filters)

  @doc "Deletes a `Role` register."
  @spec delete(role :: Role.t()) :: success_response() | failed_response()
  def delete(%Role{} = role), do: Repo.delete(role)

  @doc """
  Deletes a `Role` register.

  Similar to `delete/1` but raises `Ecto.NoResultsError` if no record was found.
  Raises if changeset is invalid.
  """
  @spec delete!(role :: Role.t()) :: success_response() | no_return()
  def delete!(%Role{} = role), do: Repo.delete!(role)
end
