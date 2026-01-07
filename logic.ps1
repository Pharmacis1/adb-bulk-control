Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- 0. CONFIGURATION (EDIT HERE) ---
$WindowTitle    = "Android ADB Control Center"
$TargetPackage  = "com.addreality.player2"       # Package name to manage
$TargetActivity = ".AIRAppEntry"                 # Main Activity (for surgical start)
$NTPServer      = "pool.ntp.org"                 # Time server (use local IP if offline)

# --- SETUP & STYLING ---
[System.Windows.Forms.Application]::EnableVisualStyles()
$modernFont = New-Object System.Drawing.Font("Segoe UI", 10)
$headerFont = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$bgColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$fgColor = [System.Drawing.Color]::White
$inputColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
$accentColor = [System.Drawing.Color]::FromArgb(0, 122, 204)
$grayColor = [System.Drawing.Color]::Gray

# --- FORM SETUP ---
$form = New-Object System.Windows.Forms.Form
$form.Text = $WindowTitle
$form.Size = New-Object System.Drawing.Size(900, 700)
$form.StartPosition = "CenterScreen"
$form.BackColor = $bgColor
$form.ForeColor = $fgColor
$form.FormBorderStyle = "Sizable"
$form.MaximizeBox = $true

# --- ACTION MODES ---
$grpMode = New-Object System.Windows.Forms.GroupBox
$grpMode.Text = "1. Select Action"
$grpMode.Location = New-Object System.Drawing.Point(20, 10)
$grpMode.Size = New-Object System.Drawing.Size(840, 70)
$grpMode.ForeColor = $accentColor
$grpMode.Font = $headerFont
$grpMode.Anchor = "Top, Left, Right"

# Buttons
$radioUpdate = New-Object System.Windows.Forms.RadioButton
$radioUpdate.Text = "Update APK"
$radioUpdate.Location = New-Object System.Drawing.Point(15, 25); $radioUpdate.AutoSize = $true; $radioUpdate.ForeColor = $fgColor
$radioUpdate.Checked = $true

$radioTZ = New-Object System.Windows.Forms.RadioButton
$radioTZ.Text = "Set Time Zone"
$radioTZ.Location = New-Object System.Drawing.Point(140, 25); $radioTZ.AutoSize = $true; $radioTZ.ForeColor = $fgColor

$radioWake = New-Object System.Windows.Forms.RadioButton
$radioWake.Text = "Restart App"
$radioWake.Location = New-Object System.Drawing.Point(280, 25); $radioWake.AutoSize = $true; $radioWake.ForeColor = $fgColor

$radioScreen = New-Object System.Windows.Forms.RadioButton
$radioScreen.Text = "Get Screenshot"
$radioScreen.Location = New-Object System.Drawing.Point(420, 25); $radioScreen.AutoSize = $true; $radioScreen.ForeColor = $fgColor

$radioReboot = New-Object System.Windows.Forms.RadioButton
$radioReboot.Text = "Full Reboot"
$radioReboot.Location = New-Object System.Drawing.Point(560, 25); $radioReboot.AutoSize = $true; $radioReboot.ForeColor = $fgColor

$grpMode.Controls.AddRange(@($radioUpdate, $radioTZ, $radioWake, $radioScreen, $radioReboot))

# --- SETTINGS PANEL ---
$panelSettings = New-Object System.Windows.Forms.Panel
$panelSettings.Location = New-Object System.Drawing.Point(20, 90); $panelSettings.Size = New-Object System.Drawing.Size(840, 50); $panelSettings.Anchor = "Top, Left, Right"

$lblSetting = New-Object System.Windows.Forms.Label
$lblSetting.Text = "Settings:"
$lblSetting.Location = New-Object System.Drawing.Point(0, 5); $lblSetting.AutoSize = $true; $lblSetting.Font = $modernFont; $lblSetting.ForeColor = $grayColor

$comboSettings = New-Object System.Windows.Forms.ComboBox
$comboSettings.Location = New-Object System.Drawing.Point(80, 0); $comboSettings.Size = New-Object System.Drawing.Size(500, 30); $comboSettings.Font = $modernFont; $comboSettings.FlatStyle = "Flat"

