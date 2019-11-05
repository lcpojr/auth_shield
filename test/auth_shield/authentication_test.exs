defmodule AuthShield.AuthenticationTest do
  use AuthShield.DataCase, async: true

  alias AuthShield.{Authentication, DelegatorMock, Credentials}

  describe "create_session/2" do
  end

  describe "create_session!/2" do
  end

  describe "update_session/2" do
  end

  describe "update_session!/2" do
  end

  describe "list_session/1" do
  end

  describe "get_session_by/1" do
  end

  describe "get_session_by!/1" do
  end

  describe "authenticate_password/2" do
    test "authenticates if the user password credential is valid" do
      assert user = insert(:user, is_active: true)
      assert password = insert(:password, user_id: user.id)

      expect(
        DelegatorMock,
        :apply,
        fn {Credentials, :get_password_by}, {Credentials.Passwords, :get_by}, [[user_id: id]] ->
          assert user.id == id
          password
        end
      )

      expect(
        DelegatorMock,
        :apply,
        fn {Credentials, :check_password?},
           {Credentials.Passwords, :check_password?},
           [pass, _pass_code] ->
          assert password == pass
          true
        end
      )

      assert {:ok, :authenticated} == Authentication.authenticate_password(user, "My_passw@rd1")
    end

    test "unauthenticates if user is not active" do
      assert user = insert(:user)
      assert insert(:password, user_id: user.id)

      assert {:error, :unauthenticated} ==
               Authentication.authenticate_password(
                 user,
                 "My_passw@rd1"
               )
    end

    test "unauthenticates if the user password credential is invalid" do
      assert user = insert(:user, is_active: true)
      assert password = insert(:password, user_id: user.id)

      expect(
        DelegatorMock,
        :apply,
        fn {Credentials, :get_password_by}, {Credentials.Passwords, :get_by}, [[user_id: id]] ->
          assert user.id == id
          password
        end
      )

      expect(
        DelegatorMock,
        :apply,
        fn {Credentials, :check_password?},
           {Credentials.Passwords, :check_password?},
           [pass, _pass_code] ->
          assert password == pass
          false
        end
      )

      assert {:error, :unauthenticated} == Authentication.authenticate_password(user, "234543")
    end
  end

  describe "authenticate_pin/2" do
    test "authenticates if the user pin credential is valid" do
      assert user = insert(:user, is_active: true)
      assert pin = insert(:pin, user_id: user.id)

      expect(
        DelegatorMock,
        :apply,
        fn {Credentials, :get_pin_by}, {Credentials.PIN, :get_by}, [[user_id: id]] ->
          assert user.id == id
          pin
        end
      )

      expect(
        DelegatorMock,
        :apply,
        fn {Credentials, :check_pin?}, {Credentials.PIN, :check_pin?}, [cred, _pin_code] ->
          assert pin == cred
          true
        end
      )

      assert {:ok, :authenticated} == Authentication.authenticate_pin(user, "123456")
    end

    test "unauthenticates if user is not active" do
      assert user = insert(:user)
      assert insert(:pin, user_id: user.id)
      assert {:error, :unauthenticated} == Authentication.authenticate_pin(user, "123456")
    end

    test "unauthenticates if the user pin credential is invalid" do
      assert user = insert(:user, is_active: true)
      assert pin = insert(:pin, user_id: user.id)

      expect(
        DelegatorMock,
        :apply,
        fn {Credentials, :get_pin_by}, {Credentials.PIN, :get_by}, [[user_id: id]] ->
          assert user.id == id
          pin
        end
      )

      expect(
        DelegatorMock,
        :apply,
        fn {Credentials, :check_pin?}, {Credentials.PIN, :check_pin?}, [cred, _pin_code] ->
          assert pin == cred
          false
        end
      )

      assert {:error, :unauthenticated} == Authentication.authenticate_pin(user, "654321")
    end
  end

  describe "authenticate_totp/2" do
    # This is an work in progress and we need to solve TOTP instabilities before
    # put some tests

    test "unauthenticates if user is not active" do
      assert user = insert(:user, is_active: false)
      assert insert(:totp, user_id: user.id)
      assert {:error, :unauthenticated} == Authentication.authenticate_totp(user, "123456")
    end
  end
end
