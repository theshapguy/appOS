defmodule AppOSWeb.Router do
  use AppOSWeb, :router

  import AppOSWeb.UserAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {AppOSWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :landing_layout do
    # Done
    plug :put_layout, html: {AppOSWeb.Layouts, :landing}
  end

  pipeline :app_session_layout do
    plug :put_layout, html: {AppOSWeb.Layouts, :app_session}
  end

  pipeline :app_settings_layout do
    plug :put_layout, html: {AppOSWeb.Layouts, :app_settings}
  end

  pipeline :app_layout_live do
    plug(:put_root_layout, {AppOSWeb.Layouts, :root_live})

    # plug :put_layout, html: {AppOSWeb.Layouts, :app_dashboard}
  end

  pipeline :app_layout do
    plug :put_layout, html: {AppOSWeb.Layouts, :app_dashboard}
  end

  # pipeline :paddle_webhook do
  #   plug(:accepts, ["json"])
  # end

  # pipeline :paddle_webhook do
  #   # plug(RemoteIp)
  #   # plug(PaddleWhitelist)
  #   plug(AppOS.Subscriptions.PaddleSignature)
  # end

  # Landing Pages
  scope "/", AppOSWeb do
    pipe_through([:browser, :landing_layout])

    get("/", PageController, :home)
    # get("/terms", PageController, :home)
    # get("/privacy", PageController, :home)
    # get("/contact", PageController, :home)
  end

  # Dashboard Scope
  scope "/", AppOSWeb do
    pipe_through([:browser, :app_layout_live])

    # Test Routes
    live "/templates", TemplateLive.Index, :index
    live "/templates/new", TemplateLive.Index, :new
    live "/templates/:id/edit", TemplateLive.Index, :edit

    live "/templates/:id", TemplateLive.Show, :show
    live "/templates/:id/show/edit", TemplateLive.Show, :edit
  end

  # Dashboard Scope
  scope "/app/", AppOSWeb do
    pipe_through([:browser, :app_layout, :require_authenticated_user])

    get("/", PageController, :app_home)
  end

  # Other scopes may use custom stacks.
  # scope "/api", AppOSWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:appOS, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: AppOSWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  ## Authentication routes

  scope "/", AppOSWeb do
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

  scope "/", AppOSWeb do
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

  scope "/", AppOSWeb do
    pipe_through([:browser, :app_settings_layout, :require_authenticated_user])

    get("/users/settings", UserSettingsController, :edit)
    put("/users/settings", UserSettingsController, :update)

    get("/users/settings/confirm_email/:token", UserSettingsController, :confirm_email)

    delete("/users/settings/credentials/:credential_id", UserSettingsController, :delete)

    # Organization Member Settings
    get("/users/settings/team", UserSettingsOrganizationController, :edit)
    put("/users/settings/team", UserSettingsOrganizationController, :update)

    resources "/users/settings/roles", RoleController,
      only: [:new, :edit, :create, :update, :delete]

    get("/users/billing", SubscriptionController, :edit)

    # live_session :roles,
    #   on_mount: [
    #     {AppOSWeb.UserAuthLive, :require_authenticated_user}
    #   ] do
    #   live "/roles", RoleLive.Index, :index
    #   live "/roles/new", RoleLive.Index, :new
    #   live "/roles/:id/edit", RoleLive.Index, :edit

    #   live "/roles/:id", RoleLive.Show, :show
    #   live "/roles/:id/show/edit", RoleLive.Show, :edit
    # end
  end

  scope "/webhook", AppOSWeb do
    pipe_through([:api])

    post("/paddle", SubscriptionController, :paddle_webhook)
  end
end
