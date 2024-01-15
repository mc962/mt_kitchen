import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/mt_kitchen start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :mt_kitchen, MTKitchenWeb.Endpoint, server: true
end

if Enum.member?([:prod, :local], config_env()) do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  config :mt_kitchen, MTKitchen.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "alazykitchen.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :mt_kitchen, MTKitchenWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:

  if System.get_env("DEPLOY_ENV") == "local" do
    # Local "production" environment does not need complicated email infrastructure as all emails sent and received
    # through local services only.
    config :mt_kitchen, MTKitchen.Mailer, adapter: Swoosh.Adapters.Local
  else
    # Remote production environment uses Sendgrid so that users may receive emails to popular email services.
    config :mt_kitchen, MTKitchen.Mailer,
           adapter: Swoosh.Adapters.Sendgrid,
           api_key: System.get_env("SENDGRID_API_KEY")
  end

  config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.

  if config_env() == :prod do
    app_name =
      System.get_env("FLY_APP_NAME") ||
        raise "FLY_APP_NAME not available"

    config :libcluster,
           debug: true,
           topologies: [
             fly6pn: [
               strategy: Cluster.Strategy.DNSPoll,
               config: [
                 polling_interval: 5_000,
                 query: "#{app_name}.internal",
                 node_basename: app_name
               ]
             ]
           ]
  end



  config :ex_aws, :s3,
    scheme: "https://",
    host: "s3.amazonaws.com",
    region: "us-east-1",
    access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
    secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role],
    json_codec: Jason,
    storage_env: :live

  config :sentry,
    dsn: System.get_env("SENTRY_DSN"),
    environment_name: System.get_env("DEPLOY_ENV") || :local,
    enable_source_code_context: true,
    root_source_code_path: File.cwd!(),
    tags: %{
      env: "production"
    },
    included_environments: System.get_env("DEPLOY_ENV") || :local
end
