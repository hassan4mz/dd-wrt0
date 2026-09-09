# DD-WRT Build Project for Raisecom MSG1500 / R6220

This repository contains automated build configurations for compiling DD-WRT firmware for Raisecom MSG1500 and compatible devices (R6220).

## Device Information

- **Raisecom MSG1500**: MediaTek MT7621-based GPON ONU/Router
- **R6220**: Similar MediaTek-based device
- **Architecture**: MIPS (MT7621)
- **Flash**: Typically 16MB
- **RAM**: 128MB or 256MB

## ⚠️ Important Warnings

1. **Brick Risk**: Flashing custom firmware may brick your device
2. **No Official Support**: These devices are NOT officially supported by DD-WRT
3. **Research First**: Verify your exact hardware revision before attempting to flash
4. **Backup**: Always backup original firmware before flashing
5. **Serial Access**: Have serial console access ready for recovery

## Repository Structure

```
├── .github/workflows/    # GitHub Actions CI/CD
├── configs/              # Device-specific configurations
├── scripts/              # Build helper scripts
├── patches/              # Device-specific patches
└── docs/                 # Documentation and guides
```

## Automated Build

This repository uses GitHub Actions to automatically:
- Fetch DD-WRT source code
- Apply device-specific patches
- Compile firmware images
- Upload build artifacts

## Getting Started

### Prerequisites

- GitHub account (for using Actions)
- Serial cable for device recovery (highly recommended)
- TFTP server for initial flash

### Using Pre-built Firmware

1. Go to the **Actions** tab
2. Select the latest successful build
3. Download the firmware artifact
4. Follow installation instructions in `docs/INSTALL.md`

### Building Locally

```bash
# Clone the repository
git clone <this-repo>
cd <repo-name>

# Run the build script
./scripts/build.sh
```

## Device Compatibility

| Device | Status | Notes |
|--------|--------|-------|
| Raisecom MSG1500 | 🟡 Experimental | Requires verification |
| Raisecom R6220 | 🟡 Experimental | Similar hardware |
| Other MT7621 devices | 🔴 Not tested | May require modifications |

## Resources

- [DD-WRT Official Site](https://dd-wrt.com/)
- [DD-WRT Forum](https://forum.dd-wrt.com/)
- [OpenWRT MT7621 Info](https://openwrt.org/toh/mediatek/mt7621)
- [Serial Recovery Guide](docs/SERIAL.md)

## Contributing

Contributions welcome! Please:
1. Test on your hardware
2. Document your changes
3. Submit pull requests with testing results

## License

DD-WRT is licensed under GPL v2. This build configuration is provided as-is.

## Disclaimer

This project is for educational purposes. Use at your own risk. The authors are not responsible for any damage to your hardware.
