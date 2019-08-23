defmodule AuthX.Resources.PermissionsTest do
  use AuthX.DataCase, async: true

  alias AuthX.Resources.Permissions
  alias AuthX.Resources.Schemas.Permission

  describe "insert/1" do
    test "creates a new permission on database" do
      assert {:ok, permission} = Permissions.insert(params_for(:permission))
      assert permission == Repo.get(Permission, permission.id)
    end

    test "fails if permission already exist" do
      assert {:error, changeset} =
               insert(:permission)
               |> Map.from_struct()
               |> Permissions.insert()

      assert %{name: ["has already been taken"]} == errors_on(changeset)
    end

    test "fails if params are empty" do
      assert {:error, changeset} = Permissions.insert(%{})
      assert %{name: ["can't be blank"]} == errors_on(changeset)
    end

    test "fails if params are invalid" do
      assert {:error, changeset} = Permissions.insert(%{name: 1, description: 1})
      assert %{name: ["is invalid"], description: ["is invalid"]} == errors_on(changeset)
    end
  end

  describe "insert!/1" do
    test "creates a new permission on database" do
      assert permission = Permissions.insert!(params_for(:permission))
      assert permission == Repo.get(Permission, permission.id)
    end

    test "fails if permission already exist" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        insert(:permission)
        |> Map.from_struct()
        |> Permissions.insert!()
      end
    end

    test "fails if params are empty" do
      assert_raise Ecto.InvalidChangesetError, fn -> Permissions.insert!(%{}) end
    end

    test "fails if params are invalid" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        Permissions.insert!(%{name: 1, description: 1})
      end
    end
  end

  describe "update/2" do
    setup do
      {:ok, permission: insert(:permission)}
    end

    test "updates a permission on database", ctx do
      assert {:ok, permission} = Permissions.update(ctx.permission, params_for(:permission))
      assert permission == Repo.get(Permission, ctx.permission.id)
      assert permission != ctx.permission
    end

    test "fails if params are invalid", ctx do
      assert {:error, changeset} = Permissions.update(ctx.permission, %{name: 1, description: 1})
      assert %{name: ["is invalid"], description: ["is invalid"]} == errors_on(changeset)
    end
  end

  describe "update!/2" do
    setup do
      {:ok, permission: insert(:permission)}
    end

    test "updates a permission on database", ctx do
      assert permission = Permissions.update!(ctx.permission, params_for(:permission))
      assert permission == Repo.get(Permission, ctx.permission.id)
      assert permission != ctx.permission
    end

    test "fails if params are invalid", ctx do
      assert_raise Ecto.InvalidChangesetError, fn ->
        Permissions.update!(ctx.permission, %{name: 1, description: 1})
      end
    end
  end

  describe "list/1" do
    setup do
      {:ok, permissions: insert_list(3, :permission)}
    end

    test "return a list of permissions", ctx do
      assert permissions = Permissions.list()
      assert permissions == ctx.permissions
    end

    test "can filter list by database fields", ctx do
      assert [permission | _] = ctx.permissions
      assert [permission] == Permissions.list(name: permission.name)
    end
  end

  describe "get_by/1" do
    setup do
      {:ok, permission: insert(:permission)}
    end

    test "can get permission by database fields", ctx do
      assert ctx.permission == Permissions.get_by(name: ctx.permission.name)
    end
  end

  describe "get_by!/1" do
    setup do
      {:ok, permission: insert(:permission)}
    end

    test "can get permission by database fields", ctx do
      assert ctx.permission == Permissions.get_by!(name: ctx.permission.name)
    end
  end

  describe "delete/1" do
    setup do
      {:ok, permission: insert(:permission)}
    end

    test "deletes a permission on database", ctx do
      assert {:ok, _permission} = Permissions.delete(ctx.permission)
      assert nil == Repo.get(Permission, ctx.permission.id)
    end
  end

  describe "delete!/1" do
    setup do
      {:ok, permission: insert(:permission)}
    end

    test "deletes a permission on database", ctx do
      assert _permission = Permissions.delete!(ctx.permission)
      assert nil == Repo.get(Permission, ctx.permission.id)
    end

    test "fails if permission dont exist", ctx do
      assert Repo.delete(ctx.permission)
      assert_raise Ecto.StaleEntryError, fn -> Permissions.delete!(ctx.permission) end
    end
  end
end
