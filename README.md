# E 宝盒 (ebox)

Hills 风格 Emby 客户端，支持 Android 和 Windows 平台。

## 功能

- 🎨 Hills 风格 UI（紫色 #6C5CE7 → 蓝色 #00CEC9 渐变）
- 📱 Android APK
- 💻 Windows 便携版 EXE
- 🎬 Emby 电影/剧集浏览
- ▶️ 视频播放
- ⭐ 收藏管理

## 本地构建

### Android
```bash
cd client
flutter pub get
flutter build apk --release
```

### Windows
```bash
cd client
flutter pub get
flutter build windows --release
```

## 自动发布

1. 推送代码：
```bash
git push origin master
```

2. 创建版本标签：
```bash
git tag v1.0.1
git push origin v1.0.1
```

3. GitHub Actions 将自动构建并发布到 Releases

## 下载

访问 [Releases](https://github.com/lover520f/ebox/releases) 下载最新版本。
