# Troubleshooting Guide

## 🔧 Common Issues & Solutions

### 1. ADB not detecting phone

**Symptoms:** `adb devices` shows empty list

**Solutions:**
- Ensure USB Debugging is ON: `Settings → System → Developer Options → USB Debugging`
- Try a different USB cable (use the original cable)
- Change USB mode to "File Transfer (MTP)"
- On the phone, tap "Allow" on the USB debugging authorization popup
- Try: `adb kill-server && adb start-server && adb devices`

### 2. Device shows "unauthorized"

**Solutions:**
- Check phone screen for "Allow USB Debugging?" popup
- Tap "Always allow from this computer" checkbox, then tap "Allow"
- If no popup appears:
  - Go to `Developer Options → Revoke USB Debugging Authorizations`
  - Disconnect and reconnect USB cable
  - The popup should appear now

### 3. ADB command "permission denied"

**Solutions:**
- Some commands require root access
- The commands in this fix do NOT require root
- If you get permission denied, ensure you're using the correct ADB version

### 4. Fix doesn't persist after reboot

**Check:**
```bash
adb shell settings get global wifi_sleep_policy
```

If it resets to `2` after reboot:
- Some OEMs reset this setting
- Create a Tasker profile to set it on boot
- Or run the fix script again after each reboot

### 5. Hotspot still turns off after fix

**Additional steps to try:**

1. Disable "Turn off hotspot automatically" in phone settings:
   ```
   Settings → Network & Internet → Hotspot & Tethering
   → Wi-Fi Hotspot → ⚙️ → Turn off hotspot automatically → OFF
   ```

2. Disable Adaptive Battery:
   ```
   Settings → Battery → Adaptive Battery → OFF
   ```

3. Disable Battery Optimization for tethering:
   ```bash
   adb shell cmd appops set com.google.android.networkstack.tethering RUN_IN_BACKGROUND allow
   ```

4. Check if any battery saver schedule is active:
   ```
   Settings → Battery → Battery Saver → Set a Schedule → No Schedule
   ```

### 6. WSL2 can't detect USB device

**Problem:** Running ADB in WSL2 (Windows Subsystem for Linux) — USB devices not visible.

**Solution:** Use ADB from Windows PowerShell/CMD instead:
1. Download [Platform Tools for Windows](https://developer.android.com/tools/releases/platform-tools)
2. Extract to a folder
3. Open PowerShell, navigate to the folder
4. Run: `.\adb.exe devices`

### 7. Wireless ADB not working

**Requirements:**
- Phone must be connected to a Wi-Fi network (not providing hotspot)
- Both phone and computer must be on the same network
- Wireless Debugging must be enabled in Developer Options

**Steps:**
```bash
# Get pairing info from phone: Developer Options → Wireless Debugging → Pair
adb pair <IP:PORT> <PAIRING_CODE>
adb connect <IP:PORT>
adb devices
```

## 📞 Still having issues?

Open an [Issue](../../issues) on this repository with:
- Your phone model
- Android version
- Output of `adb shell dumpsys wifi | grep -i tether`
- Output of `adb shell settings get global wifi_sleep_policy`
