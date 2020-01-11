defmodule AuthShield.Credentials.PublicKeyTest do
  use AuthShield.DataCase, async: true

  alias AuthShield.Credentials.PublicKey
  alias AuthShield.Credentials.Schemas.PublicKey, as: Key

  setup do
    {:ok, application: insert(:application)}
  end

  describe "insert/1" do
    setup ctx do
      {:ok, params: %{params_for(:public_key) | application_id: ctx.application.id}}
    end

    test "creates a new public_key on database", ctx do
      # Inserting public key
      assert {:ok, public_key} = PublicKey.insert(ctx.params)
      assert public_key == Repo.get(Key, public_key.id)
    end

    test "fails if public_key already exist", ctx do
      # Inserting public key
      insert(:public_key, ctx.params)

      # Inserting duplicated public key
      assert {:error, changeset} = PublicKey.insert(ctx.params)
      assert %{application_id: ["has already been taken"]} == errors_on(changeset)
    end

    test "fails if params are empty" do
      assert {:error, changeset} = PublicKey.insert(%{})
      assert %{key: ["can't be blank"]} == errors_on(changeset)
    end

    test "fails if params are invalid" do
      assert {:error, changeset} = PublicKey.insert(%{key: 1, application_id: 1})
      assert %{key: ["is invalid"], application_id: ["is invalid"]} == errors_on(changeset)
    end
  end

  describe "insert!/1" do
    setup ctx do
      {:ok, params: params_for(:public_key) |> Map.put(:application_id, ctx.application.id)}
    end

    test "creates a new public_key on database", ctx do
      # Inserting public key
      assert public_key = PublicKey.insert!(ctx.params)
      assert public_key == Repo.get(Key, public_key.id)
    end

    test "fails if public_key already exist", ctx do
      assert_raise Ecto.InvalidChangesetError, fn ->
        # Inserting public key
        assert _public_key = insert(:public_key, ctx.params)

        # Inserting duplicated application
        assert PublicKey.insert!(ctx.params)
      end
    end

    test "fails if params are empty" do
      assert_raise Ecto.InvalidChangesetError, fn -> PublicKey.insert!(%{}) end
    end

    test "fails if params are invalid" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        PublicKey.insert!(%{name: 1, description: 1})
      end
    end
  end

  describe "list/1" do
    setup do
      applications = insert_list(3, :application)

      public_keys =
        Enum.map(
          applications,
          &insert(:public_key, params_for(:public_key) |> Map.put(:application_id, &1.id))
        )

      {:ok, applications: applications, ids: Enum.map(public_keys, & &1.id)}
    end

    test "return a list of PublicKey", ctx do
      assert public_keys = PublicKey.list()
      assert true == Enum.all?(public_keys, &(&1.id in ctx.ids))
    end

    test "can filter list by database fields", ctx do
      assert [application | _] = ctx.applications
      assert [public_key] = PublicKey.list(application_id: application.id)
      assert public_key.id in ctx.ids
    end
  end

  describe "get_by/1" do
    setup ctx do
      params = params_for(:public_key) |> Map.put(:application_id, ctx.application.id)
      {:ok, public_key: insert(:public_key, params)}
    end

    test "can get public_key by database fields", ctx do
      assert public_key = PublicKey.get_by(application_id: ctx.application.id)
      assert public_key.id == ctx.public_key.id
    end
  end

  describe "get_by!/1" do
    setup ctx do
      params = params_for(:public_key) |> Map.put(:application_id, ctx.application.id)
      {:ok, public_key: insert(:public_key, params)}
    end

    test "can get public_key by database fields", ctx do
      assert public_key = PublicKey.get_by!(application_id: ctx.application.id)
      assert public_key.id == ctx.public_key.id
    end
  end

  describe "delete/1" do
    setup ctx do
      params = params_for(:public_key) |> Map.put(:application_id, ctx.application.id)
      {:ok, public_key: insert(:public_key, params)}
    end

    test "deletes a public_key on database", ctx do
      assert {:ok, _public_key} = PublicKey.delete(ctx.public_key)
      assert nil == Repo.get(Key, ctx.public_key.id)
    end
  end

  describe "delete!/1" do
    setup ctx do
      params = params_for(:public_key) |> Map.put(:application_id, ctx.application.id)
      {:ok, public_key: insert(:public_key, params)}
    end

    test "deletes a public_key on database", ctx do
      assert _public_key = PublicKey.delete!(ctx.public_key)
      assert nil == Repo.get(Key, ctx.public_key.id)
    end

    test "fails if public_key dont exist", ctx do
      assert Repo.delete(ctx.public_key)
      assert_raise Ecto.StaleEntryError, fn -> PublicKey.delete!(ctx.public_key) end
    end
  end
end
