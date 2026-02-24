#!/bin/bash
#
# Claude Code 一键安装器 for Linux/macOS
#
# 用法:
#   curl -fsSL https://raw.githubusercontent.com/LukeSONG2000/cc-helper/main/scripts/install.sh | bash
#
# 参数:
#   --non-interactive    非交互模式
#   --api-key KEY        API Key
#   --api-provider PROVIDER  API 提供商 (zhipu/anthropic)
#   --skip-permissions   跳过权限确认
#   --use-mirror         使用镜像加速
#   --help               显示帮助
#

set -e

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载模块
source "$SCRIPT_DIR/modules/common.sh"
source "$SCRIPT_DIR/modules/node.sh"
source "$SCRIPT_DIR/modules/config.sh"

# 显示帮助
show_help() {
    cat << 'EOF'
Claude Code 一键安装器

用法:
  curl -fsSL https://raw.githubusercontent.com/LukeSONG2000/cc-helper/main/scripts/install.sh | bash

参数:
  --non-interactive       非交互模式，使用默认配置
  --api-key KEY          API Key
  --api-provider PROVIDER    API 提供商 (zhipu/anthropic)
  --skip-permissions     跳过权限确认
  --use-mirror           使用镜像加速
  --help                 显示帮助

示例:
  # 交互式安装
  curl -fsSL https://raw.githubusercontent.com/LukeSONG2000/cc-helper/main/scripts/install.sh | bash

  # 非交互式安装
  curl -fsSL ... | bash -s -- --non-interactive --api-key YOUR_KEY
EOF
    exit 0
}

# 解析命令行参数
parse_args() {
    NON_INTERACTIVE="false"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --non-interactive)
                NON_INTERACTIVE="true"
                shift
                ;;
            --api-key)
                API_KEY="$2"
                shift 2
                ;;
            --api-provider)
                API_PROVIDER="$2"
                shift 2
                ;;
            --skip-permissions)
                SKIP_PERMISSIONS="true"
                shift
                ;;
            --use-mirror)
                USE_NPM_MIRROR="true"
                USE_MIRROR="true"
                shift
                ;;
            --help|-h)
                show_help
                ;;
            *)
                error "未知参数: $1"
                exit 1
                ;;
        esac
    done
}

# 主安装流程
main() {
    # 显示欢迎信息
    show_header "Claude Code 一键安装器"

    # 系统检测
    step "检测系统信息..."
    eval $(get_system_info)

    echo -e "  操作系统:   ${GREEN}$OS $VERSION${RESET}"
    echo -e "  架构:       ${GREEN}$ARCH${RESET}"
    echo -e "  包管理器:   ${GREEN}$PACKAGE_MANAGER${RESET}"
    echo -e "  Git:        $(if [[ "$HAS_GIT" == "true" ]]; then echo "${GREEN}已安装${RESET}"; else echo "${YELLOW}未安装${RESET}"; fi)"
    echo -e "  Node.js:    $(if [[ "$HAS_NODE" == "true" ]]; then echo "${GREEN}$NODE_VERSION${RESET}"; else echo "${YELLOW}未安装${RESET}"; fi)"
    echo ""

    # 检查必要工具
    if [[ "$HAS_CURL" != "true" ]] && [[ "$HAS_WGET" != "true" ]]; then
        error "需要 curl 或 wget，请先安装"
        exit 1
    fi

    # 交互式配置
    if [[ "$NON_INTERACTIVE" != "true" ]]; then
        run_interactive_config
    else
        run_non_interactive_config
    fi

    # 开始安装
    echo ""
    show_header "开始安装"

    local steps=5

    # 1. 安装基础工具
    show_progress 0 $steps "安装依赖"
    install_base_tools "$PACKAGE_MANAGER"

    # 2. 安装 Git
    show_progress 1 $steps "安装依赖"
    install_git

    # 3. 安装 Node.js
    show_progress 2 $steps "安装依赖"

    # 在 Linux 上优先安装 nvm
    if [[ "$OSTYPE" == "linux-gnu"* ]] && [[ "$HAS_NVM" != "true" ]] && [[ ! -d "$HOME/.nvm" ]]; then
        install_nvm
    fi

    install_nodejs

    if ! command_exists node; then
        error "Node.js 安装失败"
        show_rollback_info
        exit 1
    fi

    # 4. 配置 npm 镜像
    show_progress 3 $steps "配置环境"
    if [[ "$USE_NPM_MIRROR" == "true" ]]; then
        set_npm_mirror
    fi

    # 5. 安装 Claude Code
    show_progress 4 $steps "安装 Claude Code"
    install_claude_code

    if [[ $? -ne 0 ]]; then
        error "Claude Code 安装失败"
        show_rollback_info
        exit 1
    fi

    show_progress 5 $steps "安装完成"

    # 生成配置文件
    step "生成配置文件..."
    local settings_path=$(generate_claude_settings \
        "$API_PROVIDER" \
        "$API_KEY" \
        "$SKIP_PERMISSIONS" \
        "$GITHUB_TOKEN" \
        "$ENABLE_NOTIFICATIONS" \
        "$USE_NPM_MIRROR")

    success "配置文件已保存: $settings_path"

    # 完成
    echo ""
    show_header "安装完成"

    echo -e "${GREEN}Claude Code 已成功安装！${RESET}"
    echo ""
    echo "使用方法:"
    echo -e "  ${CYAN}claude${RESET}          启动 Claude Code"
    echo -e "  ${CYAN}claude --help${RESET}    查看帮助"
    echo ""

    # 提示 nvm 刷新
    if [[ -d "$HOME/.nvm" ]] && ! command_exists nvm; then
        warn "nvm 已安装，建议运行以下命令或重启终端："
        echo -e "  ${CYAN}source ~/.bashrc${RESET}  # 或 source ~/.zshrc"
    fi

    echo -e "配置文件: ${CYAN}$settings_path${RESET}"
    echo -e "安装日志: ${CYAN}$LOG_FILE${RESET}"
    echo ""
}

# 错误处理
trap 'error "安装失败，行号: $LINENO"; show_rollback_info; exit 1' ERR

# 入口
parse_args "$@"
main
