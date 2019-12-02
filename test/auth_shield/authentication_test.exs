defmodule AuthShield.AuthenticationTest do
  use AuthShield.DataCase, async: true

  alias AuthShield.{Authentication, Credentials, DelegatorMock}
  alias AuthShield.Authentication.Schemas.Session

  describe "AuthShield.Authentication" do
    setup do
      {:ok, user: insert(:user)}
    end

    test "delegates from create_session/1 to #{inspect(Authentication.Sessions)}.insert/1", ctx do
      expect(
        DelegatorMock,
        :apply,
        fn {Authentication, :create_session}, {Authentication.Sessions, :insert}, [params] ->
          {:ok, insert(:session, params)}
        end
      )

      assert Authentication.create_session(%{params_for(:session) | user_id: ctx.user.id})
    end

    test "delegates from create_session!/1 to #{inspect(Authentication.Sessions)}.insert!/1",
         ctx do
      expect(
        DelegatorMock,
        :apply,
        fn {Authentication, :create_session!}, {Authentication.Sessions, :insert!}, [params] ->
          {:ok, insert(:session, params)}
        end
      )

      assert Authentication.create_session!(%{params_for(:session) | user_id: ctx.user.id})
    end

    test "delegates from update_session/2 to #{inspect(Authentication.Sessions)}.update/2",
         ctx do
      session = insert(:session, user_id: ctx.user.id)

      expect(
        DelegatorMock,
        :apply,
        fn {Authentication, :update_session},
           {Authentication.Sessions, :update},
           [%Session{} = sess, _params] ->
          assert session.id == sess.id
          session
        end
      )

      assert Authentication.update_session(session, %{params_for(:session) | user_id: ctx.user.id})
    end

    test "delegates from update_session!/2 to #{inspect(Authentication.Sessions)}.update!/2",
         ctx do
      session = insert(:session, user_id: ctx.user.id)

      expect(
        DelegatorMock,
        :apply,
        fn {Authentication, :update_session!},
           {Authentication.Sessions, :update!},
           [%Session{} = sess, _params] ->
          assert session.id == sess.id
          session
        end
      )

      assert Authentication.update_session!(session, %{
               params_for(:session)
               | user_id: ctx.user.id
             })
    end

    test "delegates from list_session/1 to #{inspect(Authentication.Sessions)}.list/1", ctx do
      session = insert(:session, user_id: ctx.user.id)

      expect(
        DelegatorMock,
        :apply,
        fn {Authentication, :list_session}, {Authentication.Sessions, :list}, [[user_id: id]] ->
          assert ctx.user.id == id
          [session]
        end
      )

      assert Authentication.list_session(user_id: ctx.user.id)
    end

    test "delegates from get_session_by/1 to #{inspect(Authentication.Sessions)}.get_by/1",
         ctx do
      session = insert(:session, user_id: ctx.user.id)

      expect(
        DelegatorMock,
        :apply,
        fn {Authentication, :get_session_by},
           {Authentication.Sessions, :get_by},
           [[user_id: id]] ->
          assert ctx.user.id == id
          session
        end
      )

      assert Authentication.get_session_by(user_id: ctx.user.id)
    end

    test "delegates from get_session_by!/1 to #{inspect(Authentication.Sessions)}.get_by!/1",
         ctx do
      session = insert(:session, user_id: ctx.user.id)

      expect(
        DelegatorMock,
        :apply,
        fn {Authentication, :get_session_by!},
           {Authentication.Sessions, :get_by!},
           [[user_id: id]] ->
          assert ctx.user.id == id
          session
        end
      )

      assert Authentication.get_session_by!(user_id: ctx.user.id)
    end
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
      assert password = insert(:password, user_id: user.id)

      expect(
        DelegatorMock,
        :apply,
        fn {Credentials, :get_password_by}, {Credentials.Passwords, :get_by}, [[user_id: id]] ->
          assert user.id == id
          password
        end
      )

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
      assert pin = insert(:pin, user_id: user.id)

      expect(
        DelegatorMock,
        :apply,
        fn {Credentials, :get_pin_by}, {Credentials.PIN, :get_by}, [[user_id: id]] ->
          assert user.id == id
          pin
        end
      )

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
    # This is an work in progress and we need to solve
    # TOTP instabilities before put some tests
  end
end
