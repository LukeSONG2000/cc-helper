<#
.SYNOPSIS
    Claude Code 一键安装器 for Windows
.DESCRIPTION
    自动检测系统、安装依赖、配置 Claude Code
.EXAMPLE
    irm https://raw.githubusercontent.com/LukeSONG2000/cc-helper/main/scripts/install.ps1 | iex
#>

# 设置编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# 切换到脚本目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = $PWD.Path }

# 加载模块
. (Join-Path $ScriptDir "modules\common.ps1")
. (Join-Path $ScriptDir "modules\node.ps1")

# 配置选项
$Script:Config = @{
    ApiProvider = "zhipu"
    ApiKey = ""
    SkipPermissions = $true
    GithubToken = ""
    EnableNotifications = $false
    UseNpmMirror = $true
}

# ============================================================
# 交互式配置界面
# ============================================================

function Show-TUIMenu {
    param(
        [string]$Title,
        [string[]]$Options,
        [int]$Selected = 0
    )

    $width = 54
    $height = $Options.Count + 4

    # 清除区域
    for ($i = 0; $i -lt $height; $i++) {
        Write-Host "`e[$($i + 1);1H`e[K"
    }

    # 显示标题
    Write-Host "`e[1;1H${$Script:Colors.Cyan}$('─' * $width)${$Script:Colors.Reset}"
    Write-Host "`e[2;1H${$Script:Colors.Cyan}│${$Script:Colors.Reset} ${$Script:Colors.Bold}$Title${$Script:Colors.Reset}$(' ' * ($width - $Title.Length - 3))${$Script:Colors.Cyan}│${$Script:Colors.Reset}"
    Write-Host "`e[3;1H${$Script:Colors.Cyan}$('─' * $width)${$Script:Colors.Reset}"

    # 显示选项
    for ($i = 0; $i -lt $Options.Count; $i++) {
        $prefix = if ($i -eq $Selected) { "${$Script:Colors.Green}► " } else { "  " }
        $suffix = if ($i -eq $Selected) { "${$Script:Colors.Reset}" } else { "" }
        $line = "$prefix$($Options[$i])$suffix"
        Write-Host "`e[$($i + 4);1H$line"
    }
}

function Read-MenuSelection {
    param(
        [string]$Title,
        [string[]]$Options,
        [int]$Default = 0
    )

    $selected = $Default
    $origPos = $Host.UI.RawUI.CursorPosition

    # 隐藏光标
    Write-Host "`e[?25l" -NoNewline

    try {
        Show-TUIMenu -Title $Title -Options $Options -Selected $selected

        while ($true) {
            $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

            switch ($key.VirtualKeyCode) {
                38 { # Up
                    $selected = [Math]::Max(0, $selected - 1)
                    Show-TUIMenu -Title $Title -Options $Options -Selected $selected
                }
                40 { # Down
                    $selected = [Math]::Min($Options.Count - 1, $selected + 1)
                    Show-TUIMenu -Title $Title -Options $Options -Selected $selected
                }
                13 { # Enter
                    return $selected
                }
                27 { # Escape
                    return -1
                }
            }
        }
    } finally {
        # 恢复光标
        Write-Host "`e[?25h" -NoNewline
        $Host.UI.RawUI.CursorPosition = $origPos
    }
}

function Show-CheckboxMenu {
    param(
        [string]$Title,
        [string[]]$Options,
        [bool[]]$Checked
    )

    $selected = 0
    $origPos = $Host.UI.RawUI.CursorPosition

    Write-Host "`e[?25l" -NoNewline

    try {
        while ($true) {
            # 清除并重绘
            Write-Host "`e[$($origPos.Y + 1);1H"
            Write-Host "${$Script:Colors.Cyan}$('─' * 54)${$Script:Colors.Reset}"
            Write-Host "${$Script:Colors.Cyan}│${$Script:Colors.Reset} ${$Script:Colors.Bold}$Title${$Script:Colors.Reset}"
            Write-Host "${$Script:Colors.Cyan}$('─' * 54)${$Script:Colors.Reset}"

            for ($i = 0; $i -lt $Options.Count; $i++) {
                $checkbox = if ($Checked[$i]) { "${$Script:Colors.Green}[X]${$Script:Colors.Reset}" } else { "[ ]" }
                $prefix = if ($i -eq $selected) { "${$Script:Colors.Yellow}►${$Script:Colors.Reset} " } else { "  " }
                Write-Host "$prefix$checkbox $($Options[$i])"
            }

            Write-Host ""
            Write-Host "${$Script:Colors.Cyan}↑↓ 选择  │  Space 切换  │  Enter 确认${$Script:Colors.Reset}"

            $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

            switch ($key.VirtualKeyCode) {
                38 { $selected = [Math]::Max(0, $selected - 1) }
                40 { $selected = [Math]::Min($Options.Count - 1, $selected + 1) }
                32 { $Checked[$selected] = -not $Checked[$selected] }  # Space
                13 { return $Checked }  # Enter
                27 { return $Checked }  # Escape
            }
        }
    } finally {
        Write-Host "`e[?25h" -NoNewline
    }
}

