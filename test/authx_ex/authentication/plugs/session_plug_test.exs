defmodule AuthX.Authentication.Plugs.AuthSessionTest do
  use AuthX.DataCase, async: true
  use Plug.Test

  alias AuthX.Authentication.Plugs.AuthSession

  describe "GET /users" do
    setup do
      {:ok, session: insert(:session)}
    end

    test "succeeds session if authenticated and is the same application", ctx do
      assert {:ok, remote_ip} = :inet.parse_address('#{ctx.session.remote_ip}')

      assert conn =
               :get
               |> conn("/users")
               |> put_req_header("user-agent", ctx.session.user_agent)
               |> put_private(:session, ctx.session)
               |> Map.put(:remote_ip, remote_ip)
               |> AuthSession.call()

      assert 200 == conn.status
    end

    test "fails if user-agent is different", ctx do
      assert {:ok, remote_ip} = :inet.parse_address('#{ctx.session.remote_ip}')

      assert conn =
               :get
               |> conn("/users")
               |> put_req_header("user-agent", "Googlebot/2.1 (+http://www.google.com/bot.html)")
               |> put_private(:session, ctx.session)
               |> Map.put(:remote_ip, remote_ip)
               |> AuthSession.call()

      assert 401 == conn.status
    end

    test "fails if remote-ip is different", ctx do
      assert conn =
               :get
               |> conn("/users")
               |> put_req_header("user-agent", ctx.session.user_agent)
               |> put_private(:session, ctx.session)
               |> AuthSession.call()

      assert 401 == conn.status
    end

    test "fails if session not found", ctx do
      assert {:ok, remote_ip} = :inet.parse_address('#{ctx.session.remote_ip}')

      assert conn =
               :get
               |> conn("/users")
               |> put_req_header("user-agent", ctx.session.user_agent)
               |> Map.put(:remote_ip, remote_ip)
               |> AuthSession.call()

      assert 401 == conn.status
    end
  end
end
