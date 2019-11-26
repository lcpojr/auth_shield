defmodule AuthShieldTest do
  use AuthShield.DataCase, async: true
  use Plug.Test

  alias AuthShield.{Authentication, Credentials, DelegatorMock, Resources}
  alias AuthShield.Authentication.Schemas.Session

  describe "signup/1" do
    test "succeeds if params are valid" do
      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :create_user}, {Resources.Users, :insert}, [params] ->
          assert password_hash = Argon2.hash_pwd_salt(params.password_credential.password)

          assert password_credential =
                   Map.merge(params.password_credential, %{
                     password_hash: password_hash
                   })

          {:ok, insert(:user, %{params | password_credential: password_credential})}
        end
      )

      assert {:ok, _user} =
               AuthShield.signup(%{
                 "first_name" => "Lucas",
                 "last_name" => "Mesquita",
                 "email" => "lucas@gmail.com",
                 "password" => "Mypass@rd12"
               })
    end

    test "fails on validation if params are invalid" do
      assert {:error,
              %{
                email: ["can't be blank"],
                first_name: ["can't be blank"],
                password: ["can't be blank"]
              }} == AuthShield.signup(%{})
    end
  end

  describe "login/1" do
    test "succeeds if params are valid" do
      user = insert(:user, is_active: true)
      password = insert(:password, user_id: user.id)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :get_user_by}, {Resources.Users, :get_by}, [[email: email]] ->
          assert user.email == email
          user
        end
      )

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

      expect(
        DelegatorMock,
        :apply,
        fn {Authentication, :create_session}, {Authentication.Sessions, :insert}, [params] ->
          {:ok, insert(:session, params)}
        end
      )

      conn =
        :get
        |> conn("/users")
        |> put_req_header("user-agent", "Googlebot/2.1 (+http://www.google.com/bot.html)")
        |> Map.put(:body_params, %{"email" => user.email, "password" => "My_passw@rd1"})

      assert {:ok, %Session{}} = AuthShield.login(conn)
    end
  end

  describe "login/2" do
    test "succeeds if params are valid" do
      user = insert(:user, is_active: true)
      password = insert(:password, user_id: user.id)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :get_user_by}, {Resources.Users, :get_by}, [[email: email]] ->
          assert user.email == email
          user
        end
      )

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

      expect(
        DelegatorMock,
        :apply,
        fn {Authentication, :create_session}, {Authentication.Sessions, :insert}, [params] ->
          {:ok, insert(:session, params)}
        end
      )

      assert {:ok, %Session{}} =
               AuthShield.login(%{
                 "email" => user.email,
                 "password" => "My_passw@rd1"
               })
    end

    test "fails on validation if params blank" do
      assert {:error,
              %{
                email: ["can't be blank"],
                password: ["can't be blank"]
              }} == AuthShield.login(%{})
    end

    test "fails if user does not exist" do
      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :get_user_by}, {Resources.Users, :get_by}, [_filters] ->
          nil
        end
      )

      assert {:error, :user_not_found} ==
               AuthShield.login(%{
                 "email" => "wrong_email@gmail.com",
                 "password" => "My_passw@rd1"
               })
    end

    test "fails if password is wrong" do
      user = insert(:user, is_active: true)
      password = insert(:password, user_id: user.id)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :get_user_by}, {Resources.Users, :get_by}, [[email: email]] ->
          assert user.email == email
          user
        end
      )

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

      assert {:error, :unauthenticated} ==
               AuthShield.login(%{
                 "email" => user.email,
                 "password" => "123456"
               })
    end
  end

  describe "refresh_session/1" do
    setup do
      {:ok, user: insert(:user)}
    end

    test "succeeds session id is valid", ctx do
      assert session = insert(:session, user_id: ctx.user.id)

      expect(
        DelegatorMock,
        :apply,
        fn {Authentication, :get_session_by}, {Authentication.Sessions, :get_by}, [[id: id]] ->
          assert session.id == id
          session
        end
      )

      expect(
        DelegatorMock,
        :apply,
        fn {Authentication, :update_session},
           {Authentication.Sessions, :update},
           [%Session{} = sess, _params] ->
          assert session.id == sess.id
          {:ok, session}
        end
      )

      assert {:ok, %Session{}} = AuthShield.refresh_session(session.id)
    end

    test "succeeds complete session is valid", ctx do
      assert session = insert(:session, user_id: ctx.user.id)

      expect(
        DelegatorMock,
        :apply,
        fn {Authentication, :update_session},
           {Authentication.Sessions, :update},
           [%Session{} = sess, _params] ->
          assert session.id == sess.id
          {:ok, session}
        end
      )

      assert {:ok, %Session{}} = AuthShield.refresh_session(session)
    end

    test "fails if session does not exist" do
      expect(
        DelegatorMock,
        :apply,
        fn {Authentication, :get_session_by}, {Authentication.Sessions, :get_by}, [[id: _id]] ->
          nil
        end
      )

      assert {:error, :session_not_found} == AuthShield.refresh_session(Ecto.UUID.generate())
    end

    test "fails if session is expired", ctx do
      assert expiration =
               NaiveDateTime.utc_now()
               |> NaiveDateTime.add(-(60 * 20), :second)

      assert session = insert(:session, user_id: ctx.user.id, expiration: expiration)

      expect(
        DelegatorMock,
        :apply,
        fn {Authentication, :get_session_by}, {Authentication.Sessions, :get_by}, [[id: id]] ->
          assert session.id == id
          session
        end
      )

      assert {:error, :session_expired} == AuthShield.refresh_session(session.id)
    end
  end

  describe "logout/1" do
    setup do
      {:ok, user: insert(:user)}
    end

    test "succeeds if session id is valid", ctx do
      assert session = insert(:session, user_id: ctx.user.id)

      expect(
        DelegatorMock,
        :apply,
        fn {Authentication, :get_session_by}, {Authentication.Sessions, :get_by}, [[id: id]] ->
          assert session.id == id
          session
        end
      )

      expect(
        DelegatorMock,
        :apply,
        fn {Authentication, :update_session},
           {Authentication.Sessions, :update},
           [%Session{} = sess, _params] ->
          assert session.id == sess.id
          {:ok, %{session | logout_at: NaiveDateTime.utc_now()}}
        end
      )

      assert {:ok, session} = AuthShield.logout(session.id)
      assert nil != session.logout_at
    end

    test "succeeds if complete session is valid", ctx do
      assert session = insert(:session, user_id: ctx.user.id)

      expect(
        DelegatorMock,
        :apply,
        fn {Authentication, :update_session},
           {Authentication.Sessions, :update},
           [%Session{} = sess, _params] ->
          assert session.id == sess.id
          {:ok, %{session | logout_at: NaiveDateTime.utc_now()}}
        end
      )

      assert {:ok, session} = AuthShield.logout(session)
      assert nil != session.logout_at
    end

    test "fails if session does not exist" do
      expect(
        DelegatorMock,
        :apply,
        fn {Authentication, :get_session_by}, {Authentication.Sessions, :get_by}, [[id: _id]] ->
          nil
        end
      )

      assert {:error, :session_not_found} == AuthShield.logout(Ecto.UUID.generate())
    end

    test "fails if session is expired", ctx do
      assert expiration =
               NaiveDateTime.utc_now()
               |> NaiveDateTime.add(-(60 * 20), :second)

      assert session = insert(:session, user_id: ctx.user.id, expiration: expiration)

      expect(
        DelegatorMock,
        :apply,
        fn {Authentication, :get_session_by}, {Authentication.Sessions, :get_by}, [[id: id]] ->
          assert session.id == id
          session
        end
      )

      assert {:error, :session_expired} == AuthShield.logout(session.id)
    end
  end
end
