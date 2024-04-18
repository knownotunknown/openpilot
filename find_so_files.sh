#!/bin/bash

# Define the directory for storing .so files and the critical_libs file
base_dir="/tmp_so_files"

# Create the base directory if it doesn't already exist
mkdir -p "$base_dir"

# File to store the list of critical system libraries
critical_libs_file="$base_dir/critical_libs.list"

# Check if the critical_libs file does not exist
if [ ! -f "$critical_libs_file" ]; then
    echo "Populating critical libraries list with test data..."
    touch "$critical_libs_file"  # Ensure the file is created
    echo "libtest.so" > "$critical_libs_file"  # Add a test entry to the file
    # Additionally try to find and append actual .so files
    find /usr/lib/x86_64-linux-gnu -type f -name "*.so*" -exec basename {} \; >> "$critical_libs_file"
    # Append new Python .so files to the critical_libs.list
    find /usr/local/lib/python3.11 -type f -name "*.so*" -exec basename {} \; >> "$base_dir/critical_libs.list"
else
    echo "File already exists. Checking contents:"
    cat "$critical_libs_file"  # Display the contents for debugging

    mkdir -p "$base_dir/so_files"  # Create the directory for .so files if it doesn't exist

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
            cp "$so_file" "$base_dir/so_files/"
        fi
    done || echo "No .so files found or other error occurred"
fi
