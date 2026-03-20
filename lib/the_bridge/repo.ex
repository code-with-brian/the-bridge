defmodule TheBridge.Repo do
  use Ecto.Repo,
    otp_app: :the_bridge,
    adapter: Ecto.Adapters.Postgres
end
