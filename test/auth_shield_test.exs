defmodule AuthShieldTest do
  use AuthShield.DataCase, async: true

  alias AuthShield.{DelegatorMock, Credentials, Resources}
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
    test "succeeds session is valid" do
      assert session = insert(:session)
      assert {:ok, %Session{}} = AuthShield.refresh_session(session.id)
    end

    test "fails if session does not exist" do
      assert {:error, :session_not_found} == AuthShield.refresh_session(Ecto.UUID.generate())
    end

    test "fails if session is expired" do
      assert expiration =
               NaiveDateTime.utc_now()
               |> NaiveDateTime.add(-(60 * 20), :second)

      assert session = insert(:session, expiration: expiration)
      assert {:error, :session_expired} == AuthShield.refresh_session(session.id)
    end
  end

  describe "logout/1" do
    setup do
      {:ok, session: insert(:session)}
    end

    test "succeeds if session is valid", ctx do
      assert {:ok, session} = AuthShield.logout(ctx.session.id)
      assert nil != session.logout_at
    end

    test "fails if session does not exist" do
      assert {:error, :session_not_found} == AuthShield.logout(Ecto.UUID.generate())
    end

    test "fails if session is expired", ctx do
      assert expiration =
               NaiveDateTime.utc_now()
               |> NaiveDateTime.add(-(60 * 20), :second)

      assert Repo.update(Session.update_changeset(ctx.session, %{expiration: expiration}))
      assert {:error, :session_expired} == AuthShield.logout(ctx.session.id)
    end
  end
end