function Invoke-InteractiveConfig {
    Show-Header "Claude Code 配置助手"

    # 1. 选择 API 提供商
    Write-Host "`n${$Script:Colors.Bold}[1/4] 选择 API 提供商${$Script:Colors.Reset}"
    $apiOptions = @(
        "智谱 AI (GLM-5) - 推荐，国内直连",
        "Anthropic 官方 - 需要代理"
    )
    $apiChoice = Read-MenuSelection -Title "选择 API 提供商" -Options $apiOptions -Default 0
    $Script:Config.ApiProvider = if ($apiChoice -eq 0) { "zhipu" } else { "anthropic" }

    # 2. 输入 API Key
    Write-Host "`n${$Script:Colors.Bold}[2/4] 输入 API Key${$Script:Colors.Reset}"

    if ($Script:Config.ApiProvider -eq "zhipu") {
        Write-Host "请访问 ${$Script:Colors.Cyan}https://open.bigmodel.cn${$Script:Colors.Reset} 获取 API Key"
    } else {
        Write-Host "请访问 ${$Script:Colors.Cyan}https://console.anthropic.com${$Script:Colors.Reset} 获取 API Key"
    }

    Write-Host ""
    $apiKey = Read-Host "API Key"
    $Script:Config.ApiKey = $apiKey.Trim()

    if ([string]::IsNullOrWhiteSpace($Script:Config.ApiKey)) {
        Write-Error "API Key 不能为空"
        exit 1
    }

    # 3. 权限模式
    Write-Host "`n${$Script:Colors.Bold}[3/4] 权限模式${$Script:Colors.Reset}"
    $permOptions = @(
        "跳过权限确认 (推荐) - 更流畅的体验",
        "标准模式 - 每次操作需确认"
    )
    $permChoice = Read-MenuSelection -Title "权限模式" -Options $permOptions -Default 0
    $Script:Config.SkipPermissions = ($permChoice -eq 0)

    # 4. 可选配置
    Write-Host "`n${$Script:Colors.Bold}[4/4] 可选配置${$Script:Colors.Reset}"
    $optionalOptions = @(
        "配置 GitHub Token",
        "安装通知系统",
        "配置 npm 镜像加速"
    )
    $optionalChecked = Show-CheckboxMenu -Title "可选配置" -Options $optionalOptions -Checked @($false, $false, $true)

    if ($optionalChecked[0]) {
        Write-Host "`n请输入 GitHub Token (可选，直接回车跳过):"
        $Script:Config.GithubToken = Read-Host "GitHub Token"
    }

    $Script:Config.EnableNotifications = $optionalChecked[1]
    $Script:Config.UseNpmMirror = $optionalChecked[2]

    # 确认配置
    Show-Header "配置确认"
    Write-Host "API 提供商:   ${$Script:Colors.Green}$(if ($Script:Config.ApiProvider -eq 'zhipu') { '智谱 AI (GLM-5)' } else { 'Anthropic 官方' })${$Script:Colors.Reset}"
    Write-Host "API Key:      ${$Script:Colors.Green}$($Script:Config.ApiKey.Substring(0, [Math]::Min(8, $Script:Config.ApiKey.Length)))...${$Script:Colors.Reset}"
    Write-Host "权限模式:     ${$Script:Colors.Green}$(if ($Script:Config.SkipPermissions) { '跳过确认' } else { '标准模式' })${$Script:Colors.Reset}"
    Write-Host "npm 镜像:     ${$Script:Colors.Green}$(if ($Script:Config.UseNpmMirror) { '已启用 (npmmirror.com)' } else { '未启用' })${$Script:Colors.Reset}"
    Write-Host "通知系统:     ${$Script:Colors.Green}$(if ($Script:Config.EnableNotifications) { '已启用' } else { '未启用' })${$Script:Colors.Reset}"
    Write-Host ""

    $confirmOptions = @("开始安装", "取消")
    $confirm = Read-MenuSelection -Title "确认安装" -Options $confirmOptions -Default 0

    if ($confirm -ne 0) {
        Write-Host "`n${$Script:Colors.Yellow}安装已取消${$Script:Colors.Reset}"
        exit 0
    }
}

# ============================================================
# 主安装流程
# ============================================================

