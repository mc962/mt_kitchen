# Update package sources, assumes root user
apt update

# Set up non-root user
# Install sudo to allow for sudo users
apt install sudo
# Create and configure non-root superuser
createuser mt_kitchen
usermod -aG sudo mt_kitchen
apt install git
# Continue as non-sudo user
login
# Configure environment
echo "MIX_ENV=local" >> ~/.bashrc
./deploy/update.sh