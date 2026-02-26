# Claude Code 配置说明

---

## 一、权限配置

### 1.1 跳过权限确认（推荐）

在 `~/.claude/settings.json` 中添加：

```json
{
  "permissions": {
    "defaultMode": "bypassPermissions"
  },
  "skipDangerousModePermissionPrompt": true
}
```

**效果**：Claude 执行命令时不再频繁询问确认，提高效率。

### 1.2 使用 --dangerously-skip-permissions

临时以跳过权限模式启动：

```bash
claude --dangerously-skip-permissions
```

或在项目目录创建 `.claude/settings.local.json`：

```json
{
  "permissions": {
    "defaultMode": "bypassPermissions"
  }
}
```

---

## 二、API 配置

### 2.1 智谱 AI (GLM-5)

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
  }
}
```

### 2.2 官方 Anthropic API

```json
{
  "env": {
    "ANTHROPIC_API_KEY": "sk-ant-xxx",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "claude-3-5-haiku-20241022",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "claude-sonnet-4-20250514",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "claude-opus-4-20250514"
  }
}
```

---

## 三、配置文件位置

| 文件 | 位置 | 作用域 |
|------|------|--------|
| 全局配置 | `~/.claude/settings.json` | 所有项目 |
| 项目配置 | `.claude/settings.local.json` | 当前项目 |
| 企业策略 | `/etc/claude-code/policy.json` | 系统级（需管理员） |

**优先级**：项目配置 > 全局配置 > 企业策略

---

## 四、Hooks 配置（提示音）

Hooks 用于在特定事件时执行命令，常用于播放提示音。

### 4.1 安装通知工具

推荐使用 Freedesktop 音效配置，详见 [tools/claude-code-notifications](../tools/claude-code-notifications/README.md)。

### 4.2 快速配置

**Freedesktop 音效（推荐）**：
```bash
# 复制工具文件
cp -r tools/claude-code-notifications ~/.claude/tools/

# 将 configs/custom.*.json 中的 hooks 配置添加到 settings.json
```

**系统声音（无需额外文件）**：
```json
{
  "hooks": {
    "Notification": [{
      "hooks": [{
        "type": "command",
        "command": "powershell.exe -c \"[System.Media.SystemSounds]::Exclamation.Play()\""
      }]
    }],
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "powershell.exe -c \"[System.Media.SystemSounds]::Asterisk.Play()\""
      }]
    }]
  }
}
```

---

## 五、完整配置示例

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
    "defaultMode": "bypassPermissions",
    "allow": [
      "Bash(npm install:*)",
      "Bash(npm run:*)",
      "Read"
    ],
    "deny": []
  },
  "skipDangerousModePermissionPrompt": true,
  "mcpServers": {
    "git": {
      "command": "npx",
      "args": ["-y", "git-mcp-server"]
    }
  }
}
```

---

## 六、相关配置

| 配置 | 说明 |
|------|------|
| [GitHub 配置](github/README.md) | Token 创建、MCP Git 服务 |
| [通知工具](../tools/claude-code-notifications/README.md) | Freedesktop 提示音 |

---

## 更新日志

| 日期 | 内容 |
|------|------|
| 2026-02-26 | 添加 Hooks 配置说明，重构文档结构 |
| 2026-02-21 | 初始化配置文档 |
