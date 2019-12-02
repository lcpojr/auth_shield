defmodule AuthShield.Migrations do
  @moduledoc false

  use Ecto.Migration

  def up do
    create_user()
    create_password_credential()
    create_pin_credential()
    create_totp_credential()
    create_permission()
    create_role()
    create_role_permition()
    create_user_role()
    create_session()
  end

  def down do
    drop_user()
    drop_password_credential()
    drop_pin_credential()
    drop_totp_credential()
    drop_permission()
    drop_role()
    drop_role_permition()
    drop_user_role()
    drop_session()
  end

  # CREATING TABLES

  defp create_user do
    create_if_not_exists table(:users, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:first_name, :string, null: false)
      add(:last_name, :string)
      add(:email, :string, null: false)
      add(:is_active, :boolean, null: false, default: false)

      timestamps()
    end

    create_if_not_exists(unique_index(:users, [:email]))
  end

  defp create_password_credential do
    create_if_not_exists table(:password_credentials, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:password_hash, :string, null: false)
      add(:algorithm, :string, null: false, default: "argon2")

      add(:user_id, references(:users, type: :uuid), null: false)

      timestamps()
    end

    create_if_not_exists(unique_index(:password_credentials, [:user_id]))
  end

  defp create_pin_credential do
    create_if_not_exists table(:pin_credentials, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:pin_hash, :string, null: false)
      add(:algorithm, :string, null: false, default: "argon2")

      add(:user_id, references(:users, type: :uuid), null: false)

      timestamps()
    end

    create(unique_index(:pin_credentials, [:user_id]))
  end

  defp create_totp_credential do
    create_if_not_exists table(:totp_credentials, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:secret, :string, null: false)
      add(:issuer, :string, null: false)
      add(:digits, :integer, null: false, default: 6)
      add(:period, :integer, null: false, default: 30)
      add(:qrcode_base64, :text, null: false)

      add(:user_id, references(:users, type: :uuid), null: false)

      timestamps()
    end

    create_if_not_exists(unique_index(:totp_credentials, [:user_id]))
  end

  defp create_permission do
    create_if_not_exists table(:permissions, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string, null: false)
      add(:description, :text)

      timestamps()
    end

    create_if_not_exists(unique_index(:permissions, [:name]))
  end

  defp create_role do
    create_if_not_exists table(:roles, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string, null: false)
      add(:description, :text)

      timestamps()
    end

    create_if_not_exists(unique_index(:roles, [:name]))
  end

  defp create_role_permition do
    create_if_not_exists table(:roles_permissions, primary_key: false) do
      add(:role_id, references(:roles, type: :uuid, on_delete: :delete_all), primary_key: true)

      add(:permission_id, references(:permissions, type: :uuid, on_delete: :delete_all),
        primary_key: true
      )

      timestamps()
    end

    create_if_not_exists(index(:roles_permissions, [:role_id]))
    create_if_not_exists(index(:roles_permissions, [:permission_id]))

    create_if_not_exists(
      unique_index(:roles_permissions, [:role_id, :permission_id],
        name: :role_id_permission_id_unique_index
      )
    )
  end

  defp create_user_role do
    create_if_not_exists table(:users_roles, primary_key: false) do
      add(:user_id, references(:users, type: :uuid, on_delete: :delete_all), primary_key: true)
      add(:role_id, references(:roles, type: :uuid, on_delete: :delete_all), primary_key: true)

      timestamps()
    end

    create_if_not_exists(index(:users_roles, [:user_id]))
    create_if_not_exists(index(:users_roles, [:role_id]))

    create_if_not_exists(
      unique_index(:users_roles, [:user_id, :role_id], name: :user_id_role_id_unique_index)
    )
  end

  defp create_session do
    create_if_not_exists table(:sessions, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:remote_ip, :string)
      add(:user_agent, :string)
      add(:expiration, :naive_datetime, null: false)
      add(:login_at, :naive_datetime, null: false)
      add(:logout_at, :naive_datetime)

      add(:user_id, references(:users, type: :uuid), null: false)

      timestamps()
    end

    create_if_not_exists(index(:sessions, [:user_id]))
  end

  # DROPING TABLES

  defp drop_user, do: drop_if_exists(table(:users))
  defp drop_password_credential, do: drop_if_exists(table(:password_credentials))
  defp drop_pin_credential, do: drop_if_exists(table(:pin_credentials))
  defp drop_totp_credential, do: drop_if_exists(table(:totp_credentials))
  defp drop_permission, do: drop_if_exists(table(:permissions))
  defp drop_role, do: drop_if_exists(table(:roles))
  defp drop_role_permition, do: drop_if_exists(table(:roles_permissions))
  defp drop_user_role, do: drop_if_exists(table(:users_roles))
  defp drop_session, do: drop_if_exists(table(:sessions))
end
