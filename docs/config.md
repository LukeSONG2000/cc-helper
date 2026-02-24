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

## 四、完整配置示例

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
  "hooks": {
    "Notification": [{
      "hooks": [{
        "type": "command",
        "command": "paplay /usr/share/sounds/freedesktop/stereo/message.oga"
      }]
    }],
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "paplay /usr/share/sounds/freedesktop/stereo/complete.oga"
      }]
    }]
  }
}
```

---

## 更新日志

| 日期 | 内容 |
|------|------|
| 2026-02-21 | 初始化配置文档 |
