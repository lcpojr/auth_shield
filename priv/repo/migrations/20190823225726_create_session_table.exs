defmodule AuthX.Repo.Migrations.CreateSessionTable do
  use Ecto.Migration

  def change do
    create table(:sessions, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:remote_ip, :string, null: false)
      add(:user_agent, :string, null: false)
      add(:expiration, :naive_datetime, null: false)
      add(:login_at, :naive_datetime, null: false)
      add(:logout_at, :naive_datetime)

      add(:user_id, references(:users, type: :uuid), null: false)

      timestamps()
    end

    create(index(:sessions, [:user_id]))
  end
end
