# common.ps1 - Windows 公共函数库

# 颜色定义
$Script:Colors = @{
    Reset = "`e[0m"
    Red = "`e[31m"
    Green = "`e[32m"
    Yellow = "`e[33m"
    Blue = "`e[34m"
    Magenta = "`e[35m"
    Cyan = "`e[36m"
    White = "`e[37m"
    Bold = "`e[1m"
}

# 日志文件
$Script:LogFile = Join-Path $env:TEMP "claude-code-install.log"
$Script:InstalledPackages = @()

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    Add-Content -Path $Script:LogFile -Value $logEntry
}

function Write-Step {
    param([string]$Message)
    Write-Host "${$Script:Colors.Cyan}[*] $Message${$Script:Colors.Reset}"
    Write-Log "STEP: $Message"
}

function Write-Success {
    param([string]$Message)
    Write-Host "${$Script:Colors.Green}[OK] $Message${$Script:Colors.Reset}"
    Write-Log "SUCCESS: $Message"
}

function Write-Warning {
    param([string]$Message)
    Write-Host "${$Script:Colors.Yellow}[!] $Message${$Script:Colors.Reset}"
    Write-Log "WARNING: $Message"
}

function Write-Error {
    param([string]$Message)
    Write-Host "${$Script:Colors.Red}[X] $Message${$Script:Colors.Reset}"
    Write-Log "ERROR: $Message"
}

function Write-Info {
    param([string]$Message)
    Write-Host "${$Script:Colors.Blue}[i] $Message${$Script:Colors.Reset}"
    Write-Log "INFO: $Message"
}

function Test-Command {
    param([string]$Command)
    $result = Get-Command $Command -ErrorAction SilentlyContinue
    return $null -ne $result
}

function Get-SystemInfo {
    $os = Get-CimInstance Win32_OperatingSystem
    $arch = $env:PROCESSOR_ARCHITECTURE

    return @{
        OS = $os.Caption
        Version = $os.Version
        Arch = if ($arch -eq "AMD64") { "x64" } elseif ($arch -eq "ARM64") { "arm64" } else { $arch }
        HasWinget = Test-Command "winget"
        HasGit = Test-Command "git"
        HasNode = Test-Command "node"
        HasNpm = Test-Command "npm"
        NodeVersion = if (Test-Command "node") { (node --version) } else { $null }
    }
}

function Show-Header {
    param([string]$Title)
    $width = 54
    $padding = [Math]::Max(0, ($width - $Title.Length - 2) / 2)

    Write-Host ""
    Write-Host "${$Script:Colors.Cyan}$('═' * $width)${$Script:Colors.Reset}"
    Write-Host "${$Script:Colors.Cyan}║${$Script:Colors.Reset}$(' ' * [Math]::Floor($padding))${$Script:Colors.Bold}$Title${$Script:Colors.Reset}$(' ' * [Math]::Ceiling($padding))${$Script:Colors.Cyan}║${$Script:Colors.Reset}"
    Write-Host "${$Script:Colors.Cyan}$('═' * $width)${$Script:Colors.Reset}"
    Write-Host ""
}

function Show-ProgressBar {
    param(
        [int]$Current,
        [int]$Total,
        [string]$Label
    )
    $percent = [Math]::Round(($Current / $Total) * 100)
    $filled = [Math]::Round($percent / 5)
    $empty = 20 - $filled
    $bar = "${$Script:Colors.Green}$('█' * $filled)${$Script:Colors.Reset}$('░' * $empty)"

    Write-Host "`r$Label [$bar] $percent%" -NoNewline
    if ($Current -eq $Total) {
        Write-Host ""
    }
}

function Install-WithWinget {
    param(
        [string]$PackageId,
        [string]$Name
    )

    Write-Step "安装 $Name..."
    $result = winget install --id $PackageId --accept-source-agreements --accept-package-agreements -e 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Success "$Name 安装成功"
        $Script:InstalledPackages += $PackageId
        return $true
    } else {
        Write-Error "$Name 安装失败: $result"
        return $false
    }
}

function Request-Admin {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "需要管理员权限，正在请求..."
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
}

function Show-RollbackInfo {
    if ($Script:InstalledPackages.Count -gt 0) {
        Write-Host ""
        Write-Warning "以下软件包已安装，如需回滚请手动卸载："
        foreach ($pkg in $Script:InstalledPackages) {
            Write-Host "  - $pkg (winget uninstall --id $pkg)"
        }
    }
    Write-Host ""
    Write-Info "安装日志: $Script:LogFile"
}

function New-ClaudeSettings {
    param(
        [string]$ApiProvider,
        [string]$ApiKey,
        [bool]$SkipPermissions,
        [string]$GithubToken,
        [bool]$EnableNotifications,
        [bool]$UseNpmMirror
    )

    $claudeDir = Join-Path $env:USERPROFILE ".claude"
    if (-not (Test-Path $claudeDir)) {
        New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
    }

    $settings = @{}

    # API 配置
    if ($ApiProvider -eq "zhipu") {
        $settings.env = @{
            ANTHROPIC_AUTH_TOKEN = $ApiKey
            ANTHROPIC_BASE_URL = "https://open.bigmodel.cn/api/anthropic"
            API_TIMEOUT_MS = "3000000"
            CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1"
            ANTHROPIC_DEFAULT_HAIKU_MODEL = "glm-5"
            ANTHROPIC_DEFAULT_SONNET_MODEL = "glm-5"
            ANTHROPIC_DEFAULT_OPUS_MODEL = "glm-5"
        }
    } else {
        $settings.env = @{
            ANTHROPIC_API_KEY = $ApiKey
            ANTHROPIC_DEFAULT_HAIKU_MODEL = "claude-3-5-haiku-20241022"
            ANTHROPIC_DEFAULT_SONNET_MODEL = "claude-sonnet-4-20250514"
            ANTHROPIC_DEFAULT_OPUS_MODEL = "claude-opus-4-20250514"
        }
    }

    # 权限配置
    if ($SkipPermissions) {
        $settings.permissions = @{
            defaultMode = "bypassPermissions"
        }
        $settings.skipDangerousModePermissionPrompt = $true
    }

    # GitHub Token
    if ($GithubToken) {
        $settings.env.GITHUB_TOKEN = $GithubToken
    }

    # 通知配置 (Windows)
    if ($EnableNotifications) {
        $settings.hooks = @{
            Notification = @(@{
                hooks = @(@{
                    type = "command"
                    command = "powershell -c (New-Object Media.SoundPlayer 'C:\Windows\Media\notify.wav').PlaySync()"
                })
            })
            Stop = @(@{
                hooks = @(@{
                    type = "command"
                    command = "powershell -c (New-Object Media.SoundPlayer 'C:\Windows\Media\Windows Notify System.wav').PlaySync()"
                })
            })
        }
    }

    # 保存配置
    $settingsPath = Join-Path $claudeDir "settings.json"
    $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8

    # npm 镜像
    if ($UseNpmMirror) {
        npm config set registry https://registry.npmmirror.com
    }

    return $settingsPath
}
