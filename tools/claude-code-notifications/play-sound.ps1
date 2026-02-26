# Claude Code Notification Sound Player
# Usage: play-sound.ps1 <sound-file>

param(
    [Parameter(Mandatory=$true)]
    [string]$SoundFile
)

# Resolve full path
if (Test-Path $SoundFile) {
    $fullPath = (Resolve-Path $SoundFile).Path
} else {
    # Try relative to script location
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $fullPath = Join-Path $scriptDir $SoundFile
}

if (-not (Test-Path $fullPath)) {
    # Fallback to system sound if file not found
    [System.Media.SystemSounds]::Asterisk.Play()
    exit 0
}

try {
    # Use Windows Media Player COM object to play audio (supports ogg, mp3, wav)
    $player = New-Object -ComObject WMPlayer.OCX
    $player.URL = $fullPath
    $player.settings.volume = 100
    $player.settings.setMode("loop", $false)

    # Wait for media to be ready
    $readyTimeout = 0
    while ($player.openState -ne 13 -and $readyTimeout -lt 20) {
        Start-Sleep -Milliseconds 50
        $readyTimeout++
    }

    $player.controls.play()

    # Wait for playback to start and complete (max 5 seconds)
    $timeout = 0
    Start-Sleep -Milliseconds 200
    while ($player.playState -eq 3 -and $timeout -lt 50) {
        Start-Sleep -Milliseconds 100
        $timeout++
    }

    # Cleanup
    $player.controls.stop()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($player) | Out-Null
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
} catch {
    # Fallback to system sound if playback fails
    [System.Media.SystemSounds]::Asterisk.Play()
}
