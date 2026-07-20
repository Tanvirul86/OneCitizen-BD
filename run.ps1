# Launches the Pixel_7_API_34 Android emulator (if not already running) and runs the app on it.

$emulator = "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe"
$device = & adb devices | Select-String "emulator-\d+\s+device$"

if (-not $device) {
    Write-Host "Starting Pixel_7_API_34 emulator..."
    Start-Process -FilePath $emulator -ArgumentList "-avd", "Pixel_7_API_34", "-gpu", "swiftshader_indirect" -WindowStyle Hidden

    Write-Host "Waiting for emulator to come online..."
    & adb wait-for-device

    Write-Host "Waiting for boot to complete..."
    do {
        Start-Sleep -Seconds 2
        $booted = & adb shell getprop sys.boot_completed 2>$null
    } while ($booted -ne "1")

    Write-Host "Emulator ready."
} else {
    Write-Host "Emulator already running."
}

$deviceId = (& adb devices | Select-String "emulator-\d+\s+device$").ToString().Split()[0]
Write-Host "Launching app on $deviceId..."
flutter run -d $deviceId