$chkReboot = New-Object System.Windows.Forms.CheckBox
$chkReboot.Text = "Force Reboot"
$chkReboot.Location = New-Object System.Drawing.Point(600, 3); $chkReboot.AutoSize = $true; $chkReboot.ForeColor = $fgColor
$chkReboot.Visible = $false

$panelSettings.Controls.AddRange(@($lblSetting, $comboSettings, $chkReboot))

# --- DATA PREPARATION ---
$apkFiles = Get-ChildItem -Path . -Filter *.apk
$apkList = @()
if ($apkFiles.Count -gt 0) { foreach ($file in $apkFiles) { $apkList += $file.Name } } else { $apkList += "No APK files found!" }

$tzMap = [ordered]@{}
$tzMap["UTC+2  | Kaliningrad"] = "Europe/Kaliningrad"
$tzMap["UTC+3  | Moscow, SPb"] = "Europe/Moscow"
$tzMap["UTC+4  | Samara"] = "Europe/Samara"
$tzMap["UTC+5  | Yekaterinburg"] = "Asia/Yekaterinburg"
$tzMap["UTC+6  | Omsk"] = "Asia/Omsk"
$tzMap["UTC+7  | Novosibirsk, Barnaul"] = "Asia/Barnaul"
$tzMap["UTC+7  | Krasnoyarsk"] = "Asia/Krasnoyarsk"
$tzMap["UTC+8  | Irkutsk"] = "Asia/Irkutsk"
$tzMap["UTC+9  | Yakutsk"] = "Asia/Yakutsk"
$tzMap["UTC+10 | Vladivostok"] = "Asia/Vladivostok"
$tzMap["UTC+11 | Magadan"] = "Asia/Magadan"
$tzMap["UTC+12 | Kamchatka"] = "Asia/Kamchatka"

# --- SPLIT UI ---
$lblInput = New-Object System.Windows.Forms.Label
$lblInput.Text = "2. Device List (Persists):"
$lblInput.Location = New-Object System.Drawing.Point(20, 150)
$lblInput.AutoSize = $true; $lblInput.Font = $headerFont; $lblInput.ForeColor = $accentColor

$txtInput = New-Object System.Windows.Forms.TextBox
$txtInput.Location = New-Object System.Drawing.Point(20, 180)
$txtInput.Size = New-Object System.Drawing.Size(250, 400)
$txtInput.Multiline = $true; $txtInput.ScrollBars = "Vertical"
$txtInput.Font = $modernFont; $txtInput.BackColor = $inputColor; $txtInput.ForeColor = $fgColor; $txtInput.BorderStyle = "FixedSingle"; $txtInput.Anchor = "Top, Bottom, Left"

$lblLog = New-Object System.Windows.Forms.Label
$lblLog.Text = "3. Process Logs:"
$lblLog.Location = New-Object System.Drawing.Point(290, 150)
$lblLog.AutoSize = $true; $lblLog.Font = $headerFont; $lblLog.ForeColor = $grayColor

$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Location = New-Object System.Drawing.Point(290, 180)
$txtLog.Size = New-Object System.Drawing.Size(570, 400)
$txtLog.Multiline = $true; $txtLog.ScrollBars = "Vertical"
$txtLog.Font = $modernFont; $txtLog.BackColor = [System.Drawing.Color]::Black; $txtLog.ForeColor = [System.Drawing.Color]::Lime; $txtLog.BorderStyle = "FixedSingle"; $txtLog.ReadOnly = $true; $txtLog.Anchor = "Top, Bottom, Left, Right"

$btn = New-Object System.Windows.Forms.Button
$btn.Location = New-Object System.Drawing.Point(20, 600)
$btn.Size = New-Object System.Drawing.Size(840, 45)
$btn.Text = "RUN SELECTED ACTION"
$btn.Font = $headerFont; $btn.BackColor = $accentColor; $btn.ForeColor = $fgColor; $btn.FlatStyle = "Flat"; $btn.Cursor = "Hand"; $btn.Anchor = "Bottom, Left, Right"

$form.Controls.AddRange(@($grpMode, $panelSettings, $lblInput, $txtInput, $lblLog, $txtLog, $btn))

