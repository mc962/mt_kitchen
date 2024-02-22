# Update package sources, assumes root user
apt update

# Set up non-root user
# Install sudo to allow for sudo users
apt install sudo
# Create and configure non-root superuser
adduser mt_kitchen
usermod -aG sudo mt_kitchen
apt install git
# Continue as non-sudo user
login
# Configure environment
echo "MIX_ENV=local" >> ~/.bashrc
echo "MIX_ENV=local" >> ~/.profile
# Clone and enter into repository
git clone https://github.com/mc962/mt_kitchen.git && cd mt_kitchen || return
./deploy/update.sh