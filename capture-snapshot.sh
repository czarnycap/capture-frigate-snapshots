#!/bin/bash

# Define variables
SCRIPT_BASE_FOLDER=$(dirname "$0")
source "${SCRIPT_BASE_FOLDER}/.env"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
# Use the first argument as the output directory, or default to the specified directory
#SCRIPT_BASE_FOLDER
OUTPUT_DIR=${1:-"${SCRIPT_BASE_FOLDER}/snapshots/"}  
# Load variables from .env file


# Define RTSP URLs using the loaded variables
RTSP_URLS=(
    ${RTSP_URL_1}
    ${RTSP_URL_2}
    ${RTSP_URL_3}
    ${RTSP_URL_4}
    ${RTSP_URL_5}
    # Add more RTSP URLs as needed in the .env file
)

# Create a log directory if it doesn't exist
LOG_DIR="${SCRIPT_BASE_FOLDER}/log"
mkdir -p "$LOG_DIR"

# Define the log file with the current date
LOG_FILE="$LOG_DIR/capture_snapshot_$(date +"%Y-%m-%d").log"

# Ensure the output directory exists
mkdir -p "$OUTPUT_DIR"

# Function to generate camera name from RTSP URL
generate_camera_name() {
    local rtsp_url=$1
    local ip_address=$(echo "$rtsp_url" | awk -F'[@:]' '{print $4}')
    echo "${ip_address//./_}"
}

# Capture snapshots for each RTSP URL
for RTSP_URL in "${RTSP_URLS[@]}"; do
    CAMERA_NAME=$(generate_camera_name "$RTSP_URL")
    
    # Ensure CAMERA_NAME is not empty
    if [ -z "$CAMERA_NAME" ]; then
        echo "[$(date +"%Y-%m-%d %H:%M:%S")] Failed to generate camera name for $RTSP_URL" >> "$LOG_FILE"
        continue
    fi
    
    CAMERA_DIR="$OUTPUT_DIR/$CAMERA_NAME"
    mkdir -p "$CAMERA_DIR"
    OUTPUT_FILE="$CAMERA_DIR/snapshot_${CAMERA_NAME}_$TIMESTAMP.jpg"
    
    ffmpeg -i "$RTSP_URL" -frames:v 1 -s hd1080 "$OUTPUT_FILE" -y
    
    if [ $? -eq 0 ]; then
        echo "[$(date +"%Y-%m-%d %H:%M:%S")] Successfully captured snapshot for $CAMERA_NAME" >> "$LOG_FILE"
    else
        echo "[$(date +"%Y-%m-%d %H:%M:%S")] Failed to capture snapshot for $CAMERA_NAME" >> "$LOG_FILE"
    fi
done