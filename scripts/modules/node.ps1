# node.ps1 - Windows Node.js 安装模块

function Install-NodeJS {
    param([switch]$UseMirror)

    Write-Step "检查 Node.js..."

    # 检查是否已安装
    if (Test-Command "node") {
        $version = node --version
        Write-Success "Node.js 已安装: $version"
        return $true
    }

    # 使用 winget 安装
    if (Test-Command "winget") {
        Write-Info "使用 winget 安装 Node.js LTS..."

        $result = winget install OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements -e 2>&1

        if ($LASTEXITCODE -eq 0) {
            Write-Success "Node.js 安装成功"

            # 刷新环境变量
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

            # 等待安装完成
            Start-Sleep -Seconds 3

            # 再次检查
            if (Test-Command "node") {
                $version = node --version
                Write-Success "Node.js 版本: $version"
                return $true
            } else {
                Write-Warning "Node.js 已安装，但需要重启终端才能使用"
                Write-Info "请关闭当前终端，打开新终端后运行 'node --version' 验证"
                return $true
            }
        } else {
            Write-Error "winget 安装 Node.js 失败"
            return $false
        }
    }

    # 备用方案：手动下载
    Write-Warning "未找到 winget，尝试手动安装..."
    return Install-NodeJS-Manual
}

function Install-NodeJS-Manual {
    $nodeVersion = "20.11.0"
    $arch = if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") { "x64" } else { "x86" }
    $url = "https://nodejs.org/dist/v$nodeVersion/node-v$nodeVersion-win-$arch.msi"
    $tempFile = Join-Path $env:TEMP "node-installer.msi"

    Write-Info "下载 Node.js $nodeVersion..."
    Write-Info "URL: $url"

    try {
        # 使用 .NET WebClient 下载
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($url, $tempFile)

        if (Test-Path $tempFile) {
            Write-Info "运行安装程序..."
            Start-Process msiexec.exe -ArgumentList "/i `"$tempFile`" /qn" -Wait

            # 清理
            Remove-Item $tempFile -Force -ErrorAction SilentlyContinue

            # 刷新环境变量
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

            Write-Success "Node.js 安装完成"
            return $true
        }
    } catch {
        Write-Error "下载失败: $_"
    }

    return $false
}

function Install-NpmPackages {
    param([string[]]$Packages)

    if (-not (Test-Command "npm")) {
        Write-Error "npm 未安装"
        return $false
    }

    foreach ($pkg in $Packages) {
        Write-Step "安装 $pkg..."
        npm install -g $pkg 2>&1 | Out-Null

        if ($LASTEXITCODE -eq 0) {
            Write-Success "$pkg 安装成功"
        } else {
            Write-Error "$pkg 安装失败"
            return $false
        }
    }

    return $true
}

function Set-NpmMirror {
    param([string]$Mirror = "https://registry.npmmirror.com")

    Write-Step "配置 npm 镜像: $Mirror"
    npm config set registry $Mirror
    Write-Success "npm 镜像配置完成"
}

function Install-Git {
    Write-Step "检查 Git..."

    if (Test-Command "git") {
        $version = git --version
        Write-Success "Git 已安装: $version"
        return $true
    }

    if (Test-Command "winget") {
        Write-Info "使用 winget 安装 Git..."

        $result = winget install Git.Git --accept-source-agreements --accept-package-agreements -e 2>&1

        if ($LASTEXITCODE -eq 0) {
            Write-Success "Git 安装成功"

            # 刷新环境变量
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            Start-Sleep -Seconds 2

            return $true
        }
    }

    Write-Error "Git 安装失败，请手动安装: https://git-scm.com/download/win"
    return $false
}
