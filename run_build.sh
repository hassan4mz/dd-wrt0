#!/bin/bash
###############################################################################
# DD-WRT Quick Start Script
# Runs the full build process with a single command
###############################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "DD-WRT Build Automation for Raisecom Devices"
echo "=========================================="
echo ""
echo "This script will:"
echo "1. Install required dependencies (sudo required)"
echo "2. Download DD-WRT source code (~2GB)"
echo "3. Apply device patches (if any)"
echo "4. Configure and compile firmware"
echo "5. Save output to ./output directory"
echo ""
echo "⚠️  WARNING: This process can take 1-4 hours!"
echo "⚠️  Ensure you have at least 10GB free disk space."
echo ""
read -p "Do you want to continue? (y/n): " confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Build cancelled."
    exit 0
fi

# Execute the main build script
exec "$SCRIPT_DIR/build_ddwrt.sh"
