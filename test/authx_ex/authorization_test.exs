defmodule AuthX.AuthorizationTest do
  use AuthX.DataCase, async: true

  alias AuthX.Authorization
  alias AuthX.Resources.Schemas.{RolesPermissions, User, UsersRoles}

  describe "authorize/1" do
    setup do
      {:ok, user: insert(:user), role: insert(:role), permission: insert(:permission)}
    end

    test "authorizes if the user has the required role", ctx do
      assert user = Repo.update!(User.changeset_status(ctx.user, %{is_active: true}))

      assert Repo.insert(
               UsersRoles.changeset(%UsersRoles{}, %{
                 user_id: user.id,
                 role_id: ctx.role.id
               })
             )

      assert {:ok, :authorized} ==
               Authorization.authorize(%{
                 email: user.email,
                 roles: [ctx.role.name]
               })
    end

    test "authorizes if the user role has the required permission", ctx do
      assert user = Repo.update!(User.changeset_status(ctx.user, %{is_active: true}))

      assert Repo.insert(
               UsersRoles.changeset(%UsersRoles{}, %{
                 user_id: user.id,
                 role_id: ctx.role.id
               })
             )

      assert Repo.insert(
               RolesPermissions.changeset(%RolesPermissions{}, %{
                 role_id: ctx.role.id,
                 permission_id: ctx.permission.id
               })
             )

      assert {:ok, :authorized} ==
               Authorization.authorize(%{
                 email: user.email,
                 permissions: [ctx.permission.name]
               })
    end

    test "unauthorizes if user is not active", ctx do
      assert Repo.insert(
               UsersRoles.changeset(%UsersRoles{}, %{
                 user_id: ctx.user.id,
                 role_id: ctx.role.id
               })
             )

      assert Repo.insert(
               RolesPermissions.changeset(%RolesPermissions{}, %{
                 role_id: ctx.role.id,
                 permission_id: ctx.permission.id
               })
             )

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
                 roles: [ctx.role.name]
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
