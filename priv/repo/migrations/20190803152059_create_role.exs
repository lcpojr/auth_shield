defmodule AuthX.Repo.Migrations.CreateRole do
  use Ecto.Migration

  def change do
    create table(:roles, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string, null: false)
      add(:description, :text)

      timestamps()
    end

    create(unique_index(:roles, [:name]))
  end
end
