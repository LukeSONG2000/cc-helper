# Claude Code 工具安装

---

## 已安装工具

### 1. Claude Code Notifications (通知系统)

**项目地址**：https://github.com/dongzhenye/claude-code-notifications/

**功能**：当 Claude 完成回复或需要输入时播放提示音，让你不会错过响应。

#### 安装方式

**方式一：自动安装（推荐）**
```bash
curl -sSL https://raw.githubusercontent.com/dongzhenye/claude-code-notifications/main/install.sh | bash
```

**方式二：手动安装**

1. 克隆仓库：
```bash
git clone https://github.com/dongzhenye/claude-code-notifications.git
cd claude-code-notifications
```

2. 复制配置文件到 Claude 设置：

**Linux:**
```bash
cp recommended/recommended.linux.json ~/.claude/settings.json
```

**macOS:**
```bash
cp recommended/recommended.macos.json ~/.claude/settings.json
```

**Windows:**
```powershell
cp recommended/recommended.windows.json $env:USERPROFILE\.claude\settings.json
```

#### 配置说明

配置会添加以下 hooks：

| 事件 | 触发时机 | 声音 (Linux) |
|------|----------|--------------|
| `Notification` | Claude 需要你的输入 | `message.oga` |
| `Stop` | Claude 完成响应 | `complete.oga` |

#### 测试声音

```bash
# Linux
paplay /usr/share/sounds/freedesktop/stereo/message.oga
paplay /usr/share/sounds/freedesktop/stereo/complete.oga

# macOS
afplay /System/Library/Sounds/Glass.aiff
afplay /System/Library/Sounds/Tink.aiff

# Windows (PowerShell)
[System.Media.SystemSounds]::Asterisk.Play()
```

---

### 2. Happy CLI (Claude Code On the Go)

**项目地址**：https://github.com/slopus/happy-cli

**功能**：让 Claude Code 支持远程控制，可以从手机或其他设备继续会话。

#### 安装方式

```bash
# 使用 npm 镜像（中国大陆推荐）
npm install -g happy-coder --registry=https://registry.npmmirror.com

# 或使用淘宝镜像
npm install -g happy-coder --registry=https://registry.npm.taobao.org
```

#### 认证配置

```bash
happy auth
```

按提示完成认证登录。

#### 常用命令

| 命令 | 说明 |
|------|------|
| `happy` | 启动会话（支持远程控制） |
| `happy auth` | 管理认证 |
| `happy doctor` | 系统诊断 |
| `happy daemon` | 管理后台服务 |
| `happy notify` | 发送推送通知 |
| `happy --yolo` | 跳过权限模式启动 |

#### 诊断命令

遇到问题时运行：
```bash
happy doctor
```

会显示：
- 版本信息
- 认证状态
- 守护进程状态
- 日志位置

#### 配置目录

- 配置目录：`~/.happy/`
- 日志目录：`~/.happy/logs/`
- 服务地址：`https://api.cluster-fluster.com`

---

## 待安装工具

> 此区域记录计划安装但尚未配置的工具。

- [ ] 暂无

---

## 更新日志

| 日期 | 内容 |
|------|------|
| 2026-02-21 | 添加 Happy CLI 远程控制工具 |
| 2026-02-21 | 添加 Claude Code Notifications 通知系统 |
