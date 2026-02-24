#!/bin/bash
# common.sh - Linux/macOS 公共函数库

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
RESET='\033[0m'

# 日志文件
LOG_FILE="/tmp/claude-code-install.log"
INSTALLED_PACKAGES=()

# 输出函数
log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

step() {
    echo -e "${CYAN}[*]${RESET} $1"
    log "STEP: $1"
}

success() {
    echo -e "${GREEN}[OK]${RESET} $1"
    log "SUCCESS: $1"
}

warn() {
    echo -e "${YELLOW}[!]${RESET} $1"
    log "WARNING: $1"
}

error() {
    echo -e "${RED}[X]${RESET} $1"
    log "ERROR: $1"
}

info() {
    echo -e "${BLUE}[i]${RESET} $1"
    log "INFO: $1"
}

# 检测命令是否存在
command_exists() {
    command -v "$1" &> /dev/null
}

# 获取系统信息
get_system_info() {
    local os_type="Unknown"
    local os_version=""

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [[ -f /etc/os-release ]]; then
            . /etc/os-release
            os_type="$NAME"
            os_version="$VERSION_ID"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        os_type="macOS"
        os_version=$(sw_vers -productVersion)
    fi

    local arch=$(uname -m)
    [[ "$arch" == "x86_64" ]] && arch="x64"
    [[ "$arch" == "aarch64" ]] && arch="arm64"

    echo "OS=$os_type"
    echo "VERSION=$os_version"
    echo "ARCH=$arch"
    echo "HAS_CURL=$(command_exists curl && echo 'true' || echo 'false')"
    echo "HAS_WGET=$(command_exists wget && echo 'true' || echo 'false')"
    echo "HAS_GIT=$(command_exists git && echo 'true' || echo 'false')"
    echo "HAS_NODE=$(command_exists node && echo 'true' || echo 'false')"
    echo "HAS_NVM=$(command_exists nvm && echo 'true' || echo 'false')"
    echo "NODE_VERSION=$(command_exists node && node --version || echo '')"
    echo "PACKAGE_MANAGER=$(detect_package_manager)"
}

detect_package_manager() {
    if command_exists apt-get; then
        echo "apt"
    elif command_exists yum; then
        echo "yum"
    elif command_exists dnf; then
        echo "dnf"
    elif command_exists pacman; then
        echo "pacman"
    elif command_exists brew; then
        echo "brew"
    else
        echo "unknown"
    fi
}

