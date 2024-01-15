defmodule MTKitchenWeb.Router do
  use MTKitchenWeb, :router

  import MTKitchenWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {MTKitchenWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MTKitchenWeb do
    pipe_through :browser

    live "/", PageLive.Index, :index, as: :root

    live "/recipes", RecipeLive.Index, :index
    live "/recipes/:id", RecipeLive.Show, :show
  end

  # Authenticate Scope
  scope "/", MTKitchenWeb do
    pipe_through [:browser, :require_authenticated_user]

    scope "/manage", as: :manage do
      live "/", Manage.AccountLive.Show, :show, as: :account
      live "/recipes", Manage.RecipeLive.Index, :index, as: :recipe
      live "/recipes/new", Manage.RecipeLive.New, :new, as: :recipe
      live "/recipes/:id", Manage.RecipeLive.Show, :show, as: :recipe
      live "/recipes/:id/edit", Manage.RecipeLive.Edit, :edit, as: :recipe
      # Edit all recipe steps together
      live "/recipes/:id/steps/edit", Manage.StepLive.Edit, :edit, as: :recipe_steps
      # Edit all ingredients in a step together
      live "/recipes/:recipe_id/steps/:id/edit", Manage.StepIngredientLive.Edit, :edit,
        as: :step_ingredients

      # User Management
      live "/users", Manage.UserLive.Index, :index, as: :users
      live "/users/:id", Manage.UserLive.Show, :show, as: :user
      live "/users/:id/edit", Manage.UserLive.Edit, :edit, as: :user
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", MTKitchenWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MTKitchenWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev || Mix.env == :local do
    scope "/dev" do
      pipe_through [:browser, :require_authenticated_user]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", MTKitchenWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", MTKitchenWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/", MTKitchenWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end
end
