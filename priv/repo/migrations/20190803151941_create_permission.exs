defmodule AuthX.Repo.Migrations.CreatePermission do
  use Ecto.Migration

  def change do
    create table(:permissions, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string, null: false)
      add(:description, :text)

      timestamps()
    end

    create(unique_index(:permissions, [:name]))
  end
end
