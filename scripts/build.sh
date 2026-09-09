#!/bin/bash
# DD-WRT Build Script for MT7621 devices (MSG1500, R6220)
# Usage: ./build.sh [device] [config_type]

set -e

DEVICE=${1:-msg1500}
CONFIG_TYPE=${2:-standard}
BUILD_DIR="$(pwd)/build"
DDWRT_REPO="https://svn.dd-wrt.com/Generic/"

echo "=============================================="
echo "DD-WRT Build Script for MT7621 Devices"
echo "=============================================="
echo "Device: $DEVICE"
echo "Config Type: $CONFIG_TYPE"
echo "Build Directory: $BUILD_DIR"
echo "=============================================="

check_dependencies() {
    echo "[*] Checking build dependencies..."
    DEPS="build-essential bison flex gawk libssl-dev zlib1g-dev subversion wget patch"
    for dep in $DEPS; do
        if ! dpkg -l | grep -q "^ii  $dep"; then
            echo "[!] Missing: $dep - installing..."
            sudo apt-get update && sudo apt-get install -y $dep
        fi
    done
    echo "[OK] Dependencies checked"
}

setup_environment() {
    echo "[*] Setting up build environment..."
    mkdir -p "$BUILD_DIR"/{src,opt,firmware}
}

download_source() {
    echo "[*] Downloading DD-WRT source from SVN..."
    cd "$BUILD_DIR/src"
    if [ -d ".svn" ]; then
        svn update
    else
        svn co "$DDWRT_REPO" .
    fi
    echo "[OK] Source downloaded"
}

configure_build() {
    echo "[*] Configuring build for $DEVICE..."
    cd "$BUILD_DIR/src/router"
    
    CONFIG_FILE="../../configs/${DEVICE}_config.txt"
    [ ! -f "$CONFIG_FILE" ] && CONFIG_FILE="../../configs/mt7621_config.txt"
    
    if [ -f "$CONFIG_FILE" ]; then
        cp "$CONFIG_FILE" .config
        echo "[OK] Using config: $CONFIG_FILE"
    else
        cat > .config << 'CONF'
CONFIG_MIPS=y
CONFIG_MT7621=y
CONFIG_ROUTER=y
CONF
        echo "[OK] Created minimal config"
    fi
    
    case $CONFIG_TYPE in
        mini) echo "CONFIG_SMALL_FLASH=y" >> .config ;;
        micro) echo -e "CONFIG_MICRO=y\nCONFIG_SMALL_FLASH=y" >> .config ;;
    esac
}

apply_patches() {
    echo "[*] Applying patches..."
    cd "$BUILD_DIR/src"
    PATCH_DIR="../../patches"
    
    if [ -d "$PATCH_DIR" ]; then
        for patch in "$PATCH_DIR"/*.patch 2>/dev/null; do
            [ -f "$patch" ] || continue
            echo "  Applying: $(basename $patch)"
            patch -p1 < "$patch" || echo "[WARN] Patch failed: $patch"
        done
    fi
    echo "[OK] Patches processed"
}

build_firmware() {
    echo "[*] Starting compilation (this may take hours)..."
    cd "$BUILD_DIR/src/router"
    make clean 2>/dev/null || true
    
    JOBS=$(nproc)
    echo "[*] Using $JOBS parallel jobs"
    
    if make -j$JOBS 2>&1 | tee "$BUILD_DIR/build.log"; then
        echo "[OK] Build successful!"
    else
        echo "[ERROR] Build failed! Check $BUILD_DIR/build.log"
        exit 1
    fi
}

prepare_output() {
    echo "[*] Preparing firmware files..."
    cd "$BUILD_DIR"
    mkdir -p output
    
    find src -name "*.bin" -type f -exec cp {} output/ \; 2>/dev/null || true
    find src -name "*.trx" -type f -exec cp {} output/ \; 2>/dev/null || true
    
    cat > output/BUILD_INFO.txt << INFO
Build Date: $(date -u)
Device: $DEVICE
Config Type: $CONFIG_TYPE
Source: DD-WRT SVN
INFO
    
    echo "[OK] Output files in: $BUILD_DIR/output"
    ls -la output/
}

main() {
    check_dependencies
    setup_environment
    download_source
    configure_build
    apply_patches
    build_firmware
    prepare_output
    
    echo ""
    echo "=============================================="
    echo "Build Complete!"
    echo "=============================================="
    echo "Firmware: $BUILD_DIR/output/"
    echo "Log: $BUILD_DIR/build.log"
    echo ""
    echo "WARNING: Flash at your own risk!"
    echo "=============================================="
}

main
