defmodule AuthShield.Repo.Migrations.CreateAuthShieldTables do
  use Ecto.Migration

  def up do
    AuthShield.Migrations.up()
  end

  def down do
    AuthShield.Migrations.down()
  end
end
