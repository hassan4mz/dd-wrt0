#!/bin/bash
###############################################################################
# DD-WRT Environment Setup Script (Ubuntu/Debian)
# Installs all required build dependencies
###############################################################################

set -e

echo "=========================================="
echo "DD-WRT Build Environment Setup"
echo "=========================================="
echo ""

# Update package lists
echo "Updating package lists..."
sudo apt-get update

# Required packages for DD-WRT build
PACKAGES=(
    build-essential
    libncurses5-dev
    gawk
    flex
    bison
    diffutils
    zip
    unzip
    make
    gcc
    git
    subversion
    wget
    curl
    libssl-dev
    rsync
    patch
    perl
    python3
    python3-pip
    libelf-dev
    libffi-dev
    uuid-dev
    pkg-config
    cmake
    autoconf
    automake
    libtool
    texinfo
    gettext
    help2man
    xz-utils
)

echo "Installing required packages..."
sudo apt-get install -y "${PACKAGES[@]}"

echo ""
echo "=========================================="
echo "✅ Environment setup complete!"
echo "=========================================="
echo ""
echo "You can now run the build script:"
echo "  ./run_build.sh"
echo "  OR"
echo "  ./build_ddwrt.sh"
echo ""
