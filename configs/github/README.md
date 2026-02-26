# GitHub 配置指南

---

## 一、Git 基本配置

### 1.1 设置用户信息

```bash
git config --global user.name "你的用户名"
git config --global user.email "你的邮箱"
```

### 1.2 验证配置

```bash
git config --global --list
```

---

## 二、创建 GitHub Token

### 2.1 进入设置页面

1. 登录 GitHub
2. 点击头像 → **Settings**
3. 左侧菜单最下方 → **Developer settings**
4. 点击 **Personal access tokens** → **Tokens (classic)**
5. 点击 **Generate new token (classic)**

### 2.2 配置 Token

| 字段 | 值 |
|------|------|
| Note | `Claude Code` |
| Expiration | 建议 90 天 |
| Select scopes | 见下方 |

### 2.3 权限说明

| 权限 | 用途 | 推荐 |
|------|------|------|
| `repo` | 完整仓库访问 | ✅ 必选 |
| `workflow` | GitHub Actions | ✅ 推荐 |
| `write:packages` | 发布包 | 按需 |
| `read:packages` | 下载包 | 按需 |
| `admin:org` | 组织管理 | ⚠️ 高风险 |

**最简配置**：只勾选 `repo` 即可完成基本操作。

### 2.4 保存 Token

**重要**：Token 只显示一次，请立即复制保存。

---

## 三、配置环境变量

### 3.1 Windows

```powershell
# 临时设置（当前会话）
set GITHUB_TOKEN=your_token_here

# 永久设置（用户级别）
[Environment]::SetEnvironmentVariable("GITHUB_TOKEN", "your_token_here", "User")
```

### 3.2 Linux/macOS

```bash
# 临时设置
export GITHUB_TOKEN=your_token_here

# 永久设置（添加到 shell 配置）
echo 'export GITHUB_TOKEN="your_token_here"' >> ~/.bashrc
source ~/.bashrc
```

---

## 四、配置 MCP Git 服务

### 4.1 安装 Git MCP Server

```bash
npm install -g git-mcp-server
```

### 4.2 添加 MCP 配置

在 `~/.claude/settings.json` 中添加：

```json
{
  "mcpServers": {
    "git": {
      "command": "npx",
      "args": ["-y", "git-mcp-server"]
    }
  }
}
```

### 4.3 Windows 额外配置

Windows 用户需要设置 Git Bash 路径：

```powershell
setx CLAUDE_CODE_GIT_BASH_PATH "C:\Program Files\Git\bin\bash.exe"
```

---

## 五、GitHub 镜像加速（中国大陆）

### 5.1 克隆加速

```bash
# ghproxy
git clone https://ghproxy.com/https://github.com/user/repo.git

# gitclone
git clone https://gitclone.com/github.com/user/repo.git
```

### 5.2 常用镜像

| 镜像 | 地址 |
|------|------|
| ghproxy | `https://ghproxy.com/https://github.com/...` |
| gitclone | `https://gitclone.com/github.com/...` |
| fastgit | `https://hub.fastgit.xyz/...` |

---

## 六、安全提示

1. **Token 安全**
   - 不要在公开代码中硬编码 Token
   - 定期更换 Token
   - 不再使用的 Token 立即删除

2. **权限最小化**
   - 只勾选必需的权限
   - 避免勾选 `admin:org`、`delete_repo` 等高风险权限

3. **定期检查**
   - 定期查看 https://github.com/settings/tokens
   - 删除不需要的 Token

---

## 更新日志

| 日期 | 内容 |
|------|------|
| 2026-02-24 | 初始化 GitHub 配置文档 |
