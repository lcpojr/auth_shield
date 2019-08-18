defmodule AuthX.AuthenticationTest do
  use AuthX.DataCase, async: true

  alias AuthX.Authentication
  alias AuthX.Resources.Schemas.User

  describe "authorize/1" do
    setup do
      user = insert(:user)
      password = insert(:password, Map.put(params_for(:password), :user_id, user.id))
      pin = insert(:pin, Map.put(params_for(:pin), :user_id, user.id))
      {:ok, user: user, password: password, pin: pin}
    end

    test "authenticates if the user password credential is valid", ctx do
      assert user = Repo.update!(User.changeset_status(ctx.user, %{is_active: true}))

      assert {:ok, :authenticated} ==
               Authentication.authenticate(%{
                 email: user.email,
                 password: "My_passw@rd1"
               })
    end

    test "authenticates if the user pin credential is valid", ctx do
      assert user = Repo.update!(User.changeset_status(ctx.user, %{is_active: true}))

      assert {:ok, :authenticated} ==
               Authentication.authenticate(%{
                 email: user.email,
                 pin: "123456"
               })
    end

    test "unauthenticates if user is not active", ctx do
      assert {:error, :unauthenticated} ==
               Authentication.authenticate(%{
                 email: ctx.user.email,
                 password: "My_passw@rd1"
               })

      assert {:error, :unauthenticated} ==
               Authentication.authenticate(%{
                 email: ctx.user.email,
                 pin: "123456"
               })
    end

    test "unauthenticates if the user password credential is invalid", ctx do
      assert user = Repo.update!(User.changeset_status(ctx.user, %{is_active: true}))

      assert {:error, :unauthenticated} ==
               Authentication.authenticate(%{
                 email: ctx.user.email,
                 password: "234543"
               })
    end

    test "unauthenticates if the user pin credential is invalid", ctx do
      assert user = Repo.update!(User.changeset_status(ctx.user, %{is_active: true}))

      assert {:error, :unauthenticated} ==
               Authentication.authenticate(%{
                 email: ctx.user.email,
                 pin: "654321"
               })
    end
  end
end
