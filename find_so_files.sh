#!/bin/bash
mkdir -p /tmp/so_files
find /usr/lib/x86_64-linux-gnu -name "*.so*" -exec cp {} /tmp/so_files \; || echo "No .so files found or other error occurred"
