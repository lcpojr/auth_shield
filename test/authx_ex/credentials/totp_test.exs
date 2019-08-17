defmodule AuthX.Credentials.TOTPTest do
  use AuthX.DataCase, async: true

  alias AuthX.Credentials.Schemas.TOTP, as: TOTPSchema
  alias AuthX.Credentials.TOTP

  setup do
    {:ok, user: insert(:user)}
  end

  describe "insert/1" do
    setup ctx do
      {:ok, params: params_for(:totp) |> Map.put(:user_id, ctx.user.id)}
    end

    test "creates a new totp on database", ctx do
      # Inserting totp
      assert {:ok, totp} = TOTP.insert(ctx.params)
      assert totp == Repo.get(TOTPSchema, totp.id)
    end

    test "fails if totp already exist", ctx do
      # Inserting totp
      insert(:totp, ctx.params)

      # Inserting duplicated totp
      assert {:error, changeset} = TOTP.insert(ctx.params)
      assert %{user_id: ["has already been taken"]} == errors_on(changeset)
    end

    test "fails if params are empty" do
      assert {:error, changeset} = TOTP.insert(%{})
      assert %{email: ["can't be blank"], user_id: ["can't be blank"]} == errors_on(changeset)
    end

    test "fails if params are invalid" do
      assert {:error, changeset} = TOTP.insert(%{email: 1, user_id: 1})
      assert %{email: ["is invalid"], user_id: ["is invalid"]} == errors_on(changeset)
    end
  end

  describe "insert!/1" do
    setup ctx do
      {:ok, params: params_for(:totp) |> Map.put(:user_id, ctx.user.id)}
    end

    test "creates a new totp on database", ctx do
      # Inserting totp
      assert totp = TOTP.insert!(ctx.params)
      assert totp == Repo.get(TOTPSchema, totp.id)
    end

    test "fails if totp already exist", ctx do
      assert_raise Ecto.InvalidChangesetError, fn ->
        # Inserting totp
        assert _password = insert(:totp, ctx.params)

        # Inserting duplicated user
        assert TOTP.insert!(ctx.params)
      end
    end

    test "fails if params are empty" do
      assert_raise Ecto.InvalidChangesetError, fn -> TOTP.insert!(%{}) end
    end

    test "fails if params are invalid" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        TOTP.insert!(%{name: 1, description: 1})
      end
    end
  end

  describe "list/1" do
    setup do
      users = insert_list(10, :user)

      pins = Enum.map(users, &insert(:totp, params_for(:totp) |> Map.put(:user_id, &1.id)))

      {:ok, users: users, ids: Enum.map(pins, & &1.id)}
    end

    test "return a list of totp", ctx do
      assert pins = TOTP.list()
      assert true == Enum.all?(pins, &(&1.id in ctx.ids))
    end

    test "can filter list by database fields", ctx do
      assert [user | _] = ctx.users
      assert [totp] = TOTP.list(user_id: user.id)
      assert totp.id in ctx.ids
    end
  end

  describe "get_by/1" do
    setup ctx do
      params = params_for(:totp) |> Map.put(:user_id, ctx.user.id)
      {:ok, totp: insert(:totp, params)}
    end

    test "can get totp by database fields", ctx do
      assert totp = TOTP.get_by(user_id: ctx.user.id)
      assert totp.id == ctx.totp.id
    end
  end

  describe "delete/1" do
    setup ctx do
      params = params_for(:totp) |> Map.put(:user_id, ctx.user.id)
      {:ok, totp: insert(:totp, params)}
    end

    test "deletes a totp on database", ctx do
      assert {:ok, _totp} = TOTP.delete(ctx.totp)
      assert nil == Repo.get(TOTPSchema, ctx.totp.id)
    end
  end

  describe "delete!/1" do
    setup ctx do
      params = params_for(:totp) |> Map.put(:user_id, ctx.user.id)
      {:ok, totp: insert(:totp, params)}
    end

    test "deletes a totp on database", ctx do
      assert _totp = TOTP.delete!(ctx.totp)
      assert nil == Repo.get(TOTPSchema, ctx.totp.id)
    end

    test "fails if totp dont exist", ctx do
      assert Repo.delete(ctx.totp)
      assert_raise Ecto.StaleEntryError, fn -> TOTP.delete!(ctx.totp) end
    end
  end

  describe "check_totp?/3" do
    setup ctx do
      params = params_for(:totp) |> Map.put(:user_id, ctx.user.id)
      {:ok, totp: insert(:totp, params)}
    end

    test "returns true if the given code is equal to the generated", ctx do
      assert date_now = Timex.now()

      assert code =
               TOTPSchema.generate_totp(
                 ctx.totp.secret,
                 ctx.totp.period,
                 ctx.totp.digits,
                 date_now
               )

      assert true == TOTP.check_totp?(ctx.totp, code, date_now)
    end

    test "returns false if the given code is equal to the generated", ctx do
      assert false == TOTP.check_totp?(ctx.totp, "ZdiRoKEGwKFMEWUqDwDq")
    end
  end
end
