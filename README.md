# Claude Code 配置助手

快速配置和复用 Claude Code 开发环境的文档集合。

---

## 一、安装 Claude Code

### 前置条件

1. **安装 Node.js** (v18+)

   ```bash
   # macOS/Linux (nvm)
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
   nvm install --lts

   # Windows (winget)
   winget install OpenJS.NodeJS.LTS

   # 验证安装
   node -v
   npm -v
   ```

2. **一键安装 Claude Code 小助手** (智谱 AI 方案)

   ```bash
   # 使用淘宝镜像（中国大陆推荐）
   npm install -g @anthropic-ai/claude-code --registry=https://registry.npmmirror.com
   ```

   参考文档：https://docs.bigmodel.cn/cn/coding-plan/extension/coding-tool-helper

---

## 二、配置 API

### 2.1 创建配置文件

```bash
mkdir -p ~/.claude
```

### 2.2 编辑 settings.json

创建 `~/.claude/settings.json`：

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "你的API密钥",
    "ANTHROPIC_BASE_URL": "https://open.bigmodel.cn/api/anthropic",
    "API_TIMEOUT_MS": "3000000",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-5",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-5",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-5"
  },
  "permissions": {
    "defaultMode": "bypassPermissions"
  },
  "skipDangerousModePermissionPrompt": true
}
```

> **获取 API Key**：访问 [智谱开放平台](https://open.bigmodel.cn/) 注册并获取密钥

### 2.3 验证安装

```bash
claude --version
claude
```

---

## 三、使用配置助手

安装完成后，进入本目录并启动 Claude：

```bash
cd /path/to/cc-helper
claude
```

然后告诉 Claude：**"帮我配置 Claude Code"**

Claude 会读取 `CLAUDE.md` 并引导你选择需要配置的项目。

---

## 四、目录结构

```
cc-helper/
├── CLAUDE.md          # Claude 入口文件
├── README.md          # 本文件 - 安装指导
├── docs/
│   ├── config.md      # 配置说明（权限、API等）
│   ├── tools.md       # 工具安装（通知系统等）
│   ├── environment.md # 环境配置（Docker等）
│   └── faq.md         # 常见问题解答
└── scripts/           # 辅助脚本
```

---

## 五、常用命令速查

| 命令 | 说明 |
|------|------|
| `claude` | 启动交互式会话 |
| `claude --continue` | 继续上次对话 |
| `claude --resume` | 选择历史会话 |
| `/rename <名称>` | 重命名当前对话 |
| `/help` | 查看帮助 |
| `/clear` | 清空对话 |
| `/compact` | 压缩对话历史 |

---

## 六、参考链接

- [Claude Code 官方文档](https://docs.anthropic.com/en/docs/claude-code)
- [智谱 AI 编码工具助手](https://docs.bigmodel.cn/cn/coding-plan/extension/coding-tool-helper)
- [Claude Code 通知系统](https://github.com/dongzhenye/claude-code-notifications)
