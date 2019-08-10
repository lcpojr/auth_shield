defmodule AuthX.Repo.Migrations.CreateRolePermitionsRelation do
  use Ecto.Migration

  def change do
    create table(:roles_permissions, primary_key: false) do
      add(:role_id, references(:roles, type: :uuid, on_delete: :delete_all), primary_key: true)

      add(:permission_id, references(:permissions, type: :uuid, on_delete: :delete_all),
        primary_key: true
      )

      timestamps()
    end

    create(index(:roles_permissions, [:role_id]))
    create(index(:roles_permissions, [:permission_id]))

    create(
      unique_index(:roles_permissions, [:role_id, :permission_id],
        name: :role_id_permission_id_unique_index
      )
    )
  end
end
