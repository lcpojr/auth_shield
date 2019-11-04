defmodule AuthShield.Authentication.SessionsTest do
  use AuthShield.DataCase, async: true

  alias AuthShield.Authentication.Schemas.Session
  alias AuthShield.Authentication.Sessions

  setup do
    {:ok, user: insert(:user)}
  end

  describe "insert/1" do
    test "creates a new session on database", ctx do
      # Preparing params
      assert params = %{params_for(:session) | user_id: ctx.user.id}

      # Inserting session
      assert {:ok, session} = Sessions.insert(params)
      assert session == Repo.get(Session, session.id)
    end

    test "fails if params are empty" do
      assert {:error, changeset} = Sessions.insert(%{})

      assert %{
               expiration: ["can't be blank"],
               login_at: ["can't be blank"],
               user_id: ["can't be blank"]
             } == errors_on(changeset)
    end

    test "fails if params are invalid" do
      assert {:error, changeset} =
               Sessions.insert(%{
                 expiration: 1,
                 remote_ip: 1,
                 login_at: 1,
                 user_id: 1,
                 user_agent: 1
               })

      assert %{
               expiration: ["is invalid"],
               remote_ip: ["is invalid"],
               user_agent: ["is invalid"],
               login_at: ["is invalid"],
               user_id: ["is invalid"]
             } == errors_on(changeset)
    end
  end

  describe "insert!/1" do
    test "creates a new session on database", ctx do
      # Preparing params
      assert params = %{params_for(:session) | user_id: ctx.user.id}

      # Inserting session
      assert session = Sessions.insert!(params)
      assert session == Repo.get(Session, session.id)
    end

    test "fails if params are empty" do
      assert_raise Ecto.InvalidChangesetError, fn -> Sessions.insert!(%{}) end
    end

    test "fails if params are invalid" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        Sessions.insert!(%{expiration: 1, remote_ip: 1, login_at: 1, user_id: 1})
      end
    end
  end

  describe "update/2" do
    setup do
      {:ok, session: insert(:session)}
    end

    test "updates a session on database", ctx do
      assert {:ok, session} =
               Sessions.update(
                 ctx.session,
                 %{params_for(:session) | expiration: NaiveDateTime.utc_now()}
               )

      assert session != ctx.session
    end

    test "fails if params are invalid", ctx do
      assert {:error, changeset} = Sessions.update(ctx.session, %{expiration: 1})
      assert %{expiration: ["is invalid"]} == errors_on(changeset)
    end
  end

  describe "update!/2" do
    setup do
      {:ok, session: insert(:session)}
    end

    test "updates a user on database", ctx do
      assert session =
               Sessions.update!(
                 ctx.session,
                 %{params_for(:session) | expiration: NaiveDateTime.utc_now()}
               )

      assert session != ctx.session
    end

    test "fails if params are invalid", ctx do
      assert_raise Ecto.InvalidChangesetError, fn ->
        Sessions.update!(ctx.session, %{expiration: 1})
      end
    end
  end

  describe "list/1" do
    setup do
      {:ok, sessions: insert_list(3, :session)}
    end

    test "return a list of sessions", ctx do
      assert ids = Enum.map(ctx.sessions, & &1.id)
      assert sessions = Sessions.list()
      assert Enum.all?(sessions, &(&1.id in ids))
    end

    test "can filter list by database fields", ctx do
      assert [session1 | _] = ctx.sessions
      assert [session2] = Sessions.list(remote_ip: session1.remote_ip)
      assert session1.id == session2.id
    end
  end

  describe "get_by/1" do
    setup do
      {:ok, session: insert(:session)}
    end

    test "can get user by database fields", ctx do
      assert session = Sessions.get_by(user_agent: ctx.session.user_agent)
      assert session.id == ctx.session.id
    end
  end

  describe "get_by!/1" do
    setup do
      {:ok, session: insert(:session)}
    end

    test "can get user by database fields", ctx do
      assert session = Sessions.get_by!(user_agent: ctx.session.user_agent)
      assert session.id == ctx.session.id
    end
  end
end
