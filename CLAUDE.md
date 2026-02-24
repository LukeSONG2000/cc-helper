# Claude Code Helper - 配置入口

> 此文件是 Claude Code 配置助手的主入口。运行 `claude` 后，Claude 会读取此文件并引导你完成配置。

## 快速开始

告诉 Claude：**"帮我配置 Claude Code"**，然后选择你需要的项目。

---

## 配置选项

### 1. 基础配置
- [配置文件](docs/config.md) - 权限跳过、API 设置等
- [环境变量](docs/environment.md) - Docker、Node.js 等环境配置

### 2. 工具安装
- [工具列表](docs/tools.md) - 通知系统、快捷命令等

### 3. 答疑解惑
- [常见问题](docs/faq.md) - 问题排查、使用技巧

---

## 更新日志

| 日期 | 内容 | 文档 |
|------|------|------|
| 2026-02-21 | 添加 Happy CLI 远程控制工具 | [tools.md](docs/tools.md) |
| 2026-02-21 | 添加 Claude Code 通知系统 | [tools.md](docs/tools.md) |
| 2026-02-21 | 初始化配置文档系统 | - |

---

## 文档结构

```
cc-helper/
├── CLAUDE.md          # 主入口（本文件）
├── README.md          # 安装指导
├── docs/
│   ├── config.md      # 配置说明
│   ├── tools.md       # 工具安装
│   ├── environment.md # 环境配置
│   └── faq.md         # 常见问题
└── scripts/           # 脚本文件
```
