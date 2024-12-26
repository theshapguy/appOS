defmodule PlanetWeb.Router do
  use PlanetWeb, :router

  import PlanetWeb.UserAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {PlanetWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :api_with_session do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    plug(:fetch_current_user)
  end

  pipeline :landing_layout do
    # Done
    plug :put_layout, html: {PlanetWeb.Layouts, :landing}
    plug(:put_secure_browser_headers)
  end

  pipeline :app_session_layout do
    plug :put_layout, html: {PlanetWeb.Layouts, :app_session}
    plug(:put_secure_browser_headers)
  end

  pipeline :app_settings_layout do
    plug :put_layout, html: {PlanetWeb.Layouts, :app_settings}
    plug(:put_secure_browser_headers)
  end

  pipeline :app_layout do
    plug :put_layout, html: {PlanetWeb.Layouts, :app_dashboard}
    plug(:put_secure_browser_headers)
  end

  pipeline :app_layout_live do
    plug :put_root_layout, {PlanetWeb.Layouts, :root_live}
  end

  pipeline :enforce_user_authentication do
    # Only require to be logged in
    plug :require_authenticated_user
    # Requires user to to have active subscription
    plug Planet.Plug.SubscriptionCheck
  end

  # Landing Pages
  scope "/", PlanetWeb do
    pipe_through([:browser, :landing_layout])

    get("/", PageController, :home)

    get("/plans", PageController, :plans)
    get("/transaction/pay", SubscriptionController, :transaction)

    get("/privacy", PageController, :privacy)
    get("/terms", PageController, :terms)
    get("/refund", PageController, :refund)

    get("/version", PageController, :version)
    get("/health", PageController, :health)
  end

  # Dashboard Scope
  scope "/", PlanetWeb do
    pipe_through([:browser, :app_layout_live])

    # Test Routes
    live "/templates", TemplateLive.Index, :index
    live "/templates/new", TemplateLive.Index, :new
    live "/templates/:id/edit", TemplateLive.Index, :edit

    live "/templates/:id", TemplateLive.Show, :show
    live "/templates/:id/show/edit", TemplateLive.Show, :edit

    live "/dummies", DummyLive.Index, :index
    live "/dummies/new", DummyLive.Index, :new
    live "/dummies/:id/edit", DummyLive.Index, :edit

    live "/dummies/:id", DummyLive.Show, :show
    live "/dummies/:id/show/edit", DummyLive.Show, :edit
  end

  # Dashboard Scope
  scope "/app/", PlanetWeb do
    pipe_through([:browser, :app_layout, :enforce_user_authentication])

    get("/", PageController, :app_home)
  end

  # Other scopes may use custom stacks.
  # scope "/api", PlanetWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  # if Application.compile_env(:planet, :dev_routes) do
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  scope "/dev" do
    pipe_through(:browser)

    if Application.compile_env(:planet, :dev_routes) do
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end

    pipe_through(:require_authenticated_superuser)

    import Phoenix.LiveDashboard.Router
    live_dashboard("/dashboard", metrics: PlanetWeb.Telemetry)
  end

  ## Authentication routes
  scope "/", PlanetWeb do
    pipe_through([:browser, :app_session_layout, :redirect_if_user_is_authenticated])

    get("/users/register", UserRegistrationController, :new)
    post("/users/register", UserRegistrationController, :create)
    get("/users/log_in", UserSessionController, :new)
    post("/users/log_in", UserSessionController, :create)
    get("/users/reset_password", UserResetPasswordController, :new)
    post("/users/reset_password", UserResetPasswordController, :create)
    get("/users/reset_password/:token", UserResetPasswordController, :edit)
    put("/users/reset_password/:token", UserResetPasswordController, :update)
  end

  scope "/auth", PlanetWeb do
    pipe_through [:browser]

    get "/:provider", UberAuthNController, :request
    get "/:provider/callback", UberAuthNController, :callback
  end

  scope "/", PlanetWeb do
    pipe_through([:browser, :app_session_layout])

    delete("/users/log_out", UserSessionController, :delete)
    get("/users/confirm", UserConfirmationController, :new)
    post("/users/confirm", UserConfirmationController, :create)
    get("/users/confirm/:token", UserConfirmationController, :edit)
    post("/users/confirm/:token", UserConfirmationController, :update)

    # User Invite To Organization
    get("/users/confirm/invite/:token", UserConfirmationController, :confirm_invite_edit)

    put(
      "/users/confirm/invite/:token",
      UserConfirmationController,
      :confirm_invite_update
    )
  end

  scope "/", PlanetWeb do
    pipe_through([:browser, :app_settings_layout, :enforce_user_authentication])

    get("/users/settings", UserSettingsController, :edit)
    put("/users/settings", UserSettingsController, :update)

    get("/users/settings/confirm_email/:token", UserSettingsController, :confirm_email)

    delete("/users/settings/credentials/:credential_id", UserSettingsController, :delete)

    # Organization Member Settings
    get("/users/settings/team", UserSettingsOrganizationController, :edit)
    put("/users/settings/team", UserSettingsOrganizationController, :update)

    resources "/users/settings/roles", RoleController,
      only: [:new, :edit, :create, :update, :delete]
  end

  scope "/", PlanetWeb do
    # :put_user_token
    pipe_through([:browser, :app_settings_layout, :require_authenticated_user])

    # Payment On SignUp
    get("/users/billing/signup", SubscriptionController, :payment)
    get("/users/billing/verify", SubscriptionController, :verify)
    get("/users/billing", SubscriptionController, :edit)
  end

  scope "/webhook", PlanetWeb do
    pipe_through([:api])

    # post("/paddle-classic", SubscriptionController, :paddle_webhook)

    # Payment Webhooks
    post("/paddle-billing", PaymentWebhookController, :paddle_webhook)
    post("/stripe", PaymentWebhookController, :stripe_webhook)
    post("/creem", PaymentWebhookController, :creem_webhook)
  end

  scope "/", PlanetWeb do
    pipe_through([
      :api_with_session,
      :require_authenticated_user
    ])

    post("/formdata-api/checkout-session", PaymentWebhookController, :payment_checkout_session)
  end
end
