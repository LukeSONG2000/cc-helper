# Claude Code 常见问题

---

## 一、安装问题

### Q1: npm install 速度很慢或失败？

**解决方案**：使用国内镜像

```bash
npm install -g @anthropic-ai/claude-code --registry=https://registry.npmmirror.com
```

或永久配置：
```bash
npm config set registry https://registry.npmmirror.com
```

### Q2: WSL2 中没有声音？

**解决方案**：WSL2 通过 WSLg 支持 PulseAudio 音频

1. 确认 WSLg 正在运行：
```bash
pactl info
```

2. 测试声音：
```bash
paplay /usr/share/sounds/freedesktop/stereo/complete.oga
```

3. 检查 Windows 音频输出设备（耳机/扬声器）是否正常

### Q3: GitHub 仓库克隆失败？

**解决方案**：使用镜像加速

```bash
# 方式一：ghproxy
git clone https://ghproxy.com/https://github.com/user/repo.git

# 方式二：gitclone
git clone https://gitclone.com/github.com/user/repo.git
```

---

## 二、使用问题

### Q4: Claude 总是询问权限确认？

**解决方案**：配置跳过权限

在 `~/.claude/settings.json` 中添加：
```json
{
  "permissions": {
    "defaultMode": "bypassPermissions"
  },
  "skipDangerousModePermissionPrompt": true
}
```

或启动时使用：
```bash
claude --dangerously-skip-permissions
```

### Q5: 如何重命名对话？

**解决方案**：在对话中输入
```
/rename 对话名称
```

### Q6: 如何继续之前的对话？

**解决方案**：
```bash
# 继续最近的对话
claude --continue

# 选择历史对话
claude --resume
```

### Q7: 对话历史太多，如何清理？

**解决方案**：
```bash
# 查看历史会话
claude --resume

# 在会话中压缩历史
/compact
```

---

## 三、API 问题

### Q8: API 连接超时？

**解决方案**：增加超时时间

在 `~/.claude/settings.json` 中：
```json
{
  "env": {
    "API_TIMEOUT_MS": "3000000"
  }
}
```

### Q9: 如何切换不同的 API？

**解决方案**：修改 `ANTHROPIC_BASE_URL`

智谱 AI：
```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://open.bigmodel.cn/api/anthropic"
  }
}
```

官方 Anthropic：
```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.anthropic.com"
  }
}
```

---

## 四、Happy CLI 问题

### Q10: Happy 提示 ECONNREFUSED 127.0.0.1:7890？

**原因**：系统代理配置指向了未运行的代理服务

**解决方案**：检查并清除代理设置

```bash
# 检查环境变量
env | grep -i proxy

# 临时清除（当前会话）
unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ALL_PROXY

# 检查 shell 配置文件
grep -i proxy ~/.bashrc ~/.zshrc ~/.profile
```

### Q11: Happy daemon 没有运行？

**解决方案**：
```bash
# 检查状态
happy doctor

# 启动 daemon
happy daemon start
```

### Q12: Happy 无法在 Claude 会话中运行？

**原因**：不允许嵌套 Claude 会话

**解决方案**：在新的终端窗口中运行 `happy`

---

## 五、通知系统问题

### Q13: 通知声音不播放？

**排查步骤**：

1. 检查系统音量
2. 测试声音文件：
   ```bash
   # Linux
   paplay /usr/share/sounds/freedesktop/stereo/complete.oga

   # macOS
   afplay /System/Library/Sounds/Tink.aiff
   ```
3. 检查配置文件：
   ```bash
   cat ~/.claude/settings.json | grep -A 20 hooks
   ```

### Q14: 播放多个重复声音？

**解决方案**：

1. 清除终端铃声配置：
   ```bash
   claude config set --global preferredNotifChannel none
   ```

2. 检查是否有重复的 hooks 配置

---

## 命令速查表

| 命令 | 说明 |
|------|------|
| `claude` | 启动交互式会话 |
| `claude --continue` | 继续上次对话 |
| `claude --resume` | 选择历史会话 |
| `claude --dangerously-skip-permissions` | 跳过权限模式 |
| `/help` | 查看帮助 |
| `/clear` | 清空对话 |
| `/compact` | 压缩对话历史 |
| `/rename <名称>` | 重命名对话 |
| `/cost` | 查看消耗统计 |
| `/model` | 切换模型 |
| `/permissions` | 管理权限 |
| `/pr-comments` | 查看 PR 评论 |

---

## 更新日志

| 日期 | 内容 |
|------|------|
| 2026-02-21 | 初始化 FAQ 文档 |
