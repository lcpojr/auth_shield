defmodule AuthX.AuthenticationTest do
  use AuthX.DataCase, async: true

  alias AuthX.Authentication
  alias AuthX.Resources.Schemas.User

  setup do
    {:ok, user: insert(:user)}
  end

  describe "authenticate_password/2" do
    setup ctx do
      {:ok, password: insert(:password, Map.put(params_for(:password), :user_id, ctx.user.id))}
    end

    test "authenticates if the user password credential is valid", ctx do
      assert user = Repo.update!(User.changeset_status(ctx.user, %{is_active: true}))
      assert {:ok, :authenticated} == Authentication.authenticate_password(user, "My_passw@rd1")
    end

    test "unauthenticates if user is not active", ctx do
      assert {:error, :unauthenticated} ==
               Authentication.authenticate_password(ctx.user, "My_passw@rd1")
    end

    test "unauthenticates if the user password credential is invalid", ctx do
      assert user = Repo.update!(User.changeset_status(ctx.user, %{is_active: true}))
      assert {:error, :unauthenticated} == Authentication.authenticate_password(user, "234543")
    end
  end

  describe "authenticate_pin/2" do
    setup ctx do
      {:ok, pin: insert(:pin, Map.put(params_for(:pin), :user_id, ctx.user.id))}
    end

    test "authenticates if the user pin credential is valid", ctx do
      assert user = Repo.update!(User.changeset_status(ctx.user, %{is_active: true}))
      assert {:ok, :authenticated} == Authentication.authenticate_pin(user, "123456")
    end

    test "unauthenticates if user is not active", ctx do
      assert {:error, :unauthenticated} == Authentication.authenticate_pin(ctx.user, "123456")
    end

    test "unauthenticates if the user pin credential is invalid", ctx do
      assert user = Repo.update!(User.changeset_status(ctx.user, %{is_active: true}))
      assert {:error, :unauthenticated} == Authentication.authenticate_pin(user, "654321")
    end
  end

  describe "authenticate_totp/2" do
    setup ctx do
      {:ok, totp: insert(:totp, Map.put(params_for(:totp), :user_id, ctx.user.id))}
    end

    # This is an work in progress and we need to solve TOTP instabilities before
    # put some tests

    test "unauthenticates if user is not active", ctx do
      assert {:error, :unauthenticated} == Authentication.authenticate_totp(ctx.user, "123456")
    end
  end
end
