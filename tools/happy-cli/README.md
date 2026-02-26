# Happy CLI (Claude Code On the Go)

**项目地址**：https://github.com/slopus/happy-cli

**功能**：让 Claude Code 支持远程控制，可以从手机或其他设备继续会话。

---

## 安装方式

```bash
# 使用 npm 镜像（中国大陆推荐）
npm install -g happy-coder --registry=https://registry.npmmirror.com
```

---

## 认证配置

```bash
happy auth
```

按提示完成认证登录。

---

## 常用命令

| 命令 | 说明 |
|------|------|
| `happy` | 启动会话（支持远程控制） |
| `happy auth` | 管理认证 |
| `happy doctor` | 系统诊断 |
| `happy daemon` | 管理后台服务 |
| `happy notify` | 发送推送通知 |
| `happy --yolo` | 跳过权限模式启动 |

---

## 诊断命令

遇到问题时运行：
```bash
happy doctor
```

会显示：
- 版本信息
- 认证状态
- 守护进程状态
- 日志位置

---

## 配置目录

- 配置目录：`~/.happy/`
- 日志目录：`~/.happy/logs/`
- 服务地址：`https://api.cluster-fluster.com`
