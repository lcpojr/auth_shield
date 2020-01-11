defmodule AuthShield.Resources.ApplicationsTest do
  use AuthShield.DataCase, async: true

  alias AuthShield.Resources.Schemas.Application
  alias AuthShield.Resources.Applications

  describe "insert/1" do
    test "creates a new application on database" do
      # Preparing params
      assert params =
               :application
               |> params_for()
               |> Map.put(:public_key_credential, params_for(:public_key))

      # Inserting application
      assert {:ok, application} = Applications.insert(params)

      assert application ==
               Application
               |> Repo.get(application.id)
               |> Repo.preload(:public_key_credential)
    end

    test "fails if application already exist" do
      # Preparing params
      assert params =
               :application
               |> params_for()
               |> Map.put(:public_key_credential, params_for(:public_key))

      # Inserting application
      assert _application = insert(:application, params)

      # Inserting duplicated application
      assert {:error, changeset} = Applications.insert(params)
      assert %{name: ["has already been taken"]} == errors_on(changeset)
    end

    test "fails if params are empty" do
      assert {:error, changeset} = Applications.insert(%{})

      assert %{
               name: ["can't be blank"],
               public_key_credential: ["can't be blank"]
             } == errors_on(changeset)
    end

    test "fails if params are invalid" do
      assert {:error, changeset} = Applications.insert(%{name: 1, public_key_credential: 1})

      assert %{
               name: ["is invalid"],
               public_key_credential: ["is invalid"]
             } == errors_on(changeset)
    end
  end

  describe "insert!/1" do
    test "creates a new application on database" do
      # Preparing params
      assert params =
               :application
               |> params_for()
               |> Map.put(:public_key_credential, params_for(:public_key))

      # Inserting application
      assert application = Applications.insert!(params)

      assert application ==
               Application
               |> Repo.get(application.id)
               |> Repo.preload(:public_key_credential)
    end

    test "fails if application already exist" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        # Preparing params
        assert params =
                 Map.put(
                   params_for(:application),
                   :public_key_credential,
                   params_for(:public_key)
                 )

        # Inserting application
        assert _application = insert(:application, params)

        # Inserting duplicated application
        assert Applications.insert!(params)
      end
    end

    test "fails if params are empty" do
      assert_raise Ecto.InvalidChangesetError, fn -> Applications.insert!(%{}) end
    end

    test "fails if params are invalid" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        Applications.insert!(%{name: 1, description: 1})
      end
    end
  end

  describe "update/2" do
    setup do
      {:ok, application: insert(:application)}
    end

    test "updates a application on database", ctx do
      assert {:ok, application} = Applications.update(ctx.application, params_for(:application))
      assert application != ctx.application
    end

    test "fails if params are invalid", ctx do
      assert {:error, changeset} =
               Applications.update(ctx.application, %{name: 1, description: 1})

      assert %{name: ["is invalid"], description: ["is invalid"]} == errors_on(changeset)
    end
  end

  describe "update!/2" do
    setup do
      {:ok, application: insert(:application)}
    end

    test "updates a application on database", ctx do
      assert {:ok, application} = Applications.update(ctx.application, params_for(:application))
      assert application != ctx.application
    end

    test "fails if params are invalid", ctx do
      assert_raise Ecto.InvalidChangesetError, fn ->
        Applications.update!(ctx.application, %{name: 1, description: 1})
      end
    end
  end

  describe "list/1" do
    setup do
      {:ok, applications: insert_list(3, :application)}
    end

    test "return a list of applications", ctx do
      assert applications = Applications.list()
      assert applications == ctx.applications
    end

    test "can filter list by database fields", ctx do
      assert [application1 | _] = ctx.applications
      assert [application2] = Applications.list(name: application1.name)
      assert application1.id == application2.id
    end
  end

  describe "get_by/1" do
    setup do
      {:ok, application: insert(:application)}
    end

    test "can get application by database fields", ctx do
      assert ctx.application == Applications.get_by(name: ctx.application.name)
    end
  end

  describe "get_by!/1" do
    setup do
      {:ok, application: insert(:application)}
    end

    test "can get application by database fields", ctx do
      assert ctx.application == Applications.get_by!(name: ctx.application.name)
    end
  end

  describe "delete/1" do
    setup do
      {:ok, application: insert(:application)}
    end

    test "deletes a application on database", ctx do
      assert {:ok, _application} = Applications.delete(ctx.application)
      assert nil == Repo.get(Application, ctx.application.id)
    end
  end

  describe "delete!/1" do
    setup do
      {:ok, application: insert(:application)}
    end

    test "deletes a application on database", ctx do
      assert _application = Applications.delete!(ctx.application)
      assert nil == Repo.get(Application, ctx.application.id)
    end

    test "fails if application dont exist", ctx do
      assert Repo.delete(ctx.application)
      assert_raise Ecto.StaleEntryError, fn -> Applications.delete!(ctx.application) end
    end
  end

  describe "change_scopes/2" do
    setup do
      {:ok, application: insert(:application), scopes: insert_list(10, :scope)}
    end

    test "changes the application scopes", ctx do
      assert {:ok, application} = Applications.change_scopes(ctx.application, ctx.scopes)
      assert application.scopes == Repo.preload(ctx.application, :scopes).scopes
    end
  end

  describe "change_scopes!/2" do
    setup do
      {:ok, application: insert(:application), scopes: insert_list(10, :scope)}
    end

    test "changes the application scopes", ctx do
      assert application = Applications.change_scopes!(ctx.application, ctx.scopes)
      assert application.scopes == Repo.preload(ctx.application, :scopes).scopes
    end

    test "fails if params are invalid", ctx do
      assert_raise Ecto.ChangeError, fn ->
        Applications.change_scopes!(ctx.application, [%{name: 1, description: 1}])
      end
    end
  end

  describe "preload/2" do
    setup do
      {:ok, application: insert(:application)}
    end

    test "preloads application data", ctx do
      assert application = Applications.preload(ctx.application, [:public_key_credential])
      assert application == Repo.preload(application, [:public_key_credential])
    end
  end
end
