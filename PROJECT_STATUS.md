# E 宝盒 v5.0.0 - 项目状态看板

## 📊 构建状态

### 当前触发
- **TAG**: v6.0.0-alpha
- **推送时间**: 2026-06-07
- **工作流**: Build & Release
- **状态**: 🏃 运行中

### 监控链接
- [GitHub Actions](https://github.com/lover520f/ebox/actions) - 实时构建日志
- [Releases](https://github.com/lover520f/ebox/releases) - 构建产物

---

## ✅ 已完成功能

### 核心功能
- [x] Hills 风格 UI 完整复刻
- [x] Emby API 完整集成
- [x] 媒体库浏览（电影/剧集）
- [x] 媒体详情页
- [x] 视频播放器
- [x] 字幕选择（多语言）
- [x] 音轨切换
- [x] 播放进度追踪
- [x] 本地媒体支持

### 平台特性

#### Windows PC ✅
- [x] 键盘快捷键
- [x] 全屏/窗口模式
- [x] ESC 退出
- [x] 播放控制

#### Android Mobile ✅
- [x] 触控手势
- [x] 亮度滑动
- [x] 音量滑动
- [x] 快进/退拖动
- [x] 双击播放/暂停

#### Android TV ✅
- [x] 遥控器导航
- [x] 焦点管理
- [x] 大尺寸 UI
- [x] 横屏显示
- [x] OK 键选中

---

## 🏗️ CI/CD 配置

### GitHub Actions 工作流

```yaml
触发条件:
  - push tags: v*
  - workflow_dispatch

构建任务:
  1. build-windows (Windows-latest)
  2. build-android (ubuntu-latest)
  3. create-release (自动发布)
```

### 构建产物

| 平台 | 文件 | 输出位置 |
|------|------|----------|
| Windows | `ebox-windows-v*.zip` | Release 附件 |
| Android Mobile | `ebox-mobile-v*.apk` | Release 附件 |
| Android TV | `ebox-tv-v*.apk` | Release 附件 |

---

## 📁 项目结构

```
/workspace/
├── client/
│   ├── lib/
│   │   ├── main/
│   │   │   ├── main_windows.dart
│   │   │   ├── main_mobile.dart
│   │   │   └── main_tv.dart
│   │   ├── config/
│   │   │   ├── flavors/app_flavor.dart
│   │   │   ├── theme.dart
│   │   │   └── routes.dart
│   │   ├── pages/
│   │   │   ├── home/
│   │   │   ├── media/
│   │   │   ├── playback/
│   │   │   └── local/
│   │   ├── services/
│   │   │   ├── emby_api_client.dart
│   │   │   ├── video_player_service.dart
│   │   │   ├── media_streams_service.dart
│   │   │   ├── local_media_service.dart
│   │   │   └── tv_remote_service.dart
│   │   └── widgets/
│   │       ├── media_card.dart
│   │       ├── advanced_player_controls.dart
│   │       ├── track_selection_panel.dart
│   │       ├── ios_gesture_overlay.dart
│   │       └── tv_navigation_view.dart
│   ├── .github/
│   │   └── workflows/build.yml
│   ├── pubspec.yaml
│   └── build-all.sh
├── RELEASE_NOTES_v5.0.0.md
├── BUILD_INSTRUCTIONS.md
└── MONITOR_BUILD.md
```

---

## 📋 测试清单

### Windows 测试
- [ ] 安装并启动
- [ ] 添加 Emby 服务器
- [ ] 浏览媒体库
- [ ] 播放视频
- [ ] 字幕切换
- [ ] 键盘快捷键

### Android Mobile 测试
- [ ] APK 安装
- [ ] 触控手势
- [ ] 亮度/音量调节
- [ ] 横竖屏切换
- [ ] 播放功能

### Android TV 测试
- [ ] TV 安装
- [ ] 遥控器导航
- [ ] 焦点高亮
- [ ] 播放控制
- [ ] 横屏显示

---

## 🚀 下一步计划

### v5.1.0 计划
- [ ] 离线下载
- [ ] 投屏功能 (Chromecast/DLNA)
- [ ] 多服务器同步
- [ ] 观看历史云同步

### v6.0.0 计划
- [ ] iOS 版本
- [ ] macOS 版本
- [ ] 智能推荐
- [ ] 家长控制

---

## 📞 支持

- **GitHub**: https://github.com/lover520f/ebox
- **Issues**: https://github.com/lover520f/ebox/issues
- **文档**: `/RELEASE_NOTES_v5.0.0.md`

---

**最后更新**: 2026-06-07  
**版本**: v5.0.0 (正式版)  
**状态**: 🎉 发布就绪
