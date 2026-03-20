defmodule TheBridgeWeb.Plugs.RateLimit do
  @moduledoc """
  Rate limiting plug using Hammer.
  """

  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  def init(opts), do: opts

  def call(conn, opts) do
    if Application.get_env(:the_bridge, :skip_rate_limit) do
      conn
    else
      max_requests = Keyword.get(opts, :max_requests, 10)
      interval_ms = Keyword.get(opts, :interval_ms, 60_000)
      key_prefix = Keyword.get(opts, :key_prefix, "default")

      key = "#{key_prefix}:#{client_ip(conn)}"

      case Hammer.check_rate(key, interval_ms, max_requests) do
        {:allow, _count} ->
          conn

        {:deny, _limit} ->
          conn
          |> put_status(429)
          |> json(%{error: "Rate limit exceeded. Please try again later."})
          |> halt()
      end
    end
  end

  defp client_ip(conn) do
    forwarded_for =
      conn
      |> get_req_header("x-forwarded-for")
      |> List.first()

    if forwarded_for do
      forwarded_for |> String.split(",") |> List.first() |> String.trim()
    else
      conn.remote_ip |> :inet.ntoa() |> to_string()
    end
  end
end
