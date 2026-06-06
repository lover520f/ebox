# E 宝盒 v5.0.0 构建说明

## 构建产物

本次发布包含三个独立版本，构建后生成以下文件：

### 1. Windows 版
**路径**: `client/build/windows/runner/Release/`
- `E 宝盒.exe` - 主程序
- `flutter_windows.dll` - Flutter 引擎
- `data/` - 应用数据
- **打包**: 将整个 Release 目录打包为 `ebox-windows-v5.0.0.zip`

### 2. Android Mobile 版
**路径**: `client/build/app/outputs/flutter-apk/`
- `app-mobile-release.apk` → 重命名为 `ebox-mobile-v5.0.0.apk`
- **签名**: 使用 release keystore 签名

### 3. Android TV 版
**路径**: `client/build/app/outputs/flutter-apk/`
- `app-tv-release.apk` → 重命名为 `ebox-tv-v5.0.0.apk`
- **签名**: 使用 release keystore 签名

### 4. Android App Bundle (可选)
**路径**: `client/build/app/outputs/bundle/release/`
- `app-release.aab` - 用于 Google Play 分发

---

## 构建步骤

### 前置条件
1. Flutter SDK 3.x 已安装
2. Android SDK 和 NDK 已配置
3. Windows 10 SDK (用于 Windows 构建)
4. 签名密钥（Android）

### Android 签名配置

在 `client/android/` 目录创建 `key.properties`:
```properties
storePassword=你的密钥库密码
keyPassword=密钥密码
keyAlias=上传
storeFile=/path/to/keystore.jks
```

### 构建命令

```bash
cd client

# 方式 1: 使用构建脚本
./build-all.sh

# 方式 2: 手动构建各个版本
# Windows
flutter build windows --release

# Android Mobile
flutter build apk --flavor mobile -t lib/main/main_mobile.dart --release

# Android TV
flutter build apk --flavor tv -t lib/main/main_tv.dart --release

# App Bundle
flutter build appbundle --release
```

---

## GitHub Release 发布步骤

1. 访问 https://github.com/lover520f/ebox/releases/new
2. Tag version: `v5.0.0`
3. Target: `master`
4. Release title: `E 宝盒 v5.0.0 - Hills 完整功能版`
5. 描述: 复制 RELEASE_NOTES_v5.0.0.md 内容
6. 上传构建产物:
   - `ebox-windows-v5.0.0.zip`
   - `ebox-mobile-v5.0.0.apk`
   - `ebox-tv-v5.0.0.apk`
7. 勾选 "Set as latest release"
8. 点击 "Publish release"

---

## 验证清单

### Windows 版
- [ ] 可在 Windows 10/11 正常运行
- [ ] 支持键盘快捷键
- [ ] 播放器正常工作
- [ ] 服务器连接正常

### Android Mobile
- [ ] APK 安装成功
- [ ] 触控手势正常
- [ ] 亮度/音量调节正常
- [ ] 横竖屏切换正常

### Android TV
- [ ] APK 安装到 TV
- [ ] 遥控器方向键导航
- [ ] 焦点管理正常
- [ ] 横屏显示正常

---

## 常见问题

### Q: Android 构建失败
A: 检查 `local.properties` 中 SDK 和 NDK 路径

### Q: Windows 构建失败
A: 确保已安装 Visual Studio 和 Windows 10 SDK

### Q: 签名失败
A: 检查 `key.properties` 路径和密码是否正确

---

**最后更新**: 2026-06-06
