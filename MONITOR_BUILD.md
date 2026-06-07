# 监控自动构建状态

## 方式 1: GitHub Actions 页面（推荐）

访问：https://github.com/lover520f/ebox/actions

你将看到名为 "Build & Release" 的工作流正在运行：

```
✓ Build & Release
  → v6.0.0-alpha - 运行中...
```

### 构建流程

1. **build-windows** (预期时间：5-8 分钟)
   - Setup Flutter
   - Get Flutter Dependencies
   - Build Windows
   - Package Windows Release
   - Upload Windows Artifact

2. **build-android** (预期时间：8-12 分钟)
   - Setup Flutter
   - Setup Java
   - Get Flutter Dependencies
   - Build Android Mobile APK
   - Build Android TV APK
   - Rename APKs
   - Upload Artifacts

3. **create-release** (所有构建完成后，约 1-2 分钟)
   - Download Windows Build
   - Download Mobile APK
   - Download TV APK
   - Create GitHub Release (Draft)

## 方式 2: GitHub CLI（如已安装）

```bash
gh run watch
```

## 构建产物

成功完成后，你会在 Release 页面看到:
https://github.com/lover520f/ebox/releases

**Draft Release** 包含：
- ✅ `ebox-windows-v6.0.0-alpha.zip`
- ✅ `ebox-mobile-v6.0.0-alpha.apk`
- ✅ `ebox-tv-v6.0.0-alpha.apk`

## 预期时间

| 阶段 | 时间 |
|------|------|
| Windows 构建 | 5-8 分钟 |
| Android 构建 | 8-12 分钟 |
| 创建 Release | 1-2 分钟 |
| **总计** | **约 15-20 分钟** |

## 注意事项

### 首次构建
- 需要下载 Flutter SDK 和依赖，可能较慢
- Android 构建需要下载 Gradle 和 Android SDK

### 失败处理
如果构建失败：
1. 点击失败的 Job 查看详细日志
2. 常见问题：
   - 依赖下载超时 → 重试
   - 签名配置缺失 → APK 可能无签名
   - 磁盘空间不足 → 清理 runner

### 发布 Release
当前配置为 **Draft Release**，需要手动：
1. 访问 Release 页面
2. 编辑发布说明
3. 点击 "Publish release"

---

**提示**: 你可以在 GitHub 仓库的 Actions 标签页设置通知，构建完成会收到邮件。