# --- UI LOGIC ---
function Update-UI {
    $comboSettings.Items.Clear()
    $panelSettings.Visible = $true 
    
    if ($radioUpdate.Checked) {
        $comboSettings.Enabled = $true
        foreach ($item in $apkList) { $comboSettings.Items.Add($item) }
        $comboSettings.SelectedIndex = 0
        $chkReboot.Visible = $true; $chkReboot.Text = "Auto-reboot"
        $chkReboot.Checked = $false
    }
    elseif ($radioTZ.Checked) {
        $comboSettings.Enabled = $true
        foreach ($key in $tzMap.Keys) { $comboSettings.Items.Add($key) }
        $comboSettings.SelectedIndex = 1
        $chkReboot.Visible = $true; $chkReboot.Text = "Force Reboot"
        $chkReboot.Checked = $false 
    }
    else {
        $panelSettings.Visible = $false
    }
}
$radioUpdate.Add_CheckedChanged({ Update-UI }); $radioTZ.Add_CheckedChanged({ Update-UI }); 
$radioReboot.Add_CheckedChanged({ Update-UI }); $radioWake.Add_CheckedChanged({ Update-UI })
$radioScreen.Add_CheckedChanged({ Update-UI })
Update-UI

# --- HELPER: LOGGER ---
function Log-Me {
    param($text, $color="White", $file)
    $txtLog.AppendText("$text`r`n")
    $txtLog.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
    if ($file) { $ts = Get-Date -Format "HH:mm:ss"; Add-Content -Path $file -Value "[$ts] $text" -Encoding UTF8 }
}

