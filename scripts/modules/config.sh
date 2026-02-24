#!/bin/bash
# config.sh - 配置生成模块

# 配置选项
API_PROVIDER="zhipu"
API_KEY=""
SKIP_PERMISSIONS="true"
GITHUB_TOKEN=""
ENABLE_NOTIFICATIONS="false"
USE_NPM_MIRROR="true"
USE_MIRROR="true"

# 交互式菜单选择
read_menu_selection() {
    local title="$1"
    shift
    local options=("$@")
    local selected=0
    local count=${#options[@]}

    # 隐藏光标
    tput civis 2>/dev/null

    # 保存当前光标位置
    tput sc 2>/dev/null

    while true; do
        # 恢复光标位置
        tput rc 2>/dev/null

        # 清除下方内容
        tput ed 2>/dev/null

        # 显示标题
        echo -e "${CYAN}$(printf '─%.0s' {1..54})${RESET}"
        echo -e "${CYAN}│${RESET} ${BOLD}$title${RESET}"
        echo -e "${CYAN}$(printf '─%.0s' {1..54})${RESET}"

        # 显示选项
        for i in "${!options[@]}"; do
            if [[ $i -eq $selected ]]; then
                echo -e "${GREEN}► ${options[$i]}${RESET}"
            else
                echo -e "  ${options[$i]}"
            fi
        done

        echo ""
        echo -e "${CYAN}↑↓ 选择  │  Enter 确认${RESET}"

        # 读取按键
        read -rsn1 key
        case "$key" in
            A|k)  # 上
                ((selected--))
                [[ $selected -lt 0 ]] && selected=$((count - 1))
                ;;
            B|j)  # 下
                ((selected++))
                [[ $selected -ge $count ]] && selected=0
                ;;
            "")   # Enter
                break
                ;;
            q)    # Quit
                selected=-1
                break
                ;;
        esac

        # 处理转义序列 (方向键)
        if [[ "$key" == $'\x1b' ]]; then
            read -rsn2 -t 0.1 key
            case "$key" in
                '[A') ((selected--)); [[ $selected -lt 0 ]] && selected=$((count - 1)) ;;
                '[B') ((selected++)); [[ $selected -ge $count ]] && selected=0 ;;
            esac
        fi
    done

    # 显示光标
    tput cnorm 2>/dev/null

    return $selected
}

# 复选框菜单
show_checkbox_menu() {
    local title="$1"
    shift
    local options=()
    local checked=()

    # 解析参数
    while [[ $# -gt 0 ]]; do
        options+=("$1")
        checked+=("$2")
        shift 2
    done

    local selected=0
    local count=${#options[@]}

    tput civis 2>/dev/null
    tput sc 2>/dev/null

    while true; do
        tput rc 2>/dev/null
        tput ed 2>/dev/null

        echo -e "${CYAN}$(printf '─%.0s' {1..54})${RESET}"
        echo -e "${CYAN}│${RESET} ${BOLD}$title${RESET}"
        echo -e "${CYAN}$(printf '─%.0s' {1..54})${RESET}"

        for i in "${!options[@]}"; do
            local check=" "
            [[ "${checked[$i]}" == "true" ]] && check="${GREEN}X${RESET}"

            if [[ $i -eq $selected ]]; then
                echo -e "${YELLOW}►${RESET} [${check}] ${options[$i]}"
            else
                echo -e "  [${check}] ${options[$i]}"
            fi
        done

        echo ""
        echo -e "${CYAN}↑↓ 选择  │  Space 切换  │  Enter 确认${RESET}"

        read -rsn1 key

        case "$key" in
            A|k)
                ((selected--))
                [[ $selected -lt 0 ]] && selected=$((count - 1))
                ;;
            B|j)
                ((selected++))
                [[ $selected -ge $count ]] && selected=0
                ;;
            " ")
                if [[ "${checked[$selected]}" == "true" ]]; then
                    checked[$selected]="false"
                else
                    checked[$selected]="true"
                fi
                ;;
            "")
                break
                ;;
        esac

        if [[ "$key" == $'\x1b' ]]; then
            read -rsn2 -t 0.1 key
            case "$key" in
                '[A') ((selected--)); [[ $selected -lt 0 ]] && selected=$((count - 1)) ;;
                '[B') ((selected++)); [[ $selected -ge $count ]] && selected=0 ;;
            esac
        fi
    done

    tput cnorm 2>/dev/null

    # 返回选中状态
    echo "${checked[@]}"
}

