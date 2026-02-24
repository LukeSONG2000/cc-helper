# Claude Code 环境配置

---

## 一、镜像配置（中国大陆）

### 1.1 npm 镜像

**临时使用：**
```bash
npm install <package> --registry=https://registry.npmmirror.com
```

**永久配置：**
```bash
npm config set registry https://registry.npmmirror.com
```

**恢复官方源：**
```bash
npm config set registry https://registry.npmjs.org
```

**查看当前源：**
```bash
npm config get registry
```

### 1.2 常用镜像源

| 镜像 | 地址 |
|------|------|
| 淘宝 npm | `https://registry.npmmirror.com` |
| 腾讯 npm | `https://mirrors.cloud.tencent.com/npm/` |
| 华为 npm | `https://mirrors.huawei.com/npm/` |

### 1.3 pnpm 镜像（如使用 pnpm）

```bash
pnpm config set registry https://registry.npmmirror.com
```

### 1.4 yarn 镜像（如使用 yarn）

```bash
yarn config set registry https://registry.npmmirror.com
```

---

## 二、Docker 安装

### 2.1 Ubuntu/Debian (WSL2)

```bash
# 更新包索引
sudo apt-get update

# 安装依赖
sudo apt-get install ca-certificates curl gnupg

# 添加 Docker 官方 GPG 密钥
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 添加仓库（使用阿里云镜像）
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装 Docker
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 启动服务
sudo service docker start

# 验证安装
sudo docker run hello-world
```

### 2.2 Docker 镜像加速（中国大陆）

创建或编辑 `/etc/docker/daemon.json`：

```json
{
  "registry-mirrors": [
    "https://docker.1panel.live",
    "https://hub.rat.dev",
    "https://docker.chenby.cn",
    "https://docker.m.daocloud.io"
  ]
}
```

重启 Docker：
```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 2.3 常用 Docker 镜像源

| 镜像源 | 地址 |
|--------|------|
| DaoCloud | `https://docker.m.daocloud.io` |
| 1Panel | `https://docker.1panel.live` |
| Rat.dev | `https://hub.rat.dev` |
| Chenby | `https://docker.chenby.cn` |

---

## 三、Node.js 安装

### 3.1 使用 nvm（推荐）

```bash
# 安装 nvm（使用镜像）
curl -o- https://ghproxy.com/https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# 或使用 gitee 镜像
git clone https://gitee.com/mirrors/nvm.git ~/.nvm

# 加载 nvm
source ~/.bashrc

# 设置 Node.js 镜像
export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node/

# 安装 LTS 版本
nvm install --lts
nvm use --lts
```

### 3.2 使用 nrm 管理 npm 源

```bash
# 安装 nrm
npm install -g nrm --registry=https://registry.npmmirror.com

# 查看可用源
nrm ls

# 切换源
nrm use taobao

# 测试速度
nrm test
```

---

## 四、Git 配置

### 4.1 GitHub 镜像加速

```bash
# 使用 ghproxy 加速
git clone https://ghproxy.com/https://github.com/user/repo.git

# 或使用 gitclone.com
git clone https://gitclone.com/github.com/user/repo.git
```

### 4.2 常用 GitHub 镜像

| 镜像 | 用法 |
|------|------|
| ghproxy | `https://ghproxy.com/https://github.com/...` |
| gitclone | `https://gitclone.com/github.com/...` |
| fastgit | `https://hub.fastgit.xyz/...` |

---

## 更新日志

| 日期 | 内容 |
|------|------|
| 2026-02-21 | 初始化环境配置文档 |