# --- MAIN LOGIC ---
$btn.Add_Click({
    $rawText = $txtInput.Text
    $ipv4Pattern = "\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b"
    $cleanIpList = [Regex]::Matches($rawText, $ipv4Pattern) | ForEach-Object { $_.Value } | Select-Object -Unique
    
    if ($cleanIpList.Count -eq 0) { [System.Windows.Forms.MessageBox]::Show("IP List is empty!", "Error", "OK", "Warning"); return }
    $txtInput.Text = $cleanIpList -join "`r`n"
    
    $actionName = ""
    if ($radioUpdate.Checked) { $actionName = "UPDATE" } 
    elseif ($radioTZ.Checked) { $actionName = "TIMEZONE + NTP" } 
    elseif ($radioWake.Checked) { $actionName = "RESTART APP" }
    elseif ($radioScreen.Checked) { $actionName = "SCREENSHOT" }
    else { $actionName = "FULL REBOOT" }

    $logDir = "logs_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    $detailedLog = "$logDir\detailed.log"; $successLog = "$logDir\success.log"; $errorLog = "$logDir\error.log"
    $screenDir = "$PSScriptRoot\Screenshots"; if ($radioScreen.Checked) { New-Item -ItemType Directory -Path $screenDir -Force | Out-Null }

    $txtLog.Clear()
    Log-Me ">>> STARTED: $actionName ($($cleanIpList.Count) devices)" "Cyan" $detailedLog
    Log-Me "Target App: $TargetPackage" "Gray" $detailedLog
    
    cmd /c "adb kill-server" 2>&1 | Out-Null; Start-Sleep -Seconds 1
    cmd /c "adb start-server" 2>&1 | Out-Null; Start-Sleep -Seconds 2

    foreach ($ip in $cleanIpList) {
        Log-Me "`nTarget: $ip" "Yellow" $detailedLog
        
        if (-not (Test-Connection -ComputerName $ip -Count 1 -Quiet -ErrorAction SilentlyContinue)) { Log-Me "[ERROR] Offline (Ping)" "Red" $errorLog; continue }
        
        $isConnected = $false
        for ($i=1; $i -le 3; $i++) {
            cmd /c "adb disconnect $ip" 2>&1 | Out-Null
            $connRaw = cmd /c "adb connect $ip"
            if ($connRaw -match "connected") { $isConnected = $true; break } 
            else { Log-Me "   ...retry connection ($i/3)" "Gray" $detailedLog; Start-Sleep -Seconds 2 }
        }
        if (-not $isConnected) { Log-Me "[ERROR] ADB Connect Failed" "Red" $errorLog; continue }

        # --- ACTIONS ---
        if ($radioUpdate.Checked) {
            $apkName = $comboSettings.SelectedItem; Log-Me "Installing $apkName..." "Gray" $detailedLog
            $inst = cmd /c "adb -s $ip install -r -d `"$apkName`""
            if ($inst -match "Success") { 
                Log-Me "[OK] INSTALLED" "Green" $successLog 
                if ($chkReboot.Checked) { cmd /c "adb -s $ip reboot"; Log-Me "   Reboot sent." "Gray" $detailedLog }
            } else {
                Log-Me "[!] Plan A failed. Pushing..." "Orange" $detailedLog
                cmd /c "adb -s $ip push `"$apkName`" /sdcard/temp.apk"; $sh = cmd /c "adb -s $ip shell pm install -r -d /sdcard/temp.apk"; cmd /c "adb -s $ip shell rm /sdcard/temp.apk"
                if ($sh -match "Success") { 
                    Log-Me "[OK] INSTALLED (Push)" "Green" $successLog
                    if ($chkReboot.Checked) { cmd /c "adb -s $ip reboot"; Log-Me "   Reboot sent." "Gray" $detailedLog }
                } else { Log-Me "[ERROR] UPDATE FAILED" "Red" $errorLog }
            }
        }
        elseif ($radioTZ.Checked) {
            $targetTZ = $tzMap[$comboSettings.SelectedItem]; $currentTZ = (cmd /c "adb -s $ip shell getprop persist.sys.timezone").Trim()
            if ($currentTZ -eq $targetTZ -and $chkReboot.Checked -eq $false) { Log-Me "[SKIP] Already set to $currentTZ" "Green" $successLog } else {
                if ($currentTZ -ne $targetTZ) { Log-Me "Changing TZ: $currentTZ -> $targetTZ" "Orange" $detailedLog }
                cmd /c "adb -s $ip shell settings put global ntp_server $NTPServer"; cmd /c "adb -s $ip shell setprop persist.sys.timezone $targetTZ"
                $verifyTZ = (cmd /c "adb -s $ip shell getprop persist.sys.timezone").Trim()
                if ($verifyTZ -eq $targetTZ) { Log-Me "[OK] APPLIED: $verifyTZ (Rebooting...)" "Green" $successLog; cmd /c "adb -s $ip reboot" } 
                else { Log-Me "[ERROR] FAILED: Wanted $targetTZ, got $verifyTZ" "Red" $errorLog }
            }
        }
        elseif ($radioWake.Checked) {
            Log-Me "Restarting App ($TargetPackage)..." "Gray" $detailedLog
            cmd /c "adb -s $ip shell input keyevent 224"; cmd /c "adb -s $ip shell input keyevent 82"; Start-Sleep -Milliseconds 500
            cmd /c "adb -s $ip shell am force-stop $TargetPackage"; Start-Sleep -Milliseconds 500
            
            # Use configured package and activity
            $startCmd = "adb -s $ip shell am start -n $TargetPackage/$TargetActivity"
            $start = cmd /c $startCmd
            
            if ($start -match "Error") { Log-Me "[!] Launch Failed: $start" "Red" $errorLog } else { Log-Me "[OK] APP STARTED" "Green" $successLog }
        }
        elseif ($radioScreen.Checked) {
            Log-Me "Capturing screenshot..." "Gray" $detailedLog
            $fileName = "$($ip -replace '\.', '_')_$(Get-Date -Format 'HHmm').png"; $localPath = "$screenDir\$fileName"
            cmd /c "adb -s $ip shell screencap -p /sdcard/temp.png"; cmd /c "adb -s $ip pull /sdcard/temp.png `"$localPath`""; cmd /c "adb -s $ip shell rm /sdcard/temp.png"
            if (Test-Path $localPath) { Log-Me "[OK] SAVED: $fileName" "Green" $successLog; if ($cleanIpList.Count -eq 1) { Invoke-Item $localPath } } 
            else { Log-Me "[ERROR] Screenshot failed" "Red" $errorLog }
        }
        elseif ($radioReboot.Checked) { cmd /c "adb -s $ip reboot"; Log-Me "[OK] FULL REBOOT SENT" "Green" $successLog }
        
        cmd /c "adb disconnect $ip" 2>&1 | Out-Null
    }
    if ($radioScreen.Checked -and $cleanIpList.Count -gt 1) { Invoke-Item $screenDir }
    Log-Me "`n>>> COMPLETED." "Cyan" $detailedLog
})
$form.ShowDialog() | Out-Null