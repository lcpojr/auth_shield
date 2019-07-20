defmodule AuthX.Repo.Migrations.CreateTotpCredential do
  use Ecto.Migration

  def change do
    create table(:totp_credentials, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:secret, :string, null: false)
      add(:issuer, :string, null: false)
      add(:digits, :integer, null: false, default: 6)
      add(:period, :integer, null: false, default: 30)
      add(:qrcode_base64, :text, null: false)

      add(:user_id, references(:users, type: :uuid), null: false)

      timestamps()
    end

    create(unique_index(:totp_credentials, [:user_id]))
  end
end
