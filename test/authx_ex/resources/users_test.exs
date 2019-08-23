defmodule AuthX.Resources.UsersTest do
  use AuthX.DataCase, async: true

  alias AuthX.Resources.Schemas.User
  alias AuthX.Resources.Users

  describe "insert/1" do
    test "creates a new user on database" do
      # Preparing params
      assert params = Map.put(params_for(:user), :password_credential, params_for(:password))

      # Inserting user
      assert {:ok, user} = Users.insert(params)
      assert user == Repo.get(User, user.id) |> Repo.preload(:password_credential)
    end

    test "fails if user already exist" do
      # Preparing params
      assert params = Map.put(params_for(:user), :password_credential, params_for(:password))

      # Inserting user
      assert _user = insert(:user, params)

      # Inserting duplicated user
      assert {:error, changeset} = Users.insert(params)
      assert %{email: ["has already been taken"]} == errors_on(changeset)
    end

    test "fails if params are empty" do
      assert {:error, changeset} = Users.insert(%{})

      assert %{
               email: ["can't be blank"],
               first_name: ["can't be blank"],
               password_credential: ["can't be blank"]
             } == errors_on(changeset)
    end

    test "fails if params are invalid" do
      assert {:error, changeset} =
               Users.insert(%{first_name: 1, email: 1, password_credential: 1})

      assert %{
               email: ["is invalid"],
               first_name: ["is invalid"],
               password_credential: ["is invalid"]
             } == errors_on(changeset)
    end
  end

  describe "insert!/1" do
    test "creates a new user on database" do
      # Preparing params
      assert params = Map.put(params_for(:user), :password_credential, params_for(:password))

      # Inserting user
      assert user = Users.insert!(params)
      assert user == User |> Repo.get(user.id) |> Repo.preload(:password_credential)
    end

    test "fails if user already exist" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        # Preparing params
        assert params = Map.put(params_for(:user), :password_credential, params_for(:password))

        # Inserting user
        assert _user = insert(:user, params)

        # Inserting duplicated user
        assert Users.insert!(params)
      end
    end

    test "fails if params are empty" do
      assert_raise Ecto.InvalidChangesetError, fn -> Users.insert!(%{}) end
    end

    test "fails if params are invalid" do
      assert_raise Ecto.InvalidChangesetError, fn -> Users.insert!(%{name: 1, description: 1}) end
    end
  end

  describe "update/2" do
    setup do
      {:ok, user: insert(:user)}
    end

    test "updates a user on database", ctx do
      assert {:ok, user} = Users.update(ctx.user, params_for(:user))
      assert user != ctx.user
    end

    test "fails if params are invalid", ctx do
      assert {:error, changeset} =
               Users.update(ctx.user, %{first_name: 1, last_name: 1, email: 1})

      assert %{email: ["is invalid"], first_name: ["is invalid"], last_name: ["is invalid"]} ==
               errors_on(changeset)
    end
  end

  describe "update!/2" do
    setup do
      {:ok, user: insert(:user)}
    end

    test "updates a user on database", ctx do
      assert {:ok, user} = Users.update(ctx.user, params_for(:user))
      assert user != ctx.user
    end

    test "fails if params are invalid", ctx do
      assert_raise Ecto.InvalidChangesetError, fn ->
        Users.update!(ctx.user, %{first_name: 1, last_name: 1, email: 1})
      end
    end
  end

  describe "list/1" do
    setup do
      {:ok, users: insert_list(3, :user)}
    end

    test "return a list of Users", ctx do
      assert users = Users.list()
      assert users == ctx.users
    end

    test "can filter list by database fields", ctx do
      assert [user1 | _] = ctx.users
      assert [user2] = Users.list(email: user1.email)
      assert user1.id == user2.id
    end
  end

  describe "get_by/1" do
    setup do
      {:ok, user: insert(:user)}
    end

    test "can get user by database fields", ctx do
      assert ctx.user == Users.get_by(email: ctx.user.email)
    end
  end

  describe "get_by!/1" do
    setup do
      {:ok, user: insert(:user)}
    end

    test "can get user by database fields", ctx do
      assert ctx.user == Users.get_by!(email: ctx.user.email)
    end
  end

  describe "delete/1" do
    setup do
      {:ok, user: insert(:user)}
    end

    test "deletes a user on database", ctx do
      assert {:ok, _user} = Users.delete(ctx.user)
      assert nil == Repo.get(User, ctx.user.id)
    end
  end

  describe "delete!/1" do
    setup do
      {:ok, user: insert(:user)}
    end

    test "deletes a user on database", ctx do
      assert _user = Users.delete!(ctx.user)
      assert nil == Repo.get(User, ctx.user.id)
    end

    test "fails if user dont exist", ctx do
      assert Repo.delete(ctx.user)
      assert_raise Ecto.StaleEntryError, fn -> Users.delete!(ctx.user) end
    end
  end

  describe "change_roles/2" do
    setup do
      {:ok, user: insert(:user), roles: insert_list(10, :role)}
    end

    test "changes the user roles", ctx do
      assert {:ok, user} = Users.change_roles(ctx.user, ctx.roles)
      assert user.roles == Repo.preload(ctx.user, :roles).roles
    end
  end

  describe "change_roles!/2" do
    setup do
      {:ok, user: insert(:user), roles: insert_list(10, :role)}
    end

    test "changes the user roles", ctx do
      assert user = Users.change_roles!(ctx.user, ctx.roles)
      assert user.roles == Repo.preload(ctx.user, :roles).roles
    end

    test "fails if params are invalid", ctx do
      assert_raise Ecto.ChangeError, fn ->
        Users.change_roles!(ctx.user, [%{name: 1, description: 1}])
      end
    end
  end

  describe "preload/2" do
    setup do
      {:ok, user: insert(:user)}
    end

    test "preloads user data", ctx do
      assert user = Users.preload(ctx.user, [:password_credential])
      assert user == Repo.preload(user, [:password_credential])
    end
  end
end
