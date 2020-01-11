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
    create_login_attempt()
    create_application()
    create_public_key_credential()
    create_scopes()
    create_application_scopes()
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
    drop_login_attempts()
    drop_application()
    drop_public_key_credential()
    drop_scopes()
    drop_application_scopes()
  end

  # CREATING TABLES

  defp create_user do
    create_if_not_exists table(:users, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:first_name, :string, null: false)
      add(:last_name, :string)
      add(:email, :string, null: false)
      add(:is_active, :boolean, null: false, default: false)
      add(:locked_until, :naive_datetime_usec)

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

  defp create_login_attempt do
    create_if_not_exists table(:login_attempts, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:remote_ip, :string)
      add(:user_agent, :string)
      add(:status, :string, null: false)

      add(:user_id, references(:users, type: :uuid), null: false)

      timestamps()
    end

    create_if_not_exists(index(:login_attempts, [:user_id, :status]))
  end

  defp create_application do
    create_if_not_exists table(:applications, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      add(:description, :text)
      add(:is_active, :boolean, null: false, default: true)
      add(:direct_access_grants_enabled, :boolean, null: false, default: true)

      timestamps()
    end

    create_if_not_exists(unique_index(:applications, [:name]))
  end

  defp create_public_key_credential do
    create_if_not_exists table(:public_key_credentials, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:format, :string, null: false, default: "pem")
      add(:key, :text, null: false)

      add(:application_id, references(:applications, type: :uuid), null: false)

      timestamps()
    end

    create_if_not_exists(unique_index(:public_key_credentials, [:application_id]))
  end

  defp create_scopes do
    create_if_not_exists table(:scopes, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string, null: false)
      add(:description, :text)

      timestamps()
    end

    create_if_not_exists(unique_index(:scopes, [:name]))
  end

  defp create_application_scopes do
    create_if_not_exists table(:applications_scopes, primary_key: false) do
      add(:application_id, references(:applications, type: :uuid, on_delete: :delete_all),
        primary_key: true
      )

      add(:scope_id, references(:scopes, type: :uuid, on_delete: :delete_all), primary_key: true)

      timestamps()
    end

    create_if_not_exists(index(:applications_scopes, [:application_id]))
    create_if_not_exists(index(:applications_scopes, [:scope_id]))

    create_if_not_exists(
      unique_index(:applications_scopes, [:application_id, :scope_id],
        name: :application_id_scope_id_unique_index
      )
    )
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
  defp drop_login_attempts, do: drop_if_exists(table(:login_attempts))
  defp drop_application, do: drop_if_exists(table(:applications))
  defp drop_public_key_credential, do: drop_if_exists(table(:public_key_credentials))
  defp drop_scopes, do: drop_if_exists(table(:scopes))
  defp drop_application_scopes, do: drop_if_exists(table(:applications_scopes))
end