function Invoke-Install {
    param([switch]$NonInteractive)

    # 显示欢迎信息
    Show-Header "Claude Code 一键安装器"

    # 系统检测
    Write-Step "检测系统信息..."
    $sysInfo = Get-SystemInfo

    Write-Host "  操作系统:   ${$Script:Colors.Green}$($sysInfo.OS)${$Script:Colors.Reset}"
    Write-Host "  架构:       ${$Script:Colors.Green}$($sysInfo.Arch)${$Script:Colors.Reset}"
    Write-Host "  winget:     $(if ($sysInfo.HasWinget) { "${$Script:Colors.Green}已安装${$Script:Colors.Reset}" } else { "${$Script:Colors.Yellow}未安装${$Script:Colors.Reset}" })"
    Write-Host "  Git:        $(if ($sysInfo.HasGit) { "${$Script:Colors.Green}$($sysInfo.NodeVersion)${$Script:Colors.Reset}" } else { "${$Script:Colors.Yellow}未安装${$Script:Colors.Reset}" })"
    Write-Host "  Node.js:    $(if ($sysInfo.HasNode) { "${$Script:Colors.Green}$($sysInfo.NodeVersion)${$Script:Colors.Reset}" } else { "${$Script:Colors.Yellow}未安装${$Script:Colors.Reset}" })"
    Write-Host ""

    # 检查 winget
    if (-not $sysInfo.HasWinget) {
        Write-Error "未检测到 winget，请确保使用 Windows 11 或 Windows 10 (1809+)"
        Write-Info "或手动安装: https://learn.microsoft.com/windows/package-manager/winget/"
        exit 1
    }

    # 交互式配置
    if (-not $NonInteractive) {
        Invoke-InteractiveConfig
    }

    # 开始安装
    Write-Host ""
    Show-Header "开始安装"

    # 1. 安装 Git
    $steps = 4
    Show-ProgressBar -Current 0 -Total $steps -Label "安装依赖"
    $gitResult = Install-Git

    # 2. 安装 Node.js
    Show-ProgressBar -Current 1 -Total $steps -Label "安装依赖"
    $nodeResult = Install-NodeJS

    if (-not $nodeResult) {
        Write-Error "Node.js 安装失败"
        Show-RollbackInfo
        exit 1
    }

    # 3. 配置 npm 镜像
    Show-ProgressBar -Current 2 -Total $steps -Label "配置环境"
    if ($Script:Config.UseNpmMirror) {
        Set-NpmMirror
    }

    # 4. 安装 Claude Code
    Show-ProgressBar -Current 3 -Total $steps -Label "安装 Claude Code"

    # 刷新环境变量
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    Write-Step "安装 @anthropic-ai/claude-code..."
    $npmResult = npm install -g @anthropic-ai/claude-code 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Claude Code 安装失败"
        Write-Host $npmResult
        Show-RollbackInfo
        exit 1
    }

    Write-Success "Claude Code 安装成功"
    Show-ProgressBar -Current 4 -Total $steps -Label "安装完成"

    # 生成配置文件
    Write-Step "生成配置文件..."
    $settingsPath = New-ClaudeSettings `
        -ApiProvider $Script:Config.ApiProvider `
        -ApiKey $Script:Config.ApiKey `
        -SkipPermissions $Script:Config.SkipPermissions `
        -GithubToken $Script:Config.GithubToken `
        -EnableNotifications $Script:Config.EnableNotifications `
        -UseNpmMirror $Script:Config.UseNpmMirror

    Write-Success "配置文件已保存: $settingsPath"

    # 完成
    Write-Host ""
    Show-Header "安装完成"

    Write-Host "${$Script:Colors.Green}Claude Code 已成功安装！${$Script:Colors.Reset}"
    Write-Host ""
    Write-Host "使用方法:"
    Write-Host "  ${$Script:Colors.Cyan}claude${$Script:Colors.Reset}          启动 Claude Code"
    Write-Host "  ${$Script:Colors.Cyan}claude --help${$Script:Colors.Reset}    查看帮助"
    Write-Host ""

    if (-not $sysInfo.HasNode) {
        Write-Warning "Node.js 刚安装完成，建议重启终端后再使用 claude 命令"
    }

    Write-Host "配置文件: ${$Script:Colors.Cyan}$settingsPath${$Script:Colors.Reset}"
    Write-Host "安装日志: ${$Script:Colors.Cyan}$Script:LogFile${$Script:Colors.Reset}"
    Write-Host ""
}

# ============================================================
# 命令行参数处理
# ============================================================

param(
    [switch]$NonInteractive,
    [switch]$Help,
    [string]$ApiKey,
    [string]$ApiProvider,
    [switch]$SkipPermissions,
    [switch]$UseMirror
)

if ($Help) {
    Write-Host @"
Claude Code 一键安装器

用法:
  .\install.ps1                    交互式安装
  .\install.ps1 -NonInteractive    非交互式安装

参数:
  -NonInteractive    非交互模式，使用默认配置
  -ApiKey           API Key
  -ApiProvider      API 提供商 (zhipu/anthropic)
  -SkipPermissions  跳过权限确认
  -UseMirror        使用 npm 镜像

示例:
  irm https://raw.githubusercontent.com/LukeSONG2000/cc-helper/main/scripts/install.ps1 | iex
"@
    exit 0
}

# 处理命令行参数
if ($ApiKey) { $Script:Config.ApiKey = $ApiKey }
if ($ApiProvider) { $Script:Config.ApiProvider = $ApiProvider }
if ($SkipPermissions) { $Script:Config.SkipPermissions = $true }
if ($UseMirror) { $Script:Config.UseNpmMirror = $true }

# 运行安装
try {
    Invoke-Install -NonInteractive:$NonInteractive
} catch {
    Write-Error "安装失败: $_"
    Write-Log "FATAL: $_"
    Show-RollbackInfo
    exit 1
}
