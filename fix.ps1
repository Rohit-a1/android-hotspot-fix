# ============================================
# Android Hotspot Auto-Off Fix Script
# PowerShell Version (Windows)
# ============================================

Write-Host "🔧 Android Hotspot Auto-Off Fix" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if ADB is available
$adbPath = $null
if (Get-Command "adb" -ErrorAction SilentlyContinue) {
    $adbPath = "adb"
} elseif (Test-Path ".\adb.exe") {
    $adbPath = ".\adb.exe"
} else {
    Write-Host "❌ ADB is not found!" -ForegroundColor Red
    Write-Host "Download from: https://developer.android.com/tools/releases/platform-tools"
    exit 1
}

# Check if device is connected
$devices = & $adbPath devices | Select-String "device$"
if (-not $devices) {
    Write-Host "❌ No Android device found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Make sure:"
    Write-Host "  1. Phone is connected via USB"
    Write-Host "  2. USB Debugging is enabled"
    Write-Host "  3. You've allowed USB debugging on phone"
    exit 1
}

$deviceId = ($devices -split "\s+")[0]
Write-Host "✅ Device found: $deviceId" -ForegroundColor Green
Write-Host ""

# Check current wifi_sleep_policy
$currentPolicy = & $adbPath shell settings get global wifi_sleep_policy
$currentPolicy = $currentPolicy.Trim()
Write-Host "📋 Current wifi_sleep_policy: $currentPolicy"

switch ($currentPolicy) {
    "2" { Write-Host "   ⚠️  Wi-Fi turns OFF during sleep — THIS IS THE PROBLEM!" -ForegroundColor Yellow }
    "1" { Write-Host "   ⚠️  Wi-Fi stays ON only when charging" -ForegroundColor Yellow }
    "0" { Write-Host "   ✅ Already set to 0 (Wi-Fi always stays ON)" -ForegroundColor Green }
}

Write-Host ""

# Apply Fix 1
Write-Host "🔧 Fix 1: Setting wifi_sleep_policy to 0..." -ForegroundColor Cyan
& $adbPath shell settings put global wifi_sleep_policy 0
$newPolicy = (& $adbPath shell settings get global wifi_sleep_policy).Trim()

if ($newPolicy -eq "0") {
    Write-Host "   ✅ wifi_sleep_policy set to 0 successfully!" -ForegroundColor Green
} else {
    Write-Host "   ❌ Failed to set wifi_sleep_policy" -ForegroundColor Red
}

Write-Host ""

# Apply Fix 2
Write-Host "🔧 Fix 2: Whitelisting tethering from Doze mode..." -ForegroundColor Cyan
$result = & $adbPath shell dumpsys deviceidle whitelist +com.google.android.networkstack.tethering
Write-Host "   $result"

Write-Host ""

# Apply Fix 3
Write-Host "🔧 Fix 3: Disabling Android default soft AP timeout..." -ForegroundColor Cyan
& $adbPath shell settings put global soft_ap_timeout_enabled 0
Write-Host "   ✅ Done" -ForegroundColor Green

Write-Host ""

# Apply Fix 4
Write-Host "🔧 Fix 4: Disabling OEM hotspot turn off timer..." -ForegroundColor Cyan
& $adbPath shell settings put system hotspot_turn_off_timer 0
Write-Host "   ✅ Done" -ForegroundColor Green

Write-Host ""

# Verify
Write-Host "✅ Verification:" -ForegroundColor Green
$verifyPolicy = (& $adbPath shell settings get global wifi_sleep_policy).Trim()
Write-Host "   wifi_sleep_policy = $verifyPolicy"

$whitelistCheck = & $adbPath shell dumpsys deviceidle whitelist | Select-String "tethering"
if ($whitelistCheck) {
    Write-Host "   Tethering whitelisted = ✅ Yes" -ForegroundColor Green
} else {
    Write-Host "   Tethering whitelisted = ❌ No" -ForegroundColor Red
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "🎉 Fix applied! Test tonight — hotspot should stay ON." -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
