![AI Assisted](https://img.shields.io/badge/AI-Assisted-blue?style=flat-square&logo=openai)

# Android ADB Control Center

A lightweight PowerShell GUI tool for bulk management of Android devices via ADB (Android Debug Bridge). 
Designed for Digital Signage maintenance (kiosks, TV panels), but works with any Android devices.

## Features

* **Bulk Actions:** Execute commands on a list of IP addresses.
* **APK Update:** Smart installation (tries standard install first, fallbacks to push+install).
* **Timezone Fix:** Sets NTP server and Timezone (useful for devices with "SSL Handshake" errors due to wrong date).
* **App Restart:** Remotely force-stops and launches a specific app.
* **Screenshots:** Takes screenshots and saves them locally.
* **Logs:** Live execution logs in GUI + saved to file.

## Requirements

* Windows 10 / 11
* PowerShell
* `adb.exe` (must be in the same folder)

## Configuration

Open `logic.ps1` and edit the top section to match your target application:

```powershell
$TargetPackage  = "com.your.package.name"
$TargetActivity = ".MainActivity" 
$NTPServer      = "pool.ntp.org"
```

## Usage

1. Run START.bat.

2. Paste list of IP addresses (the tool extracts IPs from mixed text).

3. Select an action and click RUN.
