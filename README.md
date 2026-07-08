# 🔥 Android Hotspot Auto-Off Fix

> **Fix for Android hotspot automatically turning off at night or during idle/sleep mode.**

![Platform](https://img.shields.io/badge/Platform-Android-green?logo=android)
![Tool](https://img.shields.io/badge/Tool-ADB-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)

## 📋 Problem

Many Android users face this frustrating issue:

- 📱 Mobile hotspot **automatically turns off** at night (usually around 1-2 AM)
- 🔌 Devices connected via hotspot (laptop, tablet) **lose internet**
- 🔁 Hotspot needs to be **manually re-enabled** every time

**Affected devices:** Motorola, Samsung, Xiaomi, Realme, OnePlus, and most Android phones.

## 🔍 Root Cause

After deep debugging using **ADB (Android Debug Bridge)**, two root causes were identified:

### 1. `wifi_sleep_policy` set to `2`

Android has a hidden setting called `wifi_sleep_policy`:

| Value | Behavior |
|-------|----------|
| `0`   | Wi-Fi **always stays ON** (even during sleep) ✅ |
| `1`   | Wi-Fi stays ON **only when charging** |
| `2`   | Wi-Fi **turns OFF during sleep** ❌ |

When set to `2`, Android kills the Wi-Fi/hotspot when the phone enters sleep mode (screen off + idle).

### 2. Android Doze Mode kills the Tethering Service

Android's **Doze Mode** is a battery optimization feature that activates when the phone is idle for a long time (e.g., at night). It:

- Restricts background apps and services
- Cuts network connections
- Disables the **tethering service** (`com.google.android.networkstack.tethering`)

This causes the hotspot to silently disconnect.

### 3. Hidden System Auto-Timeout (Even if UI says "Never")

Some OEMs (like Motorola) have a UI bug where the Hotspot settings show "Turn off hotspot automatically" as disabled, but the core Android system still enforces a default inactivity timeout. We bypass this by explicitly setting `soft_ap_timeout_enabled` and `hotspot_turn_off_timer` to `0`.

### 4. Moto Smart 5G / Aggressive Network Optimizers

Certain devices (like Motorola) use background services (e.g., `com.motorola.smart5g`) that actively monitor the network. When the screen turns off, this service forces a drop from 5G to 4G to save battery, which interrupts the tethering interface and kills the hotspot. We fix this by disabling the aggressive optimizer package.

### 5. 5GHz DFS (Dynamic Frequency Selection) Drops

If your hotspot is set to 5GHz, Android may suddenly drop the connection or shut down the AP to avoid interfering with radar signals (DFS regulations). Switching the AP band to 2.4GHz prevents these random drops.

## 🔧 Fix

### Prerequisites

- A computer with **ADB installed**
- USB cable to connect your phone
- **USB Debugging** enabled on your phone

> **How to enable USB Debugging:**
> `Settings → About Phone → Tap "Build Number" 7 times → Settings → System → Developer Options → USB Debugging → ON`

### Quick Fix (6 Commands)

Connect your phone via USB and run:

```bash
# Fix 1: Keep Wi-Fi/Hotspot alive during sleep
adb shell settings put global wifi_sleep_policy 0

# Fix 2: Whitelist tethering from Doze mode
adb shell dumpsys deviceidle whitelist +com.google.android.networkstack.tethering

# Fix 3: Disable Android default soft AP timeout
adb shell settings put global soft_ap_timeout_enabled 0

# Fix 4: Disable OEM specific (e.g., Motorola) hotspot turn off timer
adb shell settings put system hotspot_turn_off_timer 0

# Fix 5: Disable aggressive Moto Smart 5G battery saver that drops tethering
adb shell pm disable-user --user 0 com.motorola.smart5g

# Fix 6: Disable background Wi-Fi scanning
adb shell settings put global wifi_scan_always_enabled 0
```

### Or Use the Script

```bash
# Linux/macOS
chmod +x fix.sh
./fix.sh

# Windows (PowerShell)
.\fix.ps1
```

### Verify the Fix

```bash
# Should return 0
adb shell settings get global wifi_sleep_policy

# Should show tethering in whitelist
adb shell dumpsys deviceidle whitelist | grep tethering
```

## 🔎 How I Debugged This

### Step 1: Check hotspot-related settings
```bash
adb shell settings list global | grep hotspot
adb shell settings list global | grep tether
adb shell settings list global | grep wifi_sleep
```

### Step 2: Analyze Wi-Fi logs for hotspot on/off history
```bash
adb shell dumpsys wifi | grep -i "tether"
```

This revealed the hotspot was being re-enabled multiple times a day — confirming it was turning off unexpectedly.

### Step 3: Check Doze mode behavior
```bash
adb shell dumpsys deviceidle
```

This showed the phone entering `deep-idle` state at night, which restricts background services.

### Step 4: Check battery and power settings
```bash
adb shell dumpsys battery
adb shell settings list global | grep low_power
```

Confirmed battery saver was OFF — so the issue was specifically `wifi_sleep_policy` + Doze mode.

## 📱 Additional Manual Fixes

On your phone, ensure the following settings are configured:

1. **Disable Hotspot Timeout:**
```
Settings → Network & Internet → Hotspot & Tethering → Wi-Fi Hotspot
→ ⚙️ (Settings) → "Turn off hotspot automatically" → OFF
```

2. **Switch to 2.4GHz Band (Crucial for Stability):**
```
Settings → Network & Internet → Hotspot & Tethering → Wi-Fi Hotspot
→ AP Band → Select "2.4 GHz"
(Or enable "Extend Compatibility" if 2.4GHz isn't explicitly listed)
```

3. **Disable Aggressive Battery Optimization:**
```
Settings → Battery → Adaptive Battery → OFF (optional)
```

## 🧪 Tested On

| Device | Android Version | Status |
|--------|----------------|--------|
| Motorola Edge 50 Neo | Android 14 | ✅ Fixed |

> **Note:** This fix should work on most Android devices running Android 10+. If you've tested on your device, please open a PR to add it to this table!

## 🤔 FAQ

**Q: Will this drain my battery?**
A: Slightly more than before, since Wi-Fi stays active during sleep. But the difference is minimal.

**Q: Do I need to run this again after a phone restart?**
A: The `wifi_sleep_policy` change is persistent (survives reboots). The Doze whitelist should also persist, but verify after reboot.

**Q: Will this affect my phone's performance?**
A: No. It only changes how Android handles Wi-Fi during sleep mode.

**Q: I don't have a computer. Can I fix this on my phone?**
A: You can try using a terminal emulator app like **Termux**, but some commands may require root access.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⭐ Support

If this helped you, please **star ⭐ this repo** and share it with others facing the same issue!

## 🤝 Contributing

Found this fix works on your device? Open a **Pull Request** to add your device to the tested devices table!
