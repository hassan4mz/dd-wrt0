# Device Patches Directory

This directory contains device-specific patches for DD-WRT.

## Current Status

**No patches included yet** - These devices (MSG1500, R6220) require hardware verification before patches can be created.

## What Patches Might Be Needed

### 1. Board Detection Patch
- Add device detection for MSG1500/R6220
- Configure GPIO pins for LEDs and buttons
- Set up reset button functionality

### 2. Network Configuration
- Switch port mapping (MT7530 switch)
- VLAN configuration
- WAN/LAN port assignment

### 3. Wireless Drivers
- MT7621 built-in 2.4GHz radio
- External 5GHz chip (if present, e.g., MT7603, MT7613)
- EEPROM calibration data extraction

### 4. Flash Layout
- Partition map for specific flash chip
- Bootloader protection
- NVRAM size configuration

### 5. USB Support (if applicable)
- USB port enablement
- Power control GPIO

## How to Create Patches

### Step 1: Gather Information
```bash
# From original firmware or via serial
cat /proc/cpuinfo
cat /proc/mtd
dmesg
lsusb
lspci
```

### Step 2: Identify Hardware
- CPU: MediaTek MT7621AT/NN
- Switch: MediaTek MT7530
- WiFi: MT7621 (2.4GHz) + ? (5GHz)
- Flash: Check chip marking (e.g., MX25L12805D = 16MB)
- RAM: 128MB or 256MB

### Step 3: Create Patch Format
Patches should be in unified diff format:
```diff
--- a/src/router/somefile.c
+++ b/src/router/somefile.c
@@ -100,7 +100,7 @@
-#define OLD_VALUE 0
+#define NEW_VALUE 1
```

### Step 4: Test Incrementally
- Apply one patch at a time
- Test build after each patch
- Document what each patch does

## Contributing Patches

If you have successfully created patches:

1. **Test thoroughly** on your hardware
2. **Document** what the patch does
3. **Include** before/after behavior
4. **Submit** via pull request with:
   - Hardware revision details
   - Testing results
   - Any known issues

## Template Patch File

```diff
--- /dev/null
+++ b/patches/msg1500_example.patch
@@ -0,0 +1,20 @@
+--- a/src/router/rc/common.c
++++ b/src/router/rc/common.c
+@@ -123,6 +123,12 @@
+     // Existing code
+ }
+ 
++// Raisecom MSG1500 support
++#ifdef CONFIG_MACH_MSG1500
++    msg1500_init();
++#endif
++
+ int main(int argc, char *argv[]) {
+     // Main function
+ }
```

## Resources

- [DD-WRT Patch Guidelines](https://dd-wrt.com/support/patch-submission/)
- [Linux Kernel Patch Format](https://www.kernel.org/doc/html/latest/process/submitting-patches.html)
- [MT7621 OpenWRT Port](https://openwrt.org/toh/mediatek/mt7621)

## Disclaimer

⚠️ **WARNING**: Incorrect patches can cause:
- Build failures
- Boot loops
- Permanent device damage (if flashed)

Always test in emulation or with serial recovery access before flashing.
