#!/bin/bash
###############################################################################
# DD-WRT Automated Local Build Script for Raisecom MSG1500 / R6220
# Author: hassan4mz
# Repository: https://github.com/hassan4mz/dd-wrt0
###############################################################################

set -e # Exit on error

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/dd-wrt-build"
SRC_DIR="$BUILD_DIR/src"
OUTPUT_DIR="$SCRIPT_DIR/output"
LOG_FILE="$SCRIPT_DIR/build_$(date +%Y%m%d_%H%M%S).log"

# DD-WRT Source Configuration
DD_WRT_REPO="svn://svn.dd-wrt.com/DD-WRT"
DD_WRT_BRANCH="tags/ftp/pre-SP2" # Stable pre-SP2 tag, change if needed
# Alternative: "branches/brainslayer_v3" for newer builds

# Device Target (MediaTek MT7621 is common for these devices)
# You may need to adjust this based on specific hardware specs
TARGET_BOARD="ramips"
TARGET_PROFILE="mt7621"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Functions ---

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS:${NC} $1" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

check_dependencies() {
    log "Checking system dependencies..."
    local deps=(
        "build-essential" "libncurses5-dev" "gawk" "flex" "bison" "diffutils"
        "zip" "unzip" "make" "gcc" "git" "subversion" "wget" "curl"
        "libssl-dev" "rsync" "patch" "perl" "python3" "python3-pip"
    )
    
    local missing=()
    for dep in "${deps[@]}"; do
        if ! dpkg -l | grep -q "^ii  $dep "; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        warn "Missing dependencies: ${missing[*]}"
        log "Attempting to install missing dependencies (requires sudo)..."
        sudo apt-get update
        sudo apt-get install -y "${missing[@]}" || error "Failed to install dependencies."
        success "Dependencies installed."
    else
        success "All dependencies are met."
    fi
}

setup_directories() {
    log "Setting up directory structure..."
    mkdir -p "$BUILD_DIR"
    mkdir -p "$SRC_DIR"
    mkdir -p "$OUTPUT_DIR"
    success "Directories created."
}

download_source() {
    if [ -d "$SRC_DIR/.svn" ]; then
        log "Source directory exists. Updating..."
        cd "$SRC_DIR"
        svn update || warn "SVN update failed, will try clean checkout if critical."
        cd "$SCRIPT_DIR"
    else
        log "Downloading DD-WRT source from $DD_WRT_REPO ($DD_WRT_BRANCH)..."
        # Clean previous partial downloads
        rm -rf "$SRC_DIR"
        mkdir -p "$SRC_DIR"
        
        # Checkout only the necessary parts to save time/space
        # Full checkout is huge (~2GB+), we try to be selective but DD-WRT build often needs full tree
        warn "Full DD-WRT source checkout can take 30-60 minutes depending on connection."
        svn checkout "$DD_WRT_REPO/$DD_WRT_BRANCH" "$SRC_DIR" || error "Failed to download DD-WRT source."
    fi
    success "Source code ready."
}

apply_patches() {
    log "Checking for device-specific patches..."
    if [ -d "$SCRIPT_DIR/patches" ] && [ "$(ls -A $SCRIPT_DIR/patches 2>/dev/null)" ]; then
        for patch_file in "$SCRIPT_DIR/patches"/*.patch; do
            if [ -f "$patch_file" ]; then
                log "Applying patch: $(basename "$patch_file")"
                # Try to apply patch, ignore if already applied or fails gracefully
                (cd "$SRC_DIR" && patch -p1 < "$patch_file" --forward --reject-file=-.rej) || warn "Patch $(basename "$patch_file") failed or was already applied."
            fi
        done
        success "Patches processed."
    else
        log "No patches found in ./patches directory. Skipping."
    fi
}

configure_build() {
    log "Configuring build for $TARGET_BOARD/$TARGET_PROFILE..."
    cd "$SRC_DIR/src"
    
    # Create .config based on generic template for the target
    # Note: Specific device configs are usually in src/router/workdir/
    # We will try to enable the generic ramips/mt7621 config
    
    if [ -f "router/configs/config.$TARGET_BOARD.$TARGET_PROFILE" ]; then
        cp "router/configs/config.$TARGET_BOARD.$TARGET_PROFILE" ".config"
        log "Loaded base config for $TARGET_BOARD.$TARGET_PROFILE"
    else
        warn "Specific config not found. Starting with minimal config."
        # Fallback: make menuconfig (non-interactive would fail, so we create a dummy one)
        # In a real scenario, you'd want a saved .config file in the repo
        echo "# Minimal config for $TARGET_BOARD" > ".config"
        echo "CONFIG_$TARGET_BOARD=y" >> ".config"
    fi

    # Enable specific features if needed via sed on .config
    # Example: echo "CONFIG_USB=y" >> ".config"
    
    success "Build configuration prepared."
    cd "$SCRIPT_DIR"
}

compile_firmware() {
    log "Starting compilation process... This may take 1-4 hours."
    cd "$SRC_DIR/src"
    
    # Clean previous builds
    make clean || true
    
    # Start the build
    # DD-WRT usually uses 'make' in the src directory
    # The exact target might vary, often just 'make' or 'make world'
    
    if timeout 4h make -j$(nproc); then
        success "Compilation completed successfully!"
    else
        if [ $? -eq 124 ]; then
            error "Compilation timed out after 4 hours."
        else
            error "Compilation failed. Check $LOG_FILE and src/build_log.txt for details."
        fi
    fi
    
    cd "$SCRIPT_DIR"
}

collect_artifacts() {
    log "Collecting compiled firmware..."
    local found=0
    
    # DD-WRT output locations vary by version/target
    # Common locations:
    # src/router/workdir/<board>/firmware.bin
    # src/release/bin/<board>/
    
    search_dirs=(
        "$SRC_DIR/src/router/workdir"
        "$SRC_DIR/src/release/bin"
        "$SRC_DIR/src/bin"
    )
    
    for dir in "${search_dirs[@]}"; do
        if [ -d "$dir" ]; then
            log "Scanning $dir for firmware..."
            find "$dir" -type f \( -name "*.bin" -o -name "*.trx" -o -name "*.img" \) | while read -r file; do
                cp "$file" "$OUTPUT_DIR/"
                log "Copied $(basename "$file") to $OUTPUT_DIR"
                found=1
            done
        fi
    done

    if [ "$(ls -A $OUTPUT_DIR 2>/dev/null)" ]; then
        success "Firmware artifacts saved to $OUTPUT_DIR"
        ls -lh "$OUTPUT_DIR"
    else
        warn "No firmware files found in expected locations. Check build logs."
    fi
}

cleanup() {
    log "Cleaning up temporary files..."
    # Optional: Remove source to save space (comment out if you want to keep src for incremental builds)
    # rm -rf "$SRC_DIR"
    success "Cleanup complete."
}

main() {
    echo "========================================"
    echo "DD-WRT Automated Build Script"
    echo "Target: Raisecom MSG1500 / R6220 (Generic MT7621)"
    echo "========================================"
    
    check_dependencies
    setup_directories
    download_source
    apply_patches
    configure_build
    compile_firmware
    collect_artifacts
    cleanup
    
    echo "========================================"
    success "Build process finished!"
    echo "Output directory: $OUTPUT_DIR"
    echo "Log file: $LOG_FILE"
    echo "========================================"
}

# Run main function
main "$@"
