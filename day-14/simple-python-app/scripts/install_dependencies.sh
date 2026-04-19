#!/bin/bash
# install_dependencies.sh
# This script installs the required dependencies for the simple-python-app
# Used by AWS CodeDeploy during the Install lifecycle event

set -e

echo "Starting dependency installation..."

# Update package list
apt-get update -y

# Install Python3 and pip if not already installed
apt-get install -y python3 python3-pip

# Install Docker if not already installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
    # Add ubuntu user to docker group so we can run docker without sudo
    usermod -aG docker ubuntu
else
    echo "Docker is already installed."
fi

# Navigate to the application directory
cd /home/ubuntu/simple-python-app

# Install Python dependencies
if [ -f requirements.txt ]; then
    echo "Installing Python requirements..."
    pip3 install -r requirements.txt
else
    echo "No requirements.txt found, installing Flask directly..."
    # Pinning to a specific version for reproducibility
    pip3 install flask==2.3.3
fi

echo "Dependency installation completed successfully."
