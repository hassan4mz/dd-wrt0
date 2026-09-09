# Installation Guide for DD-WRT on Raisecom MSG1500/R6220

## ⚠️ CRITICAL WARNINGS

**READ THIS BEFORE PROCEEDING:**

1. **BRICK RISK**: Flashing custom firmware can permanently damage your device
2. **NO OFFICIAL SUPPORT**: These devices are NOT officially supported by DD-WRT
3. **SERIAL ACCESS REQUIRED**: You MUST have a serial console cable before attempting to flash
4. **BACKUP FIRST**: Always backup your original firmware
5. **PROCEED AT YOUR OWN RISK**: The authors are not responsible for any damage

## Prerequisites

### Hardware Required
- Serial USB-to-TTL adapter (3.3V or 5V depending on device)
- Computer with Ethernet port
- Network cable
- TFTP server software (optional but recommended)

### Software Required
- TFTP client/server
- Terminal emulator (PuTTY, screen, minicom)
- Original firmware backup

## Step 1: Identify Your Hardware

### Open the Device
1. Power off the device
2. Open the case carefully
3. Look for the following:
   - CPU model (should be MediaTek MT7621)
   - Flash chip size (typically 16MB)
   - RAM size (128MB or 256MB)
   - Serial console pins (TX, RX, GND, VCC)

### Find Serial Pins
Common pinout for MT7621 devices:
```
Pin Layout (check your specific board):
[VCC] [TX] [RX] [GND]
  |     |     |     |
  3.3V  Out   In   Ground
```

**DO NOT CONNECT VCC** - Only connect TX, RX, and GND

## Step 2: Connect Serial Console

### Connection Steps
1. Set your USB-to-TTL adapter to 3.3V (or 5V if required)
2. Connect:
   - Adapter GND → Device GND
   - Adapter TX → Device RX
   - Adapter RX → Device TX
3. Do NOT connect VCC
4. Power on the device

### Terminal Settings
- Baud rate: 115200 (most common) or 57600
- Data bits: 8
- Parity: None
- Stop bits: 1
- Flow control: None

### Verify Connection
You should see boot messages when powering on the device.

## Step 3: Backup Original Firmware

### Method 1: From Running System
If you can access the device's admin interface:
1. Login to the web interface
2. Look for backup/restore options
3. Save the current firmware

### Method 2: Via Serial Console
```bash
# Access shell via serial (may require password)
# Dump flash to file
cat /dev/mtd0 > /tmp/original_firmware.bin
# Transfer via TFTP or serial
```

### Method 3: Hardware Flasher
For advanced users with SPI flash programmer.

## Step 4: Prepare Firmware

### Download Firmware
1. Go to GitHub Actions in this repository
2. Download the latest build artifact
3. Extract the .bin file

### Verify Firmware
```bash
# Check file size (should match your flash size)
ls -la firmware.bin

# Verify checksum if provided
md5sum firmware.bin
```

## Step 5: Flash Firmware

### Method 1: Web Interface (If Available)
1. Login to device web interface
2. Navigate to Administration → Firmware Upgrade
3. Select the DD-WRT firmware file
4. Click Upgrade and wait (DO NOT POWER OFF)
5. Wait 5-10 minutes for reboot

### Method 2: TFTP Recovery Mode
1. Set your computer IP to 192.168.1.10
2. Rename firmware to appropriate name (check device docs)
3. Start TFTP server with firmware file
4. Power on device while holding reset button
5. Device will automatically download firmware

### Method 3: Serial Console Flash
```bash
# Upload firmware via serial (slow)
# Or use tftp from device shell
tftp -g -r firmware.bin 192.168.1.10

# Write to flash (CAUTION: Wrong command can brick device)
mtd write firmware.bin firmware

# Reboot
reboot
```

## Step 6: First Boot

1. Wait 5-10 minutes for first boot
2. DD-WRT default IP: 192.168.1.1
3. Default credentials:
   - Username: root
   - Password: admin (or check release notes)

4. Reset to factory defaults:
   - Hold reset button for 30 seconds
   - Release and wait for reboot

## Troubleshooting

### Device Won't Boot
1. Check serial console for error messages
2. Try TFTP recovery mode
3. Restore original firmware backup

### Can't Access Web Interface
1. Check IP address (try 192.168.1.1)
2. Try different browser
3. Clear browser cache
4. Factory reset (30-30-30 method)

### Serial Console Shows Garbage
1. Verify baud rate (try 57600, 115200, 9600)
2. Check wiring connections
3. Verify voltage level (3.3V vs 5V)

### WiFi Not Working
1. This is expected for initial builds
2. WiFi drivers need device-specific configuration
3. Check forum for updates

## Post-Installation

### Recommended Settings
1. Change default password immediately
2. Configure wireless settings
3. Update DNS servers
4. Enable firewall
5. Disable unused services

### Monitoring
- Monitor device temperature initially
- Check system logs regularly
- Verify stability before production use

## Resources

- [DD-WRT Forum](https://forum.dd-wrt.com/)
- [MT7621 Documentation](https://openwrt.org/toh/mediatek/mt7621)
- [Serial Guide](SERIAL.md)

## Getting Help

Before asking for help:
1. Document your exact hardware revision
2. Note what steps you've tried
3. Provide serial console output if available
4. Include build information from firmware

**Remember: These are experimental builds. Patience and careful testing are essential.**
