defmodule AuthX.Repo.Migrations.CreatePasswordCredential do
  use Ecto.Migration

  def change do
    create table(:password_credentials, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:password_hash, :string, null: false)

      add(:user_id, references(:users, type: :uuid), null: false)

      timestamps()
    end

    create(unique_index(:password_credentials, [:user_id]))
  end
end
