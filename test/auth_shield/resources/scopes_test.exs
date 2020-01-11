defmodule AuthShield.Resources.ScopesTest do
  use AuthShield.DataCase, async: true

  alias AuthShield.Resources.Schemas.Scope
  alias AuthShield.Resources.Scopes

  describe "insert/1" do
    test "creates a new scope on database" do
      assert {:ok, scope} = Scopes.insert(params_for(:scope))
      assert scope == Repo.get(Scope, scope.id)
    end

    test "fails if scope already exist" do
      assert {:error, changeset} =
               insert(:scope)
               |> Map.from_struct()
               |> Scopes.insert()

      assert %{name: ["has already been taken"]} == errors_on(changeset)
    end

    test "fails if params are empty" do
      assert {:error, changeset} = Scopes.insert(%{})
      assert %{name: ["can't be blank"]} == errors_on(changeset)
    end

    test "fails if params are invalid" do
      assert {:error, changeset} = Scopes.insert(%{name: 1, description: 1})
      assert %{name: ["is invalid"], description: ["is invalid"]} == errors_on(changeset)
    end
  end

  describe "insert!/1" do
    test "creates a new scope on database" do
      assert scope = Scopes.insert!(params_for(:scope))
      assert scope == Repo.get(Scope, scope.id)
    end

    test "fails if scope already exist" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        insert(:scope)
        |> Map.from_struct()
        |> Scopes.insert!()
      end
    end

    test "fails if params are empty" do
      assert_raise Ecto.InvalidChangesetError, fn -> Scopes.insert!(%{}) end
    end

    test "fails if params are invalid" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        Scopes.insert!(%{name: 1, description: 1})
      end
    end
  end

  describe "update/2" do
    setup do
      {:ok, scope: insert(:scope)}
    end

    test "updates a scope on database", ctx do
      assert {:ok, scope} = Scopes.update(ctx.scope, params_for(:scope))
      assert scope == Repo.get(Scope, ctx.scope.id)
      assert scope != ctx.scope
    end

    test "fails if params are invalid", ctx do
      assert {:error, changeset} = Scopes.update(ctx.scope, %{name: 1, description: 1})
      assert %{name: ["is invalid"], description: ["is invalid"]} == errors_on(changeset)
    end
  end

  describe "update!/2" do
    setup do
      {:ok, scope: insert(:scope)}
    end

    test "updates a scope on database", ctx do
      assert scope = Scopes.update!(ctx.scope, params_for(:scope))
      assert scope == Repo.get(Scope, ctx.scope.id)
      assert scope != ctx.scope
    end

    test "fails if params are invalid", ctx do
      assert_raise Ecto.InvalidChangesetError, fn ->
        Scopes.update!(ctx.scope, %{name: 1, description: 1})
      end
    end
  end

  describe "list/1" do
    setup do
      {:ok, scopes: insert_list(3, :scope)}
    end

    test "return a list of scopes", ctx do
      assert scopes = Scopes.list()
      assert scopes == ctx.scopes
    end

    test "can filter list by database fields", ctx do
      assert [scope | _] = ctx.scopes
      assert [scope] == Scopes.list(name: scope.name)
    end
  end

  describe "get_by/1" do
    setup do
      {:ok, scope: insert(:scope)}
    end

    test "can get scope by database fields", ctx do
      assert ctx.scope == Scopes.get_by(name: ctx.scope.name)
    end
  end

  describe "get_by!/1" do
    setup do
      {:ok, scope: insert(:scope)}
    end

    test "can get scope by database fields", ctx do
      assert ctx.scope == Scopes.get_by!(name: ctx.scope.name)
    end
  end

  describe "delete/1" do
    setup do
      {:ok, scope: insert(:scope)}
    end

    test "deletes a scope on database", ctx do
      assert {:ok, _scope} = Scopes.delete(ctx.scope)
      assert nil == Repo.get(Scope, ctx.scope.id)
    end
  end

  describe "delete!/1" do
    setup do
      {:ok, scope: insert(:scope)}
    end

    test "deletes a scope on database", ctx do
      assert _scope = Scopes.delete!(ctx.scope)
      assert nil == Repo.get(Scope, ctx.scope.id)
    end

    test "fails if scope dont exist", ctx do
      assert Repo.delete(ctx.scope)
      assert_raise Ecto.StaleEntryError, fn -> Scopes.delete!(ctx.scope) end
    end
  end

  describe "change_applications/2" do
    setup do
      {:ok, scope: insert(:scope), applications: insert_list(10, :application)}
    end

    test "changes the scope applications", ctx do
      assert {:ok, scope} = Scopes.change_applications(ctx.scope, ctx.applications)
      assert scope.applications == Repo.preload(ctx.scope, :applications).applications
    end
  end

  describe "change_applications!/2" do
    setup do
      {:ok, scope: insert(:scope), applications: insert_list(10, :application)}
    end

    test "changes the scope applications", ctx do
      assert scope = Scopes.change_applications!(ctx.scope, ctx.applications)
      assert scope.applications == Repo.preload(ctx.scope, :applications).applications
    end

    test "fails if params are invalid", ctx do
      assert_raise Ecto.ChangeError, fn ->
        Scopes.change_applications!(ctx.scope, [%{name: 1, description: 1}])
      end
    end
  end
end
