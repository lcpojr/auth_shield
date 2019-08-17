defmodule AuthX.Resources.RolesTest do
  use AuthX.DataCase, async: true

  alias AuthX.Resources.Roles
  alias AuthX.Resources.Schemas.Role

  describe "insert/1" do
    test "creates a new role on database" do
      assert {:ok, role} = Roles.insert(params_for(:role))
      assert role == Repo.get(Role, role.id)
    end

    test "fails if role already exist" do
      assert {:error, changeset} =
               insert(:role)
               |> Map.from_struct()
               |> Roles.insert()

      assert %{name: ["has already been taken"]} == errors_on(changeset)
    end

    test "fails if params are empty" do
      assert {:error, changeset} = Roles.insert(%{})
      assert %{name: ["can't be blank"]} == errors_on(changeset)
    end

    test "fails if params are invalid" do
      assert {:error, changeset} = Roles.insert(%{name: 1, description: 1})
      assert %{name: ["is invalid"], description: ["is invalid"]} == errors_on(changeset)
    end
  end

  describe "insert!/1" do
    test "creates a new role on database" do
      assert role = Roles.insert!(params_for(:role))
      assert role == Repo.get(Role, role.id)
    end

    test "fails if role already exist" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        insert(:role)
        |> Map.from_struct()
        |> Roles.insert!()
      end
    end

    test "fails if params are empty" do
      assert_raise Ecto.InvalidChangesetError, fn -> Roles.insert!(%{}) end
    end

    test "fails if params are invalid" do
      assert_raise Ecto.InvalidChangesetError, fn -> Roles.insert!(%{name: 1, description: 1}) end
    end
  end

  describe "update/2" do
    setup do
      {:ok, role: insert(:role)}
    end

    test "updates a role on database", ctx do
      assert {:ok, role} = Roles.update(ctx.role, params_for(:role))
      assert role == Repo.get(Role, ctx.role.id)
      assert role != ctx.role
    end

    test "fails if params are invalid", ctx do
      assert {:error, changeset} = Roles.update(ctx.role, %{name: 1, description: 1})
      assert %{name: ["is invalid"], description: ["is invalid"]} == errors_on(changeset)
    end
  end

  describe "update!/2" do
    setup do
      {:ok, role: insert(:role)}
    end

    test "updates a role on database", ctx do
      assert role = Roles.update!(ctx.role, params_for(:role))
      assert role == Repo.get(Role, ctx.role.id)
      assert role != ctx.role
    end

    test "fails if params are invalid", ctx do
      assert_raise Ecto.InvalidChangesetError, fn ->
        Roles.update!(ctx.role, %{name: 1, description: 1})
      end
    end
  end

  describe "list/1" do
    setup do
      {:ok, roles: insert_list(10, :role)}
    end

    test "return a list of roles", ctx do
      assert roles = Roles.list()
      assert roles == ctx.roles
    end

    test "can filter list by database fields", ctx do
      assert [role | _] = ctx.roles
      assert [role] == Roles.list(name: role.name)
    end
  end

  describe "get_by/1" do
    setup do
      {:ok, role: insert(:role)}
    end

    test "can get role by database fields", ctx do
      assert ctx.role == Roles.get_by(name: ctx.role.name)
    end
  end

  describe "delete/1" do
    setup do
      {:ok, role: insert(:role)}
    end

    test "deletes a role on database", ctx do
      assert {:ok, _role} = Roles.delete(ctx.role)
      assert nil == Repo.get(Role, ctx.role.id)
    end
  end

  describe "delete!/1" do
    setup do
      {:ok, role: insert(:role)}
    end

    test "deletes a role on database", ctx do
      assert _role = Roles.delete!(ctx.role)
      assert nil == Repo.get(Role, ctx.role.id)
    end

    test "fails if role dont exist", ctx do
      assert Repo.delete(ctx.role)
      assert_raise Ecto.StaleEntryError, fn -> Roles.delete!(ctx.role) end
    end
  end

  describe "change_permissions/2" do
    setup do
      {:ok, role: insert(:role), permissions: insert_list(10, :permission)}
    end

    test "changes the role permissions", ctx do
      assert {:ok, role} = Roles.change_permissions(ctx.role, ctx.permissions)
      assert role.permissions == Repo.preload(ctx.role, :permissions).permissions
    end
  end

  describe "change_permissions!/2" do
    setup do
      {:ok, role: insert(:role), permissions: insert_list(10, :permission)}
    end

    test "changes the role permissions", ctx do
      assert role = Roles.change_permissions!(ctx.role, ctx.permissions)
      assert role.permissions == Repo.preload(ctx.role, :permissions).permissions
    end

    test "fails if params are invalid", ctx do
      assert_raise Ecto.ChangeError, fn ->
        Roles.change_permissions!(ctx.role, [%{name: 1, description: 1}])
      end
    end
  end
end
