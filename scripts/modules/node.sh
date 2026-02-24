#!/bin/bash
# node.sh - Linux/macOS Node.js 安装模块

# Node.js 版本
NODE_LTS_VERSION="20"

# 使用 nvm 安装 Node.js
install_node_with_nvm() {
    step "使用 nvm 安装 Node.js LTS..."

    # 确保 nvm 已加载
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    if ! command_exists nvm; then
        error "nvm 未安装"
        return 1
    fi

    # 安装 LTS 版本
    nvm install --lts
    nvm use --lts
    nvm alias default node

    local version=$(node --version 2>/dev/null)
    if [[ -n "$version" ]]; then
        success "Node.js 安装成功: $version"
        return 0
    else
        error "Node.js 安装失败"
        return 1
    fi
}

# 使用包管理器安装 Node.js
install_node_with_pm() {
    local pm="$1"
    step "使用 $pm 安装 Node.js..."

    case "$pm" in
        apt)
            # 使用 NodeSource 仓库
            curl -fsSL https://deb.nodesource.com/setup_${NODE_LTS_VERSION}.x | sudo -E bash -
            sudo apt install -y nodejs
            ;;
        yum)
            curl -fsSL https://rpm.nodesource.com/setup_${NODE_LTS_VERSION}.x | sudo bash -
            sudo yum install -y nodejs
            ;;
        dnf)
            curl -fsSL https://rpm.nodesource.com/setup_${NODE_LTS_VERSION}.x | sudo bash -
            sudo dnf install -y nodejs
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

    local version=$(node --version 2>/dev/null)
    if [[ -n "$version" ]]; then
        success "Node.js 安装成功: $version"
        return 0
    else
        error "Node.js 安装失败"
        return 1
    fi
}

# 手动安装 Node.js (二进制)
install_node_binary() {
    step "手动安装 Node.js..."

    local arch=$(uname -m)
    [[ "$arch" == "x86_64" ]] && arch="x64"
    [[ "$arch" == "aarch64" ]] && arch="arm64"

    local version="20.11.0"
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    local filename="node-v${version}-${os}-${arch}.tar.gz"
    local url="https://nodejs.org/dist/v${version}/${filename}"

    # 使用镜像
    if [[ "$USE_MIRROR" == "true" ]]; then
        url="https://npmmirror.com/mirrors/node/v${version}/${filename}"
    fi

    local tmp_dir="/tmp/nodejs-install"
    mkdir -p "$tmp_dir"

    info "下载 $url..."
    curl -fsSL "$url" -o "$tmp_dir/$filename"

    if [[ $? -ne 0 ]]; then
        error "下载失败"
        return 1
    fi

    # 解压并安装
    tar -xzf "$tmp_dir/$filename" -C "$tmp_dir"
    local extracted_dir="$tmp_dir/node-v${version}-${os}-${arch}"

    # 移动到 /usr/local
    sudo cp -r "$extracted_dir"/* /usr/local/

    # 清理
    rm -rf "$tmp_dir"

    local version=$(node --version 2>/dev/null)
    if [[ -n "$version" ]]; then
        success "Node.js 安装成功: $version"
        return 0
    else
        error "Node.js 安装失败"
        return 1
    fi
}

# 主安装函数
install_nodejs() {
    # 检查是否已安装
    if command_exists node; then
        local version=$(node --version)
        success "Node.js 已安装: $version"
        return 0
    fi

    # 优先使用 nvm (推荐)
    if command_exists nvm || [[ -d "$HOME/.nvm" ]]; then
        install_node_with_nvm
        return $?
    fi

    # 使用包管理器
    local pm=$(detect_package_manager)
    if [[ "$pm" != "unknown" ]]; then
        install_node_with_pm "$pm"
        return $?
    fi

    # 手动安装
    install_node_binary
    return $?
}

# 安装 npm 全局包
install_npm_packages() {
    local packages=("$@")

    if ! command_exists npm; then
        error "npm 未安装"
        return 1
    fi

    for pkg in "${packages[@]}"; do
        step "安装 $pkg..."
        npm install -g "$pkg"

        if [[ $? -eq 0 ]]; then
            success "$pkg 安装成功"
        else
            error "$pkg 安装失败"
            return 1
        fi
    done

    return 0
}

# 安装 nvm (如果需要)
setup_nvm() {
    step "设置 nvm..."

    if [[ -d "$HOME/.nvm" ]]; then
        success "nvm 已存在"
        return 0
    fi

    local nvm_version="v0.39.7"
    local install_url="https://raw.githubusercontent.com/nvm-sh/nvm/$nvm_version/install.sh"

    # 使用镜像加速
    if [[ "$USE_MIRROR" == "true" ]]; then
        install_url="https://ghproxy.com/https://raw.githubusercontent.com/nvm-sh/nvm/$nvm_version/install.sh"
    fi

    info "下载 nvm 安装脚本..."
    curl -o- "$install_url" | bash

    # 添加到 shell 配置
    local shell_rc=""
    if [[ -n "$ZSH_VERSION" ]]; then
        shell_rc="$HOME/.zshrc"
    else
        shell_rc="$HOME/.bashrc"
    fi

    # 加载 nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    if command_exists nvm; then
        success "nvm 安装成功"
        info "请运行 'source $shell_rc' 或重新打开终端以启用 nvm"
        return 0
    else
        warn "nvm 安装完成，但需要重启终端"
        return 0
    fi
}
