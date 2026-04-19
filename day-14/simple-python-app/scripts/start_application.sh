#!/bin/bash

# Start Application Script
# This script starts the Python application as a systemd service
# or directly using gunicorn/python depending on the environment.

set -e

APP_DIR="/home/ubuntu/app"
LOG_DIR="/var/log/simple-python-app"
APP_USER="ubuntu"

# Create log directory if it doesn't exist
if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR"
    chown "$APP_USER":"$APP_USER" "$LOG_DIR"
fi

# Navigate to app directory
cd "$APP_DIR"

# Activate virtual environment if it exists
if [ -f "$APP_DIR/venv/bin/activate" ]; then
    source "$APP_DIR/venv/bin/activate"
fi

# Check if the app is already running and stop it
if pgrep -f "app.py" > /dev/null; then
    echo "Application is already running. Stopping existing instance..."
    pkill -f "app.py" || true
    sleep 2
fi

# Start the Flask application using gunicorn for production
if command -v gunicorn &> /dev/null; then
    echo "Starting application with Gunicorn..."
    nohup gunicorn \
        --workers 2 \
        --bind 0.0.0.0:5000 \
        --log-file "$LOG_DIR/gunicorn.log" \
        --access-logfile "$LOG_DIR/access.log" \
        --error-logfile "$LOG_DIR/error.log" \
        --daemon \
        app:app
else
    echo "Gunicorn not found. Starting application with Python directly..."
    nohup python3 app.py \
        > "$LOG_DIR/app.log" 2>&1 &
fi

# Wait a moment and verify the application started
sleep 3

if pgrep -f "app.py\|gunicorn" > /dev/null; then
    echo "Application started successfully."
else
    echo "ERROR: Application failed to start. Check logs at $LOG_DIR"
    exit 1
fi
