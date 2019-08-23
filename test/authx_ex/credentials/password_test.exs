defmodule AuthX.Credentials.PasswordTest do
  use AuthX.DataCase, async: true

  alias AuthX.Credentials.Passwords
  alias AuthX.Credentials.Schemas.Password, as: PasswordSchema

  setup do
    {:ok, user: insert(:user)}
  end

  describe "insert/1" do
    setup ctx do
      {:ok, params: params_for(:password) |> Map.put(:user_id, ctx.user.id)}
    end

    test "creates a new password on database", ctx do
      # Inserting password
      assert {:ok, password} = Passwords.insert(ctx.params)
      assert password == Repo.get(PasswordSchema, password.id)
    end

    test "fails if password already exist", ctx do
      # Inserting password
      insert(:password, ctx.params)

      # Inserting duplicated password
      assert {:error, changeset} = Passwords.insert(ctx.params)
      assert %{user_id: ["has already been taken"]} == errors_on(changeset)
    end

    test "fails if params are empty" do
      assert {:error, changeset} = Passwords.insert(%{})
      assert %{password: ["can't be blank"], user_id: ["can't be blank"]} == errors_on(changeset)
    end

    test "fails if params are invalid" do
      assert {:error, changeset} = Passwords.insert(%{password: 1, user_id: 1})
      assert %{password: ["is invalid"], user_id: ["is invalid"]} == errors_on(changeset)
    end
  end

  describe "insert!/1" do
    setup ctx do
      {:ok, params: params_for(:password) |> Map.put(:user_id, ctx.user.id)}
    end

    test "creates a new password on database", ctx do
      # Inserting password
      assert password = Passwords.insert!(ctx.params)
      assert password == Repo.get(PasswordSchema, password.id)
    end

    test "fails if password already exist", ctx do
      assert_raise Ecto.InvalidChangesetError, fn ->
        # Inserting password
        assert _password = insert(:password, ctx.params)

        # Inserting duplicated user
        assert Passwords.insert!(ctx.params)
      end
    end

    test "fails if params are empty" do
      assert_raise Ecto.InvalidChangesetError, fn -> Passwords.insert!(%{}) end
    end

    test "fails if params are invalid" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        Passwords.insert!(%{name: 1, description: 1})
      end
    end
  end

  describe "list/1" do
    setup do
      users = insert_list(3, :user)

      pins =
        Enum.map(users, &insert(:password, params_for(:password) |> Map.put(:user_id, &1.id)))

      {:ok, users: users, ids: Enum.map(pins, & &1.id)}
    end

    test "return a list of password", ctx do
      assert pins = Passwords.list()
      assert true == Enum.all?(pins, &(&1.id in ctx.ids))
    end

    test "can filter list by database fields", ctx do
      assert [user | _] = ctx.users
      assert [password] = Passwords.list(user_id: user.id)
      assert password.id in ctx.ids
    end
  end

  describe "get_by/1" do
    setup ctx do
      params = params_for(:password) |> Map.put(:user_id, ctx.user.id)
      {:ok, password: insert(:password, params)}
    end

    test "can get password by database fields", ctx do
      assert password = Passwords.get_by(user_id: ctx.user.id)
      assert password.id == ctx.password.id
    end
  end

  describe "get_by!/1" do
    setup ctx do
      params = params_for(:password) |> Map.put(:user_id, ctx.user.id)
      {:ok, password: insert(:password, params)}
    end

    test "can get password by database fields", ctx do
      assert password = Passwords.get_by!(user_id: ctx.user.id)
      assert password.id == ctx.password.id
    end
  end

  describe "delete/1" do
    setup ctx do
      params = params_for(:password) |> Map.put(:user_id, ctx.user.id)
      {:ok, password: insert(:password, params)}
    end

    test "deletes a password on database", ctx do
      assert {:ok, _password} = Passwords.delete(ctx.password)
      assert nil == Repo.get(PasswordSchema, ctx.password.id)
    end
  end

  describe "delete!/1" do
    setup ctx do
      params = params_for(:password) |> Map.put(:user_id, ctx.user.id)
      {:ok, password: insert(:password, params)}
    end

    test "deletes a password on database", ctx do
      assert _password = Passwords.delete!(ctx.password)
      assert nil == Repo.get(PasswordSchema, ctx.password.id)
    end

    test "fails if password dont exist", ctx do
      assert Repo.delete(ctx.password)
      assert_raise Ecto.StaleEntryError, fn -> Passwords.delete!(ctx.password) end
    end
  end

  describe "check_password?/2" do
    setup ctx do
      params = params_for(:password) |> Map.put(:user_id, ctx.user.id)
      {:ok, password: insert(:password, params)}
    end

    test "returns true if the given code is equal to the saved hash", ctx do
      assert true == Passwords.check_password?(ctx.password, "My_passw@rd1")
    end

    test "returns false if the given code is equal to the generated", ctx do
      assert false == Passwords.check_password?(ctx.password, "ZdiRoKEGwKFMEWUqDwDq")
    end
  end
end
