apt update
# Install necessary system dependencies
apt install dhcpcd git build-essential libstdc++6 openssl libncurses5 locales erlang elixir
# Set up elixir package manager
mix local.hex --force && mix local.rebar --force
# Clone and enter into repository
git clone https://github.com/mc962/mt_kitchen.git && cd mt_kitchen || return
# Install elixir dependencies
mix deps.get --only "$MIX_ENV"
# Compile dependencies
mix deps.compile
# Compile static assets
mix assets.deploy
# Compile elixir project code
mix compile
# Generate a "production" release
mix release
