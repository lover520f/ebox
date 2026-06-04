# 🌥️ GitHub Actions 云端自动打包发布指南

## 🎯 自动打包发布流程

我已经创建了 GitHub Actions 工作流，可以直接在 GitHub 云端完成打包和发布！

---

## ⚡ 快速开始

### 方式 1: 推送标签自动触发 (推荐)

```bash
# 在本地执行
git tag v1.0.0
git push origin v1.0.0
```

**效果**: 
- ✅ GitHub Actions 自动启动
- ✅ 云端构建 Windows 版本
- ✅ 自动创建 GitHub Release
- ✅ 自动上传便携版 (.zip)

### 方式 2: 手动触发工作流

1. 访问：https://github.com/lover520f/ebox/actions
2. 点击 "Windows Build and Release" 工作流
3. 点击 "Run workflow" 按钮
4. 填写版本号（如 `v1.0.0`）
5. 点击 "Run workflow"
6. 等待约 10-15 分钟
7. 查看 Release 页面

---

## 📋 工作流详解

### 自动执行步骤

```yaml
1. 检出代码 → GitHub 仓库代码
2. 设置 Flutter → 安装 Flutter 3.x
3. 安装依赖 → flutter pub get
4. 构建 Windows → flutter build windows --release
5. 创建 ZIP 包 → 便携版压缩包
6. 创建 Release → GitHub Releases 页面
7. 上传文件 → 自动上传到 Release
```

### 工作时间

- **Fluttter 安装**: ~3 分钟
- **依赖安装**: ~2 分钟
- **构建编译**: ~5-8 分钟
- **打包上传**: ~1 分钟
- **总计**: 约 10-15 分钟

---

## 🔍 查看构建进度

### 实时查看日志

1. 访问：https://github.com/lover520f/ebox/actions
2. 点击正在运行的工作流
3. 查看每个步骤的输出
4. 等待 "发布完成" 步骤

### 构建成功后

- ✅ 自动创建 Release
- ✅ 上传 `ebox-v1.0.0-portable.zip`
- ✅ 发布说明自动生成

---

## 📦 下载已发布的版本

构建完成后访问：

```
https://github.com/lover520f/ebox/releases/tag/v1.0.0
```

点击Assets 中的 `ebox-v1.0.0-portable.zip` 下载！

---

## ⚙️ 工作流配置说明

### 触发条件

**自动触发**:
```yaml
on:
  push:
    tags:
      - 'v*'  # 推送 v 开头的标签时触发
```

**手动触发**:
```yaml
workflow_dispatch:
  inputs:
    version:
      description: '版本号'
      default: 'v1.0.0'
```

### 运行环境

```yaml
runs-on: windows-latest  # Windows Server 2022
```

### Flutter 配置

```yaml
flutter-version: '3.x'  # 稳定版
channel: 'stable'
```

---

## 🎯 完整操作步骤

### 第一步：推送标签

```bash
# 确保所有代码已推送
git push origin master

# 推送版本标签
git tag v1.0.0
git push origin v1.0.0
```

### 第二步：等待自动构建

访问查看进度：
```
https://github.com/lover520f/ebox/actions
```

### 第三步：下载发布版本

构建完成后：
```
https://github.com/lover520f/ebox/releases/tag/v1.0.0
```

---

## 💡 提示

### 便携版特点
- ✅ 解压即用，无需安装
- ✅ 不写注册表
- ✅ 可放 U 盘随身携带
- ✅ 大小约 70-80MB

### 如果需要安装版

GitHub Actions 工作流目前仅生成便携版。如需安装版：

1. 下载便携版 ZIP
2. 在本地使用 Inno Setup 创建安装包
3. 手动上传到 Release

---

## 🔧 故障排查

### 构建失败？

1. **查看日志**
   - 访问 Actions 页面
   - 点击失败的工作流
   - 查看错误信息

2. **常见错误**
   - Flutter 版本不兼容 → 检查工作流配置
   - 依赖安装失败 → 检查 pubspec.yaml
   - 编译错误 → 查看代码错误信息

3. **重新运行**
   - 点击 "Re-run jobs" 按钮
   - 或修复问题后重新推送标签

### 工作流未触发？

1. 检查标签推送：
   ```bash
   git push origin v1.0.0 --force
   ```

2. 手动触发工作流（方式 2）

---

## 📊 工作流程状态

| 步骤 | 状态 |
|------|------|
| 工作流创建 | ✅ 已完成 |
| 等待触发 | ⏳ 等待中 |
| 云端构建 | ⏳ 等待中 |
| 打包发布 | ⏳ 等待中 |

---

## 🚀 现在开始！

```bash
# 推送标签，触发自动构建
git push origin v1.0.0
```

然后访问：
- Actions: https://github.com/lover520f/ebox/actions
- Releases: https://github.com/lover520f/ebox/releases

**10-15 分钟后，第一个 Windows 版本就会自动发布！** 🎉

---

**创建时间**: 2026-06-03  
**工作流**: `.github/workflows/build-windows.yml`
