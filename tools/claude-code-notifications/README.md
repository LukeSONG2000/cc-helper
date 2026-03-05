# Claude Code Notifications

**项目地址**：https://github.com/dongzhenye/claude-code-notifications

**功能**：当 Claude 完成回复或需要输入时播放提示音，让你不会错过响应。

---

## 配置选项

### 自定义音效（推荐）

使用项目自带的提示音文件：

| 事件 | 触发时机 | 声音 |
|------|----------|------|
| `Notification` | 需要输入时 | message.wav |
| `Stop` | 完成响应时 | complete.wav |

### 系统默认声音

使用系统默认提示音（无需额外文件）：

| 事件 | 触发时机 | 声音 |
|------|----------|------|
| `Notification` | 需要输入时 | Exclamation |
| `Stop` | 完成响应时 | Asterisk |

---

## 安装方式

### 方式一：自定义音效（推荐）

```bash
# 1. 复制工具文件到 Claude 配置目录
mkdir -p ~/.claude/tools/claude-code-notifications
cp -r tools/claude-code-notifications/* ~/.claude/tools/claude-code-notifications/

# 2. 将配置合并到 settings.json
# Windows: 将 configs/custom.windows.json 中的 hooks 部分添加到 settings.json
# Linux:   将 configs/custom.linux.json 中的 hooks 部分添加到 settings.json
# macOS:   将 configs/custom.macos.json 中的 hooks 部分添加到 settings.json
```

### 方式二：系统默认声音

直接使用系统声音，无需额外文件：

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

## 文件结构

```
claude-code-notifications/
├── README.md                    # 本文档
├── sounds/                      # 音效文件
│   ├── message.wav              # 通知提示音
│   ├── message.oga              # 通知提示音（Linux 原始）
│   ├── complete.wav             # 完成提示音
│   └── complete.oga             # 完成提示音（Linux 原始）
├── configs/                     # 配置文件
│   ├── custom.windows.json      # Windows 自定义配置（推荐）
│   ├── custom.linux.json        # Linux 自定义配置（推荐）
│   ├── custom.macos.json        # macOS 自定义配置（推荐）
│   ├── recommended.windows.json # Windows 官方推荐
│   ├── recommended.linux.json   # Linux 官方推荐
│   └── recommended.macos.json   # macOS 官方推荐
└── play-sound.ps1               # Windows 声音播放脚本
```

---

## 测试声音

```bash
# Windows（在 Terminal/Git Bash 中）
powershell.exe -c "(New-Object Media.SoundPlayer 'C:/Users/YOUR_USERNAME/.claude/tools/claude-code-notifications/sounds/message.wav').PlaySync()"

# Linux
paplay /usr/share/sounds/freedesktop/stereo/message.oga

# macOS
afplay ~/.claude/tools/claude-code-notifications/sounds/message.oga
```

---

## 自定义声音

替换 `sounds/` 目录下的文件即可使用自己的提示音：

- `message.wav` - 通知提示音（需要输入时）
- `complete.wav` - 完成提示音（任务完成时）

建议使用短促、清晰的提示音，时长不超过 2 秒。

---

## 注意事项

### Windows Terminal / Git Bash 用户

由于 hooks 在 bash 环境中执行，需要注意：

1. **路径格式**：使用正斜杠 `/` 而非反斜杠 `\`
2. **引号格式**：PowerShell 命令需要用双引号包裹，内部路径用单引号

正确示例：
```json
"command": "powershell.exe -c \"(New-Object Media.SoundPlayer 'C:/Users/xxx/sounds/complete.wav').PlaySync()\""
```

### 各平台支持

- **Windows**: 使用 wav 格式，原生支持
- **Linux**: 直接使用系统音效 `/usr/share/sounds/freedesktop/stereo/`
- **macOS**: 使用 oga 格式，需要 afplay 支持
