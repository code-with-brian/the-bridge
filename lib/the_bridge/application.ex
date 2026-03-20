defmodule TheBridge.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TheBridgeWeb.Telemetry,
      TheBridge.Repo,
      {DNSCluster, query: Application.get_env(:the_bridge, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TheBridge.PubSub},
      {Oban, Application.fetch_env!(:the_bridge, Oban)},
      TheBridgeWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: TheBridge.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    TheBridgeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