# 显示标题
show_header() {
    local title="$1"
    local width=54
    local padding=$(( ($width - ${#title} - 2) / 2 ))

    echo ""
    echo -e "${CYAN}$(printf '═%.0s' $(seq 1 $width))${RESET}"
    printf "${CYAN}║${RESET}%*s${BOLD}%s${RESET}%*s${CYAN}║${RESET}\n" $padding "" "$title" $padding ""
    echo -e "${CYAN}$(printf '═%.0s' $(seq 1 $width))${RESET}"
    echo ""
}

# 进度条
show_progress() {
    local current=$1
    local total=$2
    local label="$3"
    local percent=$(( current * 100 / total ))
    local filled=$(( percent / 5 ))
    local empty=$(( 20 - filled ))

    printf "\r%s [%s%s] %d%%" "$label" \
        "$(printf '█%.0s' $(seq 1 $filled))" \
        "$(printf '░%.0s' $(seq 1 $empty))" \
        "$percent"

    [[ $current -eq $total ]] && echo ""
}

# 回滚信息
show_rollback_info() {
    if [[ ${#INSTALLED_PACKAGES[@]} -gt 0 ]]; then
        echo ""
        warn "以下软件包已安装，如需回滚请手动卸载："
        for pkg in "${INSTALLED_PACKAGES[@]}"; do
            echo "  - $pkg"
        done
    fi
    echo ""
    info "安装日志: $LOG_FILE"
}

# 生成 Claude Code 配置
generate_claude_settings() {
    local api_provider="$1"
    local api_key="$2"
    local skip_permissions="$3"
    local github_token="$4"
    local enable_notifications="$5"
    local use_npm_mirror="$6"

    local claude_dir="$HOME/.claude"
    mkdir -p "$claude_dir"

    local settings_file="$claude_dir/settings.json"

    # 构建配置
    cat > "$settings_file" << 'SETTINGS_EOF'
{
SETTINGS_EOF

    # API 配置
    if [[ "$api_provider" == "zhipu" ]]; then
        cat >> "$settings_file" << EOF
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "$api_key",
    "ANTHROPIC_BASE_URL": "https://open.bigmodel.cn/api/anthropic",
    "API_TIMEOUT_MS": "3000000",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-5",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-5",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-5"
EOF
    else
        cat >> "$settings_file" << EOF
  "env": {
    "ANTHROPIC_API_KEY": "$api_key",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "claude-3-5-haiku-20241022",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "claude-sonnet-4-20250514",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "claude-opus-4-20250514"
EOF
    fi

    # GitHub Token
    if [[ -n "$github_token" ]]; then
        echo '    ,"GITHUB_TOKEN": "'"$github_token"'"' >> "$settings_file"
    fi

    echo '  }' >> "$settings_file"

    # 权限配置
    if [[ "$skip_permissions" == "true" ]]; then
        cat >> "$settings_file" << 'EOF'
  ,"permissions": {
    "defaultMode": "bypassPermissions"
  }
  ,"skipDangerousModePermissionPrompt": true
EOF
    fi

    # 通知配置
    if [[ "$enable_notifications" == "true" ]]; then
        cat >> "$settings_file" << 'EOF'
  ,"hooks": {
    "Notification": [{
      "hooks": [{
        "type": "command",
        "command": "paplay /usr/share/sounds/freedesktop/stereo/message.oga 2>/dev/null || afplay /System/Library/Sounds/Ping.aiff 2>/dev/null || true"
      }]
    }],
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null || afplay /System/Library/Sounds/Hero.aiff 2>/dev/null || true"
      }]
    }]
  }
EOF
    fi

    echo "}" >> "$settings_file"

    # npm 镜像
    if [[ "$use_npm_mirror" == "true" ]]; then
        npm config set registry https://registry.npmmirror.com 2>/dev/null
    fi

    echo "$settings_file"
}

# 安装基础工具
install_base_tools() {
    local pm="$1"

    step "安装基础工具..."

    case "$pm" in
        apt)
            sudo apt update
            sudo apt install -y curl git build-essential
            ;;
        yum|dnf)
            sudo "$pm" install -y curl git gcc-c++ make
            ;;
        pacman)
            sudo pacman -Sy --noconfirm curl git base-devel
            ;;
        brew)
            brew install curl git
            ;;
    esac

    INSTALLED_PACKAGES+=("curl" "git")
}

# 安装 nvm
install_nvm() {
    step "安装 nvm..."

    if [[ -d "$HOME/.nvm" ]]; then
        success "nvm 已安装"
        return 0
       fi

    local nvm_version="v0.39.7"
    local install_url="https://raw.githubusercontent.com/nvm-sh/nvm/$nvm_version/install.sh"

    # 尝试使用镜像
    if [[ "$USE_MIRROR" == "true" ]]; then
        install_url="https://ghproxy.com/$install_url"
    fi

    curl -o- "$install_url" | bash

    # 加载 nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    if command_exists nvm; then
        success "nvm 安装成功"
        INSTALLED_PACKAGES+=("nvm")
        return 0
    else
        error "nvm 安装失败"
        return 1
    fi
}

# 安装 Node.js
install_nodejs() {
    step "安装 Node.js..."

    if command_exists node; then
        local version=$(node --version)
        success "Node.js 已安装: $version"
        return 0
    fi

    # 使用 nvm 安装
    if command_exists nvm; then
        nvm install --lts
        nvm use --lts
        INSTALLED_PACKAGES+=("nodejs")
        return 0
    fi

    # 使用包管理器安装
    local pm=$(detect_package_manager)
    case "$pm" in
        apt)
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
            sudo apt install -y nodejs
            ;;
        yum|dnf)
            curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
            sudo "$pm" install -y nodejs
            ;;
        pacman)
            sudo pacman -Sy --noconfirm nodejs npm
            ;;
        brew)
            brew install node
            ;;
        *)
            error "不支持的包管理器: $pm"
            return 1
            ;;
    esac

    INSTALLED_PACKAGES+=("nodejs")
    success "Node.js 安装成功"
}

# 安装 Git
install_git() {
    step "检查 Git..."

    if command_exists git; then
        local version=$(git --version)
        success "Git 已安装: $version"
        return 0
    fi

    local pm=$(detect_package_manager)
    case "$pm" in
        apt)
            sudo apt update
            sudo apt install -y git
            ;;
        yum|dnf)
            sudo "$pm" install -y git
            ;;
        pacman)
            sudo pacman -Sy --noconfirm git
            ;;
        brew)
            brew install git
            ;;
    esac

    INSTALLED_PACKAGES+=("git")
    success "Git 安装成功"
}

# 配置 npm 镜像
set_npm_mirror() {
    local mirror="${1:-https://registry.npmmirror.com}"
    step "配置 npm 镜像: $mirror"
    npm config set registry "$mirror"
    success "npm 镜像配置完成"
}

# 安装 Claude Code
install_claude_code() {
    step "安装 @anthropic-ai/claude-code..."

    if ! command_exists npm; then
        error "npm 未安装"
        return 1
    fi

    npm install -g @anthropic-ai/claude-code

    if [[ $? -eq 0 ]]; then
        success "Claude Code 安装成功"
        return 0
    else
        error "Claude Code 安装失败"
        return 1
    fi
}
