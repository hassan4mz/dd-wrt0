# Serial Console Guide for MT7621 Devices

## Required Hardware

### USB-to-TTL Serial Adapter
Popular options:
- **FTDI FT232RL** (Recommended, reliable)
- **CP2102** (Common, affordable)
- **CH340/CH341** (Budget option)
- **PL2303** (Older, may have driver issues)

**Important**: Ensure your adapter supports 3.3V logic level!

### Additional Items
- Jumper wires (female-to-female or female-to-male)
- Multimeter (for verifying pins)
- Optional: Pin header soldering kit

## Finding Serial Pins on MSG1500/R6220

### Visual Inspection
1. Open the device case
2. Look for unpopulated pin headers
3. Common locations:
   - Near the CPU
   - Along the edge of the board
   - Near reset button

### Typical Pin Labels
Look for silkscreen labels:
- `TX` or `TXD` (Transmit)
- `RX` or `RXD` (Receive)  
- `GND` or `Ground`
- `VCC` or `3.3V` or `5V`

### If No Labels
Use a multimeter to identify pins:
1. Set to DC voltage mode
2. Black probe on metal shield (ground)
3. Red probe on each pin
4. Power on device
5. Pin showing ~3.3V is VCC
6. Pin showing 0V is GND
7. TX and RX need further testing

## Wiring Diagram

```
Device (MSG1500/R6220)     USB-to-TTL Adapter
----------------------     ------------------
     GND  ───────────────►  GND
     TX   ───────────────►  RX
     RX   ───────────────►  TX
     VCC  ────┬───X DO NOT CONNECT!
              │
         (Leave disconnected)
```

**CRITICAL**: Never connect VCC from adapter to device!
- Device has its own power supply
- Connecting both can damage the device or your computer

## Connection Steps

### Step 1: Prepare Adapter
1. Set voltage jumper to 3.3V (if adjustable)
2. Install necessary drivers for your adapter
3. Test adapter by shorting TX-RX (loopback test)

### Step 2: Connect Wires
1. **Power OFF** the device
2. Connect GND first
3. Connect TX to RX
4. Connect RX to TX
5. Double-check connections
6. Do NOT connect VCC

### Step 3: Verify Connections
```
Checklist:
□ GND connected to GND
□ Device TX connected to Adapter RX
□ Device RX connected to Adapter TX
□ VCC NOT connected
□ All connections secure
```

## Software Setup

### Windows
1. Install adapter drivers (from manufacturer website)
2. Open Device Manager → find COM port number
3. Download PuTTY or Tera Term
4. Configure serial connection:
   - Serial line: COMx (your port number)
   - Speed: 115200
   - Data bits: 8
   - Stop bits: 1
   - Parity: None
   - Flow control: None

### Linux
1. Install screen or minicom:
   ```bash
   sudo apt-get install screen minicom
   ```
2. Find your device:
   ```bash
   ls -la /dev/ttyUSB*  # For FTDI, CP2102
   ls -la /dev/ttyACM*  # For Arduino-style
   ```
3. Add user to dialout group:
   ```bash
   sudo usermod -a -G dialout $USER
   ```
4. Connect with screen:
   ```bash
   screen /dev/ttyUSB0 115200
   ```
5. Disconnect: Press `Ctrl+A`, then `K`, then `Y`

### macOS
1. Install screen (pre-installed)
2. Find your device:
   ```bash
   ls -la /dev/tty.usbserial*
   ls -la /dev/tty.usbmodem*
   ```
3. Connect:
   ```bash
   screen /dev/tty.usbserial 115200
   ```
4. Disconnect: Press `Ctrl+A`, then type `:quit`

## Common Baud Rates

Try these if you don't see output:
- **115200** (most common for MT7621)
- 57600
- 38400
- 19200
- 9600

## Expected Output

When powering on, you should see:

```
U-Boot 1.1.3 (Oct 15 2020 - 12:34:56)

Board: Ralink APSoC DRAM:  128 MB
relocate_code Pointer at: 87fb0000

Config XHCI 40MHz PLL
SSC disabled.
flash manufacture id: c2, device id 20 18
find flash: MX25L12805D
raspi_read: from:40000 len:1000
*** Warning - bad CRC, using default environment

...

Starting kernel ...

Linux version 4.x.x (...) 
...
```

## Troubleshooting

### No Output
1. Check wiring (TX/RX swapped?)
2. Try different baud rates
3. Verify GND connection
4. Check if device is powered
5. Try different serial adapter

### Garbage Characters
1. Wrong baud rate - try others
2. Loose connections
3. Voltage mismatch (3.3V vs 5V)
4. Electrical interference

### Can't Type Commands
1. TX/RX might be swapped
2. Flow control enabled (disable it)
3. Wrong terminal program settings

### Access Denied (Linux)
```bash
sudo chmod 666 /dev/ttyUSB0
# Or permanently:
sudo usermod -a -G dialout $USER
# Then logout and login again
```

## Using the Console

### Interrupt Boot Process
Press any key when prompted during boot to enter U-Boot menu.

### Common U-Boot Commands
```
printenv          # Show environment variables
setenv name val   # Set environment variable
saveenv           # Save environment
reset             # Reset device
tftpboot          # Load via TFTP
```

### Linux Shell Access
After boot completes, you may get a shell prompt:
- Default credentials vary (try root/admin)
- May require password from device label

## Safety Tips

1. **ESD Protection**: Ground yourself before touching electronics
2. **No Hot Plugging**: Connect/disconnect only when powered off
3. **Double-Check Voltage**: Verify 3.3V before connecting
4. **Secure Connections**: Ensure wires don't short adjacent pins
5. **Patience**: Take time to verify everything before powering on

## Next Steps

Once connected:
1. Backup original firmware
2. Document your hardware revision
3. Proceed with installation (see INSTALL.md)

## Resources

- [DD-WRT Forum Serial Guide](https://forum.dd-wrt.com/phpBB2/viewtopic.php?t=51423)
- [OpenWRT Serial Console](https://openwrt.org/docs/guide-user/troubleshooting/serial_console)
- [MT7621 Datasheet](https://wikidevi.com/wiki/MediaTek_MT7621)
