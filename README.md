## Devopsfetch-for-Server-Information-Retrieval-and-Monitoring

## Overview
DevOpsFetch is a tool designed for DevOps professionals to collect and display critical system information. It monitors various aspects of the system including active ports, Docker images and containers, Nginx configurations, and user logins. The tool runs as a service and supports continuous monitoring with log rotation.

## Features
- Active Ports: Lists all active ports and services.
- Docker: Lists Docker images and containers, and retrieves detailed container information.
- Nginx: Displays Nginx domains and configurations.
- Users: Lists users and their last login times.
- Time Range: Displays activities within a specified time range.

## Installation and Configuration
Installation Script:
The install.sh script automates the installation and setup of DevOpsFetch, including necessary dependencies, permissions, systemd service configuration, and log rotation. Follow these steps to run the installation script:

## Run the Installation Script
```
sudo ./install.sh
```

## Script Breakdown

Install_dependencies Function: Updates package lists and installs required packages (net-tools, iproute2, docker.io, nginx, jq).
```
  install_dependencies() {
    echo "Updating package lists..."
    sudo apt-get update || { echo "Error: Failed to update package lists."; exit 1; }
    
    echo "Installing necessary packages..."
    sudo apt-get install -y net-tools iproute2 docker.io nginx jq || { echo "Error: Failed to install packages."; exit 1; }
}
```

Move_script Function: Moves the devopsfetch script to /usr/local/bin and sets executable permissions.
```
move_script() {
    echo "Moving devopsfetch.sh to /usr/local/bin..."
    sudo mv devopsfetch /usr/local/bin/devopsfetch || { echo "Error: Failed to move the script to /usr/local/bin."; exit 1; }

    sudo chmod +x /usr/local/bin/devopsfetch || { echo "Error: Failed to set executable permissions."; exit 1; }
}
```

Setup_service Function: Configures the systemd service for continuous monitoring and logging.
```
setup_service() {
    echo "Setting up systemd service..."

    cat <<EOF | sudo tee /etc/systemd/system/devopsfetch.service
[Unit]
Description=DevOpsFetch Monitoring Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/devopsfetch -l
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload || { echo "Error: Failed to reload systemd daemon."; exit 1; }
    sudo systemctl enable devopsfetch.service || { echo "Error: Failed to enable devopsfetch service."; exit 1; }
    sudo systemctl start devopsfetch.service || { echo "Error: Failed to start devopsfetch service."; exit 1; }
}
```

Adjust_permissions Function: Adjusts user permissions for Docker and sets up the log file with appropriate permissions.
```
adjust_permissions() {
    echo "Adjusting permissions..."

    sudo usermod -aG docker $USER || { echo "Error: Failed to add user to Docker group."; exit 1; }
    sudo touch /var/log/devopsfetch.log || { echo "Error: Failed to create log file."; exit 1; }
    sudo chmod 666 /var/log/devopsfetch.log || { echo "Error: Failed to set log file permissions."; exit 1; }
}
```

## Logging Mechanism and How to Retrieve Logs

### Logging Mechanism:
The devopsfetch tool includes a robust logging mechanism to continuously monitor and record system activities. This is achieved through a systemd service, which ensures that the monitoring runs continuously in the background. Logs are recorded in a dedicated log file, /var/log/devopsfetch.log, with detailed information about the execution of various devopsfetch commands.

To manage the log file and prevent it from growing indefinitely, we have implemented a log rotation system. The log rotation is configured to rotate the log file hourly and keep up to 288 compressed logs. This setup ensures that the log data is kept manageable and does not consume excessive disk space.

Log Rotation File: "/etc/logrotate.d/devopsfetch"

```
/var/log/devopsfetch.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 666 root root
    postrotate
        systemctl restart devopsfetch.service > /dev/null 2>&1 || true
    endscript
}
```
- daily: Rotates the log file every day.
- rotate 7: Keeps the last 7 rotated log files.
- compress: Compresses old log files to save space.
- missingok: Ignores errors if the log file is missing.
- notifempty: Does not rotate the log file if it is empty.
- create 666 root root: Creates a new log file with the specified permissions and ownership after rotation.
- postrotate: Runs a script after rotating the log file to restart the devopsfetch service, ensuring it writes to the new log file.

### How to Retrieve Logs:

- View Current Log:
To view the latest logs, you can use the cat or tail command. For example:
```
cat /var/log/devopsfetch.log
```
or to continuously monitor the log output, you can use:

```
tail -f /var/log/devopsfetch.log
```

## Usage

## Command-Line Flags

- "-p" or "--port": Display all active ports and services or provide detailed information about a specific port.
```
devopsfetch -p
devopsfetch -p 80
```
- "-d" or "--docker": List all Docker images and containers, or provide detailed information about a specific container.
```
devopsfetch -d
devopsfetch -d <container_name>
```
- -n or --nginx: Display all Nginx domains and their ports, or provide detailed configuration information for a specific domain.
```
devopsfetch -n
devopsfetch -n <domain>
```

- -u or --users: List all users and their last login times, or provide detailed information about a specific user.
```
devopsfetch -u
devopsfetch -u <username>
```

- -t or --time: Display activities within a specified time range.
```
devopsfetch -t "start_time end_time"
```

- -h or --help: Display usage instructions for the program.
```
devopsfetch -h
```
