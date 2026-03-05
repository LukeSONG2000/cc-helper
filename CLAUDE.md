# cc-helper

> 此文件是 cc-helper 的主入口。运行 `claude` 后，Claude 会读取此文件并引导你完成配置。

---

## 行为指令

### 当用户打招呼或没有明确需求时

使用 AskUserQuestion 提供三个选项供用户勾选：

- 配置助手 - 配置提示音、远程控制、API 模型等
- Claude Code 使用帮助 - 常用命令、快捷键、技巧提示
- 更新 cc-helper - 更新到最新版本

**如果用户勾选了"配置助手"**，进入二级菜单：
- 自定义提示音 - 当 Claude 完成或需要输入时播放声音
- 远程控制 - 通过 Happy CLI 远程控制 Claude
- 权限跳过 - 跳过命令确认，提高效率
- [ZAI] 模型配置 - GLM-4.7-Flash(Haiku)/GLM-4.7(Sonnet)/GLM-5(Opus)
- GitHub 配置 - Token 创建、MCP Git 服务

### 当用户明确说"帮我配置"时

使用 AskUserQuestion 工具，提供所有可配置选项供用户勾选：

```
- [ ] 自定义提示音 - 当 Claude 完成或需要输入时播放声音
- [ ] 远程控制 - 通过 Happy CLI 远程控制 Claude
- [ ] 权限跳过 - 跳过命令确认，提高效率
- [ ] [ZAI] 模型配置 - GLM-4.7-Flash(Haiku)/GLM-4.7(Sonnet)/GLM-5(Opus)
- [ ] GitHub 配置 - Token 创建、MCP Git 服务
```

### 更新 cc-helper 功能

当用户选择"更新 cc-helper"时，执行以下步骤：

```bash
# 1. 获取远程更新信息
git fetch origin

# 2. 比较本地和远程的提交时间
LOCAL_TIME=$(git log -1 --format=%ct HEAD)
REMOTE_TIME=$(git log -1 --format=%ct origin/main)

# 3. 如果远程更新，执行拉取
if [ "$REMOTE_TIME" -gt "$LOCAL_TIME" ]; then
  echo "发现新版本，正在更新..."
  git pull origin main
else
  echo "已是最新版本"
fi
```

更新后告诉用户更新的内容（通过 `git log --oneline HEAD@{1}..HEAD` 查看）。

### [ZAI] 模型配置说明

配置完成后，告诉用户：

> **模型已配置完成！**
>
> | 模型 | 额度消耗 | 特点 | 使用场景 |
> |------|----------|------|----------|
> | GLM-4.7-Flash (Haiku) | 不消耗 | 快速响应 | 简单任务、快速问答 |
> | GLM-4.7 (Sonnet) | 消耗 | 性能平衡 | 日常开发、代码编写 |
> | GLM-5 (Opus) | 消耗 | 最强能力 | 复杂任务、架构设计 |
>
> **切换模型**：使用 `/model` 命令选择模型
> - 默认使用 Opus (GLM-5)
> - 如果遇到速率限制，可切换到 Sonnet (GLM-4.7)

### /terminal-setup 使用说明

运行 `/terminal-setup` 可以配置终端集成：
- 将 `claude` 命令添加到终端
- 配置终端快捷键支持

---

## 配置选项详情

### 工具类（为 CC 提供能力）
- [Claude Code Notifications](tools/claude-code-notifications/README.md) - 自定义提示音
- [Happy CLI](tools/happy-cli/README.md) - 远程控制

### 配置类（CC 配置文件修改）
- [基础配置](configs/settings.md) - 权限跳过、API 设置、Hooks
- [GitHub 配置](configs/github/README.md) - Token 创建、MCP Git 服务

### 其他文档
- [工具索引](docs/tools.md) - 工具快速链接
- [常见问题](docs/faq.md) - 问题排查、使用技巧

---

## 文档结构

```
cc-helper/
├── CLAUDE.md                    # 主入口（本文件）
├── README.md                    # 使用说明
├── tools/                       # 工具类
│   ├── claude-code-notifications/  # 通知系统
│   └── happy-cli/                  # 远程控制
├── configs/                     # 配置类
│   ├── settings.md              # 基础配置说明
│   └── github/                  # GitHub 配置
└── docs/                        # 其他文档
    ├── tools.md                 # 工具索引
    └── faq.md                   # 常见问题
```
