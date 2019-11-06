defmodule AuthShield.Authentication.Plugs.AuthSession do
  @moduledoc """
  Helper plug for authenticated sessions.
  """

  import Plug.Conn

  alias AuthShield.Authentication.Schemas.Session
  alias Plug.Conn

  require Logger

  @behaviour Plug

  @impl true
  def init(opts \\ []), do: opts

  @impl true
  def call(%Conn{} = conn, opts \\ []) do
    with {:session, %Session{} = session} <- {:session, current_session(conn)},
         {:ip, remote_ip} when not is_nil(remote_ip) <- {:ip, current_remote_ip(conn)},
         {:agent, [user_agent]} when not is_nil(user_agent) <- {:agent, current_user_agent(conn)},
         {:valid_ip?, true} <- {:valid_ip?, session.remote_ip == remote_ip},
         {:valid_agent?, true} <- {:valid_agent?, session.user_agent == user_agent} do
      session
      |> AuthShield.refresh_session()
      |> case do
        {:ok, session} ->
          Logger.debug("[AuthPlug] session authenticated.")

          conn
          |> put_private(:session, session)
          |> put_status(200)

        {:error, :session_expired} ->
          Logger.debug("[AuthPlug] session expired.")
          handle_fallback(conn, {:error, :unauthenticated}, opts)

        {:error, _error} ->
          Logger.debug("[AuthPlug] failed to create the session.")
          raise Plug.BadRequestError
      end
    else
      {:session, nil} ->
        Logger.debug("[AuthPlug] session not found.")
        handle_fallback(conn, {:error, :unauthenticated}, opts)

      {:ip, nil} ->
        Logger.debug("[AuthPlug] remote_ip not found.")
        handle_fallback(conn, {:error, :unauthenticated}, opts)

      {:agent, []} ->
        Logger.debug("[AuthPlug] user_agent not found.")
        handle_fallback(conn, {:error, :unauthenticated}, opts)

      {:valid_ip?, false} ->
        Logger.debug("[AuthPlug] remote_ip is invalid for session.")
        handle_fallback(conn, {:error, :unauthenticated}, opts)

      {:valid_agent?, false} ->
        Logger.debug("[AuthPlug] user_agent is invalid for session.")
        handle_fallback(conn, {:error, :unauthenticated}, opts)
    end
  end

  @doc "Returns the current session"
  @spec current_session(Conn.t()) :: Session.t() | nil
  def current_session(%Conn{} = conn), do: conn.private[:session]

  @doc "Returns the current remote_ip"
  @spec current_remote_ip(Conn.t()) :: String.t() | nil
  def current_remote_ip(%Conn{} = conn), do: conn.remote_ip |> :inet_parse.ntoa() |> to_string()

  @doc "Returns the current user_agent"
  @spec current_user_agent(Conn.t()) :: [String.t()] | []
  def current_user_agent(%Conn{} = conn), do: get_req_header(conn, "user-agent")

  defp handle_fallback(%Conn{} = conn, error, opts) do
    if opts[:fallback] do
      opts[:fallback].call(conn, error)
    else
      send_resp(conn, 401, "Unauthenticated")
    end
  end
end
