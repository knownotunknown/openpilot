#!/bin/bash

# Create the destination directory for .so files
mkdir -p /tmp/so_files

# File to store the list of critical system libraries
critical_libs_file="/tmp/critical_libs.list"

# Populate critical_libs file with .so files from the directory if it's the first run
if [ ! -f "$critical_libs_file" ]; then
    echo "Populating critical libraries list..."
    find /usr/lib/x86_64-linux-gnu -type f -name "*.so*" -exec basename {} \; > "$critical_libs_file"
fi

# Read the list of critical libraries into an array
mapfile -t critical_libs < "$critical_libs_file"

# Function to check if the file is a critical library
is_critical() {
    local file=$(basename "$1")
    for lib in "${critical_libs[@]}"; do
        if [[ "$file" == "$lib" ]]; then
            return 0
        fi
    done
    return 1
}

# Find and copy .so files, excluding critical system libraries
find /usr/lib/x86_64-linux-gnu -type f -name "*.so*" | while read -r so_file; do
    if ! is_critical "$so_file"; then
        cp "$so_file" /tmp/so_files/
    fi
done || echo "No .so files found or other error occurred"
