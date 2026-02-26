# Claude Code Helper - 配置入口

> 此文件是 Claude Code 配置助手的主入口。运行 `claude` 后，Claude 会读取此文件并引导你完成配置。

## 一键安装

在纯净系统上执行一条命令即可完成安装：

| 系统 | 命令 |
|------|------|
| Windows | `irm https://raw.githubusercontent.com/LukeSONG2000/cc-helper/main/scripts/install.ps1 \| iex` |
| Linux/macOS | `curl -fsSL https://raw.githubusercontent.com/LukeSONG2000/cc-helper/main/scripts/install.sh \| bash` |

安装器将自动：
- 检测系统环境
- 安装 Git、Node.js 等依赖
- 安装 Claude Code
- 引导配置 API Key

---

## 快速开始

告诉 Claude：**"帮我配置 Claude Code"**，然后选择你需要的项目。

---

## 配置选项

### 1. 工具类（为 CC 提供能力）
- [Claude Code Notifications](tools/claude-code-notifications/README.md) - 自定义提示音
- [Happy CLI](tools/happy-cli/README.md) - 远程控制

### 2. 配置类（CC 配置文件修改）
- [基础配置](configs/settings.md) - 权限跳过、API 设置、Hooks
- [GitHub 配置](configs/github/README.md) - Token 创建、MCP Git 服务

### 3. 其他文档
- [工具安装](docs/tools.md) - Happy CLI 等外部工具
- [环境配置](docs/environment.md) - Docker、Node.js、镜像源
- [常见问题](docs/faq.md) - 问题排查、使用技巧

---

## 更新日志

| 日期 | 内容 | 文档 |
|------|------|------|
| 2026-02-26 | 重构项目结构，添加自定义提示音 | [tools/](tools/) |
| 2026-02-24 | 添加一键安装脚本 | [scripts/](scripts/) |
| 2026-02-21 | 添加 Happy CLI 远程控制工具 | [docs/tools.md](docs/tools.md) |
| 2026-02-21 | 添加 Claude Code 通知系统 | [tools/](tools/) |
| 2026-02-21 | 初始化配置文档系统 | - |

---

## 文档结构

```
cc-helper/
├── CLAUDE.md                    # 主入口（本文件）
├── README.md                    # 安装指导
├── tools/                       # 工具类（为 CC 提供能力）
│   ├── claude-code-notifications/  # 通知系统
│   │   ├── README.md               # 项目说明
│   │   ├── sounds/                 # 声音文件
│   │   └── configs/                # 配置文件
│   └── happy-cli/                  # 远程控制
│       └── README.md               # 项目说明
├── configs/                     # 配置类（CC 配置文件修改）
│   ├── settings.md              # 基础配置说明
│   └── github/                  # GitHub 配置
│       └── README.md
├── docs/                        # 其他文档
│   ├── environment.md           # 环境配置
│   └── faq.md                   # 常见问题
└── scripts/                     # 安装脚本
    ├── install.ps1              # Windows 安装入口
    ├── install.sh               # Linux/macOS 安装入口
    └── modules/                 # 功能模块
```
