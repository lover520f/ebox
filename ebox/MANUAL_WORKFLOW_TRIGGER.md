# 🚀 手动触发 GitHub Actions 工作流指南

## ⚠️ 为什么需要手动触发？

由于 GitHub Actions 默认可能不会自动触发标签推送，我们需要手动触发工作流。

---

## 📝 方式 1: GitHub 网页触发（最简单）

### 步骤 1: 访问 Actions 页面

打开浏览器访问：
```
https://github.com/lover520f/ebox/actions
```

### 步骤 2: 选择工作流

点击左侧列表中的：
- **Windows Build and Release**

### 步骤 3: 运行工作流

1. 点击右上角 **"Run workflow"** 按钮
2. 在弹出窗口中：
   - **Branch**: 选择 `master`
   - **Version**: 输入 `v1.0.0`
3. 点击绿色 **"Run workflow"** 按钮

### 步骤 4: 等待完成

- ⏱️ 预计时间：10-15 分钟
- 实时查看日志
- 完成后自动跳转 Release

---

## 📝 方式 2: 使用 GitHub CLI 触发

### 1. 安装 GitHub CLI

```bash
# Linux (Debian/Ubuntu)
sudo apt-get install gh

# macOS
brew install gh

# Windows
winget install GitHub.cli
```

### 2. 登录 GitHub

```bash
gh auth login
```

### 3. 触发工作流

```bash
cd /workspace/ebox
gh workflow run build-windows.yml --field version=v1.0.0
```

### 4. 查看状态

```bash
gh run watch
```

---

## 📝 方式 3: 使用 curl 触发

### 1. 生成 Personal Access Token

1. 访问：https://github.com/settings/tokens
2. 点击 "Generate new token"
3. 勾选权限：`repo`, `workflow`
4. 生成并复制 token

### 2. 设置环境变量

```bash
export GITHUB_TOKEN=你的 token 在这里
```

### 3. 触发工作流

```bash
curl -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  https://api.github.com/repos/lover520f/ebox/actions/workflows/build-windows.yml/dispatches \
  -d '{"ref":"master","inputs":{"version":"v1.0.0"}}'
```

---

## 📝 方式 4: 重新推送标签

有时重新推送标签可以触发：

```bash
cd /workspace/ebox

# 删除标签
git tag -d v1.0.0

# 重新推送
git push origin v1.0.0 --force
```

---

## ✅ 验证是否触发成功

### 检查方法 1: Actions 页面

访问：https://github.com/lover520f/ebox/actions

**成功标志：**
- ✅ 看到 "Windows Build and Release" 正在运行
- ✅ 进度条显示
- ✅ 日志开始输出

### 检查方法 2: GitHub 通知

- 查看 GitHub 右上角铃铛图标
- 应该看到 "Workflow run started" 通知

---

## 🔍 故障排查

### 问题 1: 没有看到 Run workflow 按钮

**原因**: 工作流可能没有正确配置

**解决方法:**
1. 检查工作流文件是否存在
2. 确认文件路径：`.github/workflows/build-windows.yml`
3. 检查工作流语法

### 问题 2: 工作流触发后立即失败

**检查:**
1. 查看错误日志
2. 检查 Flutter 版本配置
3. 确认依赖是否完整

### 问题 3: 标签推送不触发

**原因:** GitHub 可能不会为 force push 触发

**解决方法:** 使用手动触发（方式 1）

---

## 🎯 当前状态

| 项目 | 状态 |
|------|------|
| 工作流文件 | ✅ 已创建 |
| v1.0.0 标签 | ✅ 已推送 |
| 自动触发 | ⚠️ 可能未激活 |
| 手动触发 | ✅ 立即可用 |

---

## 🚀 立即手动触发！

**最简单方式：**

1. **打开**: https://github.com/lover520f/ebox/actions
2. **点击**: "Windows Build and Release"
3. **点击**: "Run workflow"
4. **选择**: v1.0.0
5. **等待**: 10-15 分钟

**完成！** 🎉

---

**最后更新**: 2026-06-03 19:15
