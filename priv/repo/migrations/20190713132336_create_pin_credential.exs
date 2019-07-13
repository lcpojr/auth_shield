defmodule AuthX.Repo.Migrations.CreatePinCredential do
  use Ecto.Migration

  def change do
    create table(:pin_credentials, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:pin_hash, :string, null: false)

      add(:user_id, references(:users, type: :uuid), null: false)

      timestamps()
    end

    create(unique_index(:pin_credentials, [:user_id]))
  end
end
