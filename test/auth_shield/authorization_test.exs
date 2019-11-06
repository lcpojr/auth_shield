defmodule AuthShield.AuthorizationTest do
  use AuthShield.DataCase, async: true

  alias AuthShield.{Authorization, DelegatorMock, Resources}
  alias AuthShield.Resources.Schemas.User

  setup do
    permission = insert(:permission)
    role = insert(:role, permissions: [permission])
    user = insert(:user, roles: [role])

    {:ok, user: user, role: role, permission: permission}
  end

  describe "authorize_roles/2" do
    test "authorizes if the user has all the required role", ctx do
      assert user = Repo.update!(User.changeset_status(ctx.user, %{is_active: true}))
      assert roles = [ctx.role.name]

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :preload_user}, {Resources.Users, :preload}, [%User{} = user, [:roles]] ->
          user
        end
      )

      assert {:ok, :authorized} == Authorization.authorize_roles(user, roles)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :preload_user}, {Resources.Users, :preload}, [%User{} = user, [:roles]] ->
          user
        end
      )

      assert {:ok, :authorized} == Authorization.authorize_roles(user, roles, rule: :all)
    end

    test "authorizes if the user has any one of the required role", ctx do
      assert user = Repo.update!(User.changeset_status(ctx.user, %{is_active: true}))
      assert roles = [ctx.role.name]

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :preload_user}, {Resources.Users, :preload}, [%User{} = user, [:roles]] ->
          user
        end
      )

      assert {:ok, :authorized} == Authorization.authorize_roles(user, roles, rule: :any)
    end

    test "unauthorizes if user is not active", ctx do
      assert {:error, :unauthorized} == Authorization.authorize_roles(ctx.user, [ctx.role.name])
    end

    test "unauthorizes if the role is invalid", ctx do
      assert user = Repo.update!(User.changeset_status(ctx.user, %{is_active: true}))

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :preload_user}, {Resources.Users, :preload}, [%User{} = user, [:roles]] ->
          user
        end
      )

      assert {:error, :unauthorized} == Authorization.authorize_roles(user, ["any-role"])
    end

    test "unauthorizes if the the user does not have roles", ctx do
      assert user = Repo.update!(User.changeset_status(ctx.user, %{is_active: true}))

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :preload_user}, {Resources.Users, :preload}, [%User{} = user, [:roles]] ->
          user
        end
      )

      assert {:error, :unauthorized} == Authorization.authorize_roles(user, [])
    end
  end

  describe "authorize_permissions/2" do
    test "authorizes if the user role has all the required permission", ctx do
      assert user = Repo.update!(User.changeset_status(ctx.user, %{is_active: true}))
      assert permissions = [ctx.permission.name]

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :preload_user},
           {Resources.Users, :preload},
           [%User{} = user, [roles: :permissions]] ->
          user
        end
      )

      assert {:ok, :authorized} == Authorization.authorize_permissions(user, permissions)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :preload_user},
           {Resources.Users, :preload},
           [%User{} = user, [roles: :permissions]] ->
          user
        end
      )

      assert {:ok, :authorized} ==
               Authorization.authorize_permissions(user, permissions, rule: :all)
    end

    test "authorizes if the user role has one of the required permission", ctx do
      assert user = Repo.update!(User.changeset_status(ctx.user, %{is_active: true}))
      assert permissions = [ctx.permission.name]

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :preload_user},
           {Resources.Users, :preload},
           [%User{} = user, [roles: :permissions]] ->
          user
        end
      )

      assert {:ok, :authorized} ==
               Authorization.authorize_permissions(user, permissions, rule: :any)
    end

    test "unauthorizes if user is not active", ctx do
      assert {:error, :unauthorized} ==
               Authorization.authorize_permissions(ctx.user, [ctx.permission.name])
    end
  end
end
