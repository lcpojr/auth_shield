defmodule AuthShield.Credentials.PINTest do
  use AuthShield.DataCase, async: true

  alias AuthShield.Credentials.PIN
  alias AuthShield.Credentials.Schemas.PIN, as: PINSchema

  setup do
    {:ok, user: insert(:user)}
  end

  describe "insert/1" do
    setup ctx do
      {:ok, params: params_for(:pin) |> Map.put(:user_id, ctx.user.id)}
    end

    test "creates a new pin on database", ctx do
      # Inserting PIN
      assert {:ok, pin} = PIN.insert(ctx.params)
      assert pin == Repo.get(PINSchema, pin.id)
    end

    test "fails if pin already exist", ctx do
      # Inserting PIN
      insert(:pin, ctx.params)

      # Inserting duplicated PIN
      assert {:error, changeset} = PIN.insert(ctx.params)
      assert %{user_id: ["has already been taken"]} == errors_on(changeset)
    end

    test "fails if params are empty" do
      assert {:error, changeset} = PIN.insert(%{})
      assert %{pin: ["can't be blank"], user_id: ["can't be blank"]} == errors_on(changeset)
    end

    test "fails if params are invalid" do
      assert {:error, changeset} = PIN.insert(%{pin: 1, user_id: 1})
      assert %{pin: ["is invalid"], user_id: ["is invalid"]} == errors_on(changeset)
    end
  end

  describe "insert!/1" do
    setup ctx do
      {:ok, params: params_for(:pin) |> Map.put(:user_id, ctx.user.id)}
    end

    test "creates a new pin on database", ctx do
      # Inserting PIN
      assert pin = PIN.insert!(ctx.params)
      assert pin == Repo.get(PINSchema, pin.id)
    end

    test "fails if pin already exist", ctx do
      assert_raise Ecto.InvalidChangesetError, fn ->
        # Inserting PIN
        assert _pin = insert(:pin, ctx.params)

        # Inserting duplicated user
        assert PIN.insert!(ctx.params)
      end
    end

    test "fails if params are empty" do
      assert_raise Ecto.InvalidChangesetError, fn -> PIN.insert!(%{}) end
    end

    test "fails if params are invalid" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        PIN.insert!(%{name: 1, description: 1})
      end
    end
  end

  describe "list/1" do
    setup do
      users = insert_list(3, :user)
      pins = Enum.map(users, &insert(:pin, params_for(:pin) |> Map.put(:user_id, &1.id)))
      {:ok, users: users, ids: Enum.map(pins, & &1.id)}
    end

    test "return a list of PIN", ctx do
      assert pins = PIN.list()
      assert true == Enum.all?(pins, &(&1.id in ctx.ids))
    end

    test "can filter list by database fields", ctx do
      assert [user | _] = ctx.users
      assert [pin] = PIN.list(user_id: user.id)
      assert pin.id in ctx.ids
    end
  end

  describe "get_by/1" do
    setup ctx do
      params = params_for(:pin) |> Map.put(:user_id, ctx.user.id)
      {:ok, pin: insert(:pin, params)}
    end

    test "can get pin by database fields", ctx do
      assert pin = PIN.get_by(user_id: ctx.user.id)
      assert pin.id == ctx.pin.id
    end
  end

  describe "get_by!/1" do
    setup ctx do
      params = params_for(:pin) |> Map.put(:user_id, ctx.user.id)
      {:ok, pin: insert(:pin, params)}
    end

    test "can get pin by database fields", ctx do
      assert pin = PIN.get_by!(user_id: ctx.user.id)
      assert pin.id == ctx.pin.id
    end
  end

  describe "delete/1" do
    setup ctx do
      params = params_for(:pin) |> Map.put(:user_id, ctx.user.id)
      {:ok, pin: insert(:pin, params)}
    end

    test "deletes a pin on database", ctx do
      assert {:ok, _pin} = PIN.delete(ctx.pin)
      assert nil == Repo.get(PINSchema, ctx.pin.id)
    end
  end

  describe "delete!/1" do
    setup ctx do
      params = params_for(:pin) |> Map.put(:user_id, ctx.user.id)
      {:ok, pin: insert(:pin, params)}
    end

    test "deletes a pin on database", ctx do
      assert _pin = PIN.delete!(ctx.pin)
      assert nil == Repo.get(PINSchema, ctx.pin.id)
    end

    test "fails if pin dont exist", ctx do
      assert Repo.delete(ctx.pin)
      assert_raise Ecto.StaleEntryError, fn -> PIN.delete!(ctx.pin) end
    end
  end

  describe "check_pin?/2" do
    setup ctx do
      params = params_for(:pin) |> Map.put(:user_id, ctx.user.id)
      {:ok, pin: insert(:pin, params)}
    end

    test "returns true if the given code is equal to the saved hash", ctx do
      assert true == PIN.check_pin?(ctx.pin, "123456")
    end

    test "returns false if the given code is equal to the generated", ctx do
      assert false == PIN.check_pin?(ctx.pin, "ZdiRoKEGwKFMEWUqDwDq")
    end
  end
end
