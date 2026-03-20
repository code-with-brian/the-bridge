defmodule TheBridgeWeb.PageController do
  use TheBridgeWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
