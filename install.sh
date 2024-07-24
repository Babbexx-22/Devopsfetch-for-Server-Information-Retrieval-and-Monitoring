#!/bin/bash

# Function to install necessary dependencies
install_dependencies() {
    echo "Updating package lists..."
    sudo apt-get update || { echo "Error: Failed to update package lists."; exit 1; }
    
    echo "Installing necessary packages..."
    sudo apt-get install -y net-tools iproute2 docker.io nginx jq || { echo "Error: Failed to install packages."; exit 1; }
}

# Function to move the script to /usr/local/bin
move_script() {
    echo "Moving devopsfetch.sh to /usr/local/bin..."
    sudo cp devopsfetch /usr/local/bin/devopsfetch || { echo "Error: Failed to move the script to /usr/local/bin."; exit 1; }

    # Ensure the script has executable permissions
    sudo chmod +x /usr/local/bin/devopsfetch || { echo "Error: Failed to set executable permissions."; exit 1; }
}

# Function to set up the systemd service
setup_service() {
    echo "Setting up systemd service..."

    # Create a systemd service file
    cat <<EOF | sudo tee /etc/systemd/system/devopsfetch.service
[Unit]
Description=DevOpsFetch Monitoring Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/devopsfetch
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd to apply changes
    sudo systemctl daemon-reload || { echo "Error: Failed to reload systemd daemon."; exit 1; }
    
    # Enable and start the service
    sudo systemctl enable devopsfetch.service || { echo "Error: Failed to enable devopsfetch service."; exit 1; }
    sudo systemctl start devopsfetch.service || { echo "Error: Failed to start devopsfetch service."; exit 1; }
}

# Function to set up log rotation
setup_logrotate() {
    echo "Setting up log rotation..."

    cat << EOF | sudo tee /etc/logrotate.d/devopsfetch
/var/log/devopsfetch.log {
    hourly
    rotate 288
    compress
    missingok
    notifempty
    create 666 root root
}
EOF
}

# Function to adjust permissions
adjust_permissions() {
    echo "Adjusting permissions..."

    # Set permissions for Docker
    sudo usermod -aG docker $USER || { echo "Error: Failed to add user to Docker group."; exit 1; }

    # Set log file permissions
    sudo touch /var/log/devopsfetch.log || { echo "Error: Failed to create log file."; exit 1; }
    sudo chmod 666 /var/log/devopsfetch.log || { echo "Error: Failed to set log file permissions."; exit 1; }
}

# Main script execution
install_dependencies
move_script
setup_service
setup_logrotate
adjust_permissions

echo "Setup complete. Please log out and log back in to apply group changes."
