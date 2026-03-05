# Claude Code Helper - 配置入口

> 此文件是 Claude Code 配置助手的主入口。运行 `claude` 后，Claude 会读取此文件并引导你完成配置。

---

## 快速开始

告诉 Claude：**"帮我配置"**，然后选择你需要的项目。

---

## 配置选项

### 1. 工具类（为 CC 提供能力）
- [Claude Code Notifications](tools/claude-code-notifications/README.md) - 自定义提示音
- [Happy CLI](tools/happy-cli/README.md) - 远程控制

### 2. 配置类（CC 配置文件修改）
- [基础配置](configs/settings.md) - 权限跳过、API 设置、Hooks
- [GitHub 配置](configs/github/README.md) - Token 创建、MCP Git 服务

### 3. 其他文档
- [工具索引](docs/tools.md) - 工具快速链接
- [常见问题](docs/faq.md) - 问题排查、使用技巧

---

## 文档结构

```
cc-helper/
├── CLAUDE.md                    # 主入口（本文件）
├── README.md                    # 使用说明
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
└── docs/                        # 其他文档
    ├── tools.md                 # 工具索引
    └── faq.md                   # 常见问题
```
