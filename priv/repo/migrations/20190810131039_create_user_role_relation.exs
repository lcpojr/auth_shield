defmodule AuthX.Repo.Migrations.CreateUserRoleRelation do
  use Ecto.Migration

  def change do
    create table(:users_roles, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:user_id, references(:users, type: :uuid, on_delete: :delete_all), primary_key: true)
      add(:role_id, references(:roles, type: :uuid, on_delete: :delete_all), primary_key: true)

      timestamps()
    end

    create(index(:users_roles, [:user_id]))
    create(index(:users_roles, [:role_id]))

    create(unique_index(:users_roles, [:user_id, :role_id], name: :user_id_role_id_unique_index))
  end
end
