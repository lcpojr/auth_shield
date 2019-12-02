defmodule AuthShield.Authentication.LoginAttemptsTest do
  use AuthShield.DataCase, async: true

  alias AuthShield.Authentication.Schemas.LoginAttempt
  alias AuthShield.Authentication.LoginAttempts

  setup do
    {:ok, user: insert(:user)}
  end

  describe "insert/1" do
    test "creates a new login_attempt on database", ctx do
      # Preparing params
      assert params = %{params_for(:login_attempt) | user_id: ctx.user.id}

      # Inserting login_attempt
      assert {:ok, login_attempt} = LoginAttempts.insert(params)
      assert login_attempt == Repo.get(LoginAttempt, login_attempt.id)
    end

    test "fails if params are empty" do
      assert {:error, changeset} = LoginAttempts.insert(%{})

      assert %{user_id: ["can't be blank"], status: ["can't be blank"]} == errors_on(changeset)
    end

    test "fails if params are invalid" do
      assert {:error, changeset} =
               LoginAttempts.insert(%{
                 status: 1,
                 remote_ip: 1,
                 user_id: 1,
                 user_agent: 1
               })

      assert %{
               status: ["is invalid"],
               remote_ip: ["is invalid"],
               user_agent: ["is invalid"],
               user_id: ["is invalid"]
             } == errors_on(changeset)
    end
  end

  describe "insert!/1" do
    test "creates a new login_attempt on database", ctx do
      # Preparing params
      assert params = %{params_for(:login_attempt) | user_id: ctx.user.id}

      # Inserting login_attempt
      assert login_attempt = LoginAttempts.insert!(params)
      assert login_attempt == Repo.get(LoginAttempt, login_attempt.id)
    end

    test "fails if params are empty" do
      assert_raise Ecto.InvalidChangesetError, fn -> LoginAttempts.insert!(%{}) end
    end

    test "fails if params are invalid" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        LoginAttempts.insert!(%{status: 1, remote_ip: 1, user_id: 1})
      end
    end
  end

  describe "list/1" do
    setup ctx do
      {:ok, login_attempts: insert_list(3, :login_attempt, user_id: ctx.user.id)}
    end

    test "return a list of login_attempts", ctx do
      assert ids = Enum.map(ctx.login_attempts, & &1.id)
      assert login_attempts = LoginAttempts.list()
      assert Enum.all?(login_attempts, &(&1.id in ids))
    end

    test "can filter list by database fields", ctx do
      assert [login_attempt1 | _] = ctx.login_attempts
      assert [login_attempt2] = LoginAttempts.list(remote_ip: login_attempt1.remote_ip)
      assert login_attempt1.id == login_attempt2.id
    end
  end

  describe "get_by/1" do
    setup ctx do
      {:ok, login_attempt: insert(:login_attempt, user_id: ctx.user.id)}
    end

    test "can get user by database fields", ctx do
      assert login_attempt = LoginAttempts.get_by(user_agent: ctx.login_attempt.user_agent)
      assert login_attempt.id == ctx.login_attempt.id
    end
  end

  describe "get_by!/1" do
    setup ctx do
      {:ok, login_attempt: insert(:login_attempt, user_id: ctx.user.id)}
    end

    test "can get user by database fields", ctx do
      assert login_attempt = LoginAttempts.get_by!(user_agent: ctx.login_attempt.user_agent)
      assert login_attempt.id == ctx.login_attempt.id
    end
  end
end
