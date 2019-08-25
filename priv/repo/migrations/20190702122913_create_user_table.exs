defmodule AuthX.Repo.Migrations.CreateUserTable do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:first_name, :string, null: false)
      add(:last_name, :string)
      add(:email, :string, null: false)
      add(:is_active, :boolean, null: false, default: false)

      timestamps()
    end

    create(unique_index(:users, [:email]))
  end
end
