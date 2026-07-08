#!/bin/bash

# ============================================
# Android Hotspot Auto-Off Fix Script
# ============================================
# Fixes the issue where Android hotspot
# automatically turns off during sleep/idle
# ============================================

echo "🔧 Android Hotspot Auto-Off Fix"
echo "================================"
echo ""

# Check if ADB is installed
if ! command -v adb &> /dev/null; then
    echo "❌ ADB is not installed!"
    echo "Install it with: sudo apt install adb"
    exit 1
fi

# Check if device is connected
DEVICE=$(adb devices | grep -w "device" | head -1)
if [ -z "$DEVICE" ]; then
    echo "❌ No Android device found!"
    echo ""
    echo "Make sure:"
    echo "  1. Phone is connected via USB"
    echo "  2. USB Debugging is enabled"
    echo "  3. You've allowed USB debugging on phone"
    exit 1
fi

echo "✅ Device found: $(echo $DEVICE | awk '{print $1}')"
echo ""

# Check current wifi_sleep_policy
CURRENT_POLICY=$(adb shell settings get global wifi_sleep_policy)
echo "📋 Current wifi_sleep_policy: $CURRENT_POLICY"

if [ "$CURRENT_POLICY" = "2" ]; then
    echo "   ⚠️  Value is 2 (Wi-Fi turns OFF during sleep) — THIS IS THE PROBLEM!"
elif [ "$CURRENT_POLICY" = "1" ]; then
    echo "   ⚠️  Value is 1 (Wi-Fi stays ON only when charging)"
elif [ "$CURRENT_POLICY" = "0" ]; then
    echo "   ✅ Value is already 0 (Wi-Fi always stays ON)"
fi

echo ""

# Apply Fix 1: Set wifi_sleep_policy to 0
echo "🔧 Fix 1: Setting wifi_sleep_policy to 0..."
adb shell settings put global wifi_sleep_policy 0
NEW_POLICY=$(adb shell settings get global wifi_sleep_policy)

if [ "$NEW_POLICY" = "0" ]; then
    echo "   ✅ wifi_sleep_policy set to 0 successfully!"
else
    echo "   ❌ Failed to set wifi_sleep_policy"
fi

echo ""

# Apply Fix 2: Whitelist tethering from Doze mode
echo "🔧 Fix 2: Whitelisting tethering from Doze mode..."
RESULT=$(adb shell dumpsys deviceidle whitelist +com.google.android.networkstack.tethering)
echo "   $RESULT"

echo ""

# Apply Fix 3: Disable Android default soft AP timeout
echo "🔧 Fix 3: Disabling default soft AP timeout..."
adb shell settings put global soft_ap_timeout_enabled 0
echo "   ✅ Done"

echo ""

# Apply Fix 4: Disable OEM specific hotspot turn off timer
echo "🔧 Fix 4: Disabling OEM hotspot turn off timer..."
adb shell settings put system hotspot_turn_off_timer 0
echo "   ✅ Done"

echo ""

# Verify
echo "✅ Verification:"
echo "   wifi_sleep_policy = $(adb shell settings get global wifi_sleep_policy)"

WHITELIST_CHECK=$(adb shell dumpsys deviceidle whitelist | grep tethering)
if [ -n "$WHITELIST_CHECK" ]; then
    echo "   Tethering whitelisted = ✅ Yes"
else
    echo "   Tethering whitelisted = ❌ No (may need root)"
fi

echo ""
echo "================================"
echo "🎉 Fix applied! Test tonight — hotspot should stay ON."
echo "================================"
