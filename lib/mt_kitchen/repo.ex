defmodule MTKitchen.Repo do
  use Ecto.Repo,
    otp_app: :mt_kitchen,
    adapter: Ecto.Adapters.Postgres
end