# 交互式配置
run_interactive_config() {
    show_header "Claude Code 配置助手"

    # 1. 选择 API 提供商
    echo -e "\n${BOLD}[1/4] 选择 API 提供商${RESET}"
    local api_options=(
        "智谱 AI (GLM-5) - 推荐，国内直连"
        "Anthropic 官方 - 需要代理"
    )
    read_menu_selection "选择 API 提供商" "${api_options[@]}"
    local api_choice=$?

    if [[ $api_choice -eq 0 ]]; then
        API_PROVIDER="zhipu"
    else
        API_PROVIDER="anthropic"
    fi

    # 2. 输入 API Key
    echo -e "\n${BOLD}[2/4] 输入 API Key${RESET}"

    if [[ "$API_PROVIDER" == "zhipu" ]]; then
        echo -e "请访问 ${CYAN}https://open.bigmodel.cn${RESET} 获取 API Key"
    else
        echo -e "请访问 ${CYAN}https://console.anthropic.com${RESET} 获取 API Key"
    fi

    echo ""
    read -p "API Key: " API_KEY

    if [[ -z "$API_KEY" ]]; then
        error "API Key 不能为空"
        exit 1
    fi

    # 3. 权限模式
    echo -e "\n${BOLD}[3/4] 权限模式${RESET}"
    local perm_options=(
        "跳过权限确认 (推荐) - 更流畅的体验"
        "标准模式 - 每次操作需确认"
    )
    read_menu_selection "权限模式" "${perm_options[@]}"
    local perm_choice=$?

    SKIP_PERMISSIONS="true"
    [[ $perm_choice -eq 1 ]] && SKIP_PERMISSIONS="false"

    # 4. 可选配置
    echo -e "\n${BOLD}[4/4] 可选配置${RESET}"

    local optional_options=(
        "配置 GitHub Token"
        "安装通知系统"
        "配置 npm 镜像加速"
    )
    local optional_defaults=("false" "false" "true")

    local result=$(show_checkbox_menu \
        "可选配置" \
        "${optional_options[0]}" "${optional_defaults[0]}" \
        "${optional_options[1]}" "${optional_defaults[1]}" \
        "${optional_options[2]}" "${optional_defaults[2]}")

    # 解析结果
    read -ra checked_values <<< "$result"

    if [[ "${checked_values[0]}" == "true" ]]; then
        echo ""
        read -p "GitHub Token (可选，直接回车跳过): " GITHUB_TOKEN
    fi

    ENABLE_NOTIFICATIONS="${checked_values[1]}"
    USE_NPM_MIRROR="${checked_values[2]}"

    # 确认配置
    show_header "配置确认"

    local provider_name="Anthropic 官方"
    [[ "$API_PROVIDER" == "zhipu" ]] && provider_name="智谱 AI (GLM-5)"

    local perm_name="标准模式"
    [[ "$SKIP_PERMISSIONS" == "true" ]] && perm_name="跳过确认"

    local mirror_name="未启用"
    [[ "$USE_NPM_MIRROR" == "true" ]] && mirror_name="已启用 (npmmirror.com)"

    local notify_name="未启用"
    [[ "$ENABLE_NOTIFICATIONS" == "true" ]] && notify_name="已启用"

    echo -e "API 提供商:   ${GREEN}$provider_name${RESET}"
    echo -e "API Key:      ${GREEN}${API_KEY:0:8}...${RESET}"
    echo -e "权限模式:     ${GREEN}$perm_name${RESET}"
    echo -e "npm 镜像:     ${GREEN}$mirror_name${RESET}"
    echo -e "通知系统:     ${GREEN}$notify_name${RESET}"
    echo ""

    local confirm_options=("开始安装" "取消")
    read_menu_selection "确认安装" "${confirm_options[@]}"
    local confirm=$?

    if [[ $confirm -ne 0 ]]; then
        echo -e "\n${YELLOW}安装已取消${RESET}"
        exit 0
    fi
}

# 非交互式配置
run_non_interactive_config() {
    if [[ -z "$API_KEY" ]]; then
        error "非交互模式需要提供 --api-key 参数"
        exit 1
    fi
}
