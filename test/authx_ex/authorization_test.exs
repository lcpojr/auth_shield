defmodule AuthX.AuthorizationTest do
  use AuthX.DataCase, async: true

  alias AuthX.Authorization
  alias AuthX.Resources.Schemas.User

  describe "authorize/1" do
    setup do
      permission = insert(:permission)
      role = insert(:role, Map.put(params_for(:role), :permissions, [permission]))
      user = insert(:user, Map.put(params_for(:user), :roles, [role]))
      {:ok, user: user, role: role, permission: permission}
    end

    test "authorizes if the user has the required role", ctx do
      assert user = Repo.update!(User.changeset_status(ctx.user, %{is_active: true}))

      assert {:ok, :authorized} ==
               Authorization.authorize(%{
                 email: user.email,
                 roles: [ctx.role.name]
               })
    end

    test "authorizes if the user role has the required permission", ctx do
      assert user = Repo.update!(User.changeset_status(ctx.user, %{is_active: true}))

      assert {:ok, :authorized} ==
               Authorization.authorize(%{
                 email: user.email,
                 permissions: [ctx.permission.name]
               })
    end

    test "unauthorizes if user is not active", ctx do
      assert {:error, :unauthorized} ==
               Authorization.authorize(%{
                 email: ctx.user.email,
                 roles: [ctx.role.name]
               })

      assert {:error, :unauthorized} ==
               Authorization.authorize(%{
                 email: ctx.user.email,
                 permissions: [ctx.permission.name]
               })
    end

    test "unauthorizes if the role is invalid", ctx do
      assert user = Repo.update!(User.changeset_status(ctx.user, %{is_active: true}))

      assert {:error, :unauthorized} ==
               Authorization.authorize(%{
                 email: ctx.user.email,
                 roles: ["any-role"]
               })
    end

    test "unauthorizes if the the user does not have roles", ctx do
      assert user = Repo.update!(User.changeset_status(ctx.user, %{is_active: true}))

      assert {:error, :unauthorized} ==
               Authorization.authorize(%{
                 email: ctx.user.email,
                 roles: []
               })
    end
  end
end
