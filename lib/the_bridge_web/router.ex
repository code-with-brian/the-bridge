defmodule TheBridgeWeb.Router do
  use TheBridgeWeb, :router

  import TheBridgeWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TheBridgeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :rate_limit_auth do
    plug TheBridgeWeb.Plugs.RateLimit, max_requests: 10, interval_ms: 60_000, key_prefix: "auth"
  end

  pipeline :rate_limit_payment do
    plug TheBridgeWeb.Plugs.RateLimit,
      max_requests: 20,
      interval_ms: 60_000,
      key_prefix: "payment"
  end

  # Authenticated pages — donors, workers, admins
  scope "/", TheBridgeWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :authenticated,
      on_mount: [{TheBridgeWeb.UserAuth, :require_authenticated}] do
      live "/dashboard", DashboardLive, :index
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email

      # Donor routes
      live "/my-donations", DonorLive.Donations, :index
      live "/my-donations/:id", DonorLive.DonationShow, :show
      live "/my-impact", DonorLive.Impact, :index

      # Agency worker/admin routes
      live "/agency", AgencyLive.Show, :show
      live "/agency/workers", AgencyLive.Workers, :index
      live "/agency/clients", AgencyLive.ClientIndex, :index
      live "/agency/clients/new", AgencyLive.ClientForm, :new
      live "/agency/clients/:id", AgencyLive.ClientShow, :show
      live "/agency/clients/:id/edit", AgencyLive.ClientForm, :edit
      live "/agency/clients/:id/needs/new", AgencyLive.NeedForm, :new
      live "/agency/clients/:id/updates/new", AgencyLive.UpdateForm, :new
      live "/agency/reports", AgencyLive.Reports, :index

      # Platform admin routes
      live "/admin", AdminLive.Dashboard, :index
      live "/admin/agencies", AdminLive.Agencies, :index
      live "/admin/vendors", AdminLive.Vendors, :index
      live "/admin/vendors/new", AdminLive.VendorForm, :new
      live "/admin/vendors/:id/edit", AdminLive.VendorForm, :edit
      live "/admin/users", AdminLive.Users, :index
      live "/admin/audit-log", AdminLive.AuditLog, :index
      live "/admin/moderation", AdminLive.Moderation, :index
      live "/admin/reports", AdminLive.Reports, :index
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  # Payment routes
  scope "/", TheBridgeWeb do
    pipe_through [:browser, :require_authenticated_user, :rate_limit_payment]

    get "/checkout/donate/:need_id", CheckoutController, :donate
  end

  # Stripe webhooks
  scope "/webhooks", TheBridgeWeb do
    pipe_through :api

    post "/stripe", WebhookController, :stripe
  end

  # Public pages
  scope "/", TheBridgeWeb do
    pipe_through :browser

    live_session :public,
      on_mount: [{TheBridgeWeb.UserAuth, :mount_current_scope}] do
      live "/", HomeLive, :index
      live "/clients", ClientLive.Index, :index
      live "/clients/:bridge_id", ClientLive.Show, :show
      live "/needs", NeedLive.Index, :index
      live "/needs/:id", NeedLive.Show, :show
      live "/needs/:id/donate", NeedLive.Donate, :new
      live "/impact", ImpactLive, :index
      live "/impact/:agency_slug", ImpactLive, :agency
    end
  end

  # User auth routes
  scope "/", TheBridgeWeb do
    pipe_through [:browser, :rate_limit_auth]

    live_session :current_user,
      on_mount: [{TheBridgeWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end

  # Development routes
  if Application.compile_env(:the_bridge, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TheBridgeWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
