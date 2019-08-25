defmodule AuthXTest do
  use AuthX.DataCase, async: true

  alias AuthX.Authentication.Schemas.Session
  alias AuthX.Resources.Schemas.User

  describe "signup/1" do
    test "succeeds if params are valid" do
      assert {:ok, _user} =
               AuthX.signup(%{
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
              }} == AuthX.signup(%{})
    end
  end

  describe "login/1" do
    setup do
      user = insert(:user)
      password = insert(:password, params_for(:password) |> Map.put(:user_id, user.id))
      {:ok, user: user, password: password}
    end

    test "succeeds if params are valid", ctx do
      assert user = Repo.update!(User.changeset_status(ctx.user, %{is_active: true}))

      assert ip = "172.31.4.1"
      assert user_agent = "Mozilla/5.0 (Windows NT x.y; rv:10.0) Gecko/20100101 Firefox/10.0"

      assert {:ok, session} =
               AuthX.login(
                 %{
                   "email" => ctx.user.email,
                   "password" => "My_passw@rd1"
                 },
                 ip_address: ip,
                 user_agent: user_agent
               )

      assert nil != session.login_at
    end

    test "fails on validation if params are invalid" do
      assert {:error, %{email: ["can't be blank"], password: ["can't be blank"]}} ==
               AuthX.login(%{})
    end

    test "fails if user does not exist" do
      assert {:error, :user_not_found} ==
               AuthX.login(%{"email" => "wrong_email@gmail.com", "password" => "My_passw@rd1"})
    end

    test "fails if password is wrong", ctx do
      assert {:error, :unauthenticated} ==
               AuthX.login(%{"email" => ctx.user.email, "password" => "123456"})
    end
  end

  describe "refresh_session/1" do
    setup do
      {:ok, session: insert(:session)}
    end

    test "succeeds session is valid", ctx do
      assert {:ok, _session} = AuthX.refresh_session(ctx.session.id)
    end

    test "fails if session does not exist" do
      assert {:error, :session_not_found} == AuthX.refresh_session(UUID.uuid4())
    end

    test "fails if session is expired", ctx do
      assert expiration = Timex.now() |> Timex.subtract(Timex.Duration.from_minutes(20))
      assert Repo.update(Session.update_changeset(ctx.session, %{expiration: expiration}))
      assert {:error, :session_expired} == AuthX.refresh_session(ctx.session.id)
    end
  end

  describe "logout/1" do
    setup do
      {:ok, session: insert(:session)}
    end

    test "succeeds if session is valid", ctx do
      assert {:ok, session} = AuthX.logout(ctx.session.id)
      assert nil != session.logout_at
    end

    test "fails if session does not exist" do
      assert {:error, :session_not_found} == AuthX.logout(UUID.uuid4())
    end

    test "fails if session is expired", ctx do
      assert expiration = Timex.now() |> Timex.subtract(Timex.Duration.from_minutes(20))
      assert Repo.update(Session.update_changeset(ctx.session, %{expiration: expiration}))
      assert {:error, :session_expired} == AuthX.logout(ctx.session.id)
    end
  end
end
