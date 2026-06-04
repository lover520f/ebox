# E 宝盒 (ebox)

> 跨平台媒体中心应用 - 支持 Emby 服务器和本地媒体播放

[![GitHub release](https://img.shields.io/github/release/lover520f/ebox.svg)](https://github.com/lover520f/ebox/releases)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Android%20%7C%20iOS-blue)](https://github.com/lover520f/ebox)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)](https://flutter.dev)
[![License](https://img.shields.io/github/license/lover520f/ebox.svg)](LICENSE)

## 🎨 产品特色

### 精美设计
- Hills 风格深色主题
- 紫蓝色渐变点缀
- 流畅的交互动画
- 响应式布局

### 强大功能
- ✅ 连接 Emby 媒体服务器
- ✅ 本地视频播放
- ✅ 播放进度记忆
- ✅ 倍速播放
- ✅ 字幕支持（开发中）
- ✅ 画质选择（开发中）

### 跨平台支持
- 💻 Windows 10/11
- 📱 Android (即将推出)
- 📱 iOS (即将推出)
- 📺 Android TV (规划中)

## 📥 下载安装

### Windows

1. 访问 [Releases](https://github.com/lover520f/ebox/releases)
2. 下载最新版本 `ebox-v1.0.0-windows.zip`
3. 解压到任意目录
4. 双击运行 `ebox_client.exe`

**系统要求:**
- Windows 10 64 位及以上
- 4GB+ RAM
- 500MB 可用存储空间

## 🚀 快速开始

### 1. 连接 Emby 服务器

1. 启动 E 宝盒
2. 点击"开始使用"
3. 点击"添加服务器"（右上角 + 号）
4. 填写服务器信息:
   - 服务器地址：`http://IP 地址：8096`
   - 服务器名称：（可选）
   - 用户名/密码：（如果有）
5. 点击"测试连接"
6. 保存并连接

### 2. 浏览媒体库

1. 在主页点击任意媒体库
2. 浏览电影/电视剧海报墙
3. 点击海报查看详情
4. 点击"播放"开始观看

### 3. 播放本地视频

1. 底部导航栏点击"本地"
2. 选择包含视频的文件夹
3. 自动扫描视频文件
4. 点击任意视频播放

## 🛠️ 开发指南

### 环境要求

- Flutter SDK 3.x
- Dart 3.x
- Visual Studio 2022 (Windows)
- Android Studio (Android)
- Xcode (iOS)

### 克隆项目

```bash
git clone https://github.com/lover520f/ebox.git
cd ebox/client
```

### 安装依赖

```bash
flutter pub get
```

### 运行应用

```bash
# Windows
flutter run -d windows

# Android
flutter run -d android

# macOS
flutter run -d macos
```

### 打包发布

```bash
# Windows
flutter build windows --release

# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

## 📚 项目结构

```
ebox/
├── client/                   # Flutter 客户端
│   ├── lib/
│   │   ├── main.dart         # 应用入口
│   │   ├── app.dart          # 应用配置
│   │   ├── config/           # 配置 (主题、路由)
│   │   ├── models/           # 数据模型
│   │   ├── services/         # 服务层 (API、存储)
│   │   ├── providers/        # 状态管理
│   │   ├── pages/            # 页面
│   │   └── widgets/          # 组件
│   ├── assets/               # 资源文件
│   ├── test/                 # 测试
│   └── pubspec.yaml          # 依赖配置
├── server/                   # Go 服务端 (规划中)
├── docs/                     # 文档
└── README.md                 # 本文件
```

## 🎯 功能路线图

### 第一阶段 (MVP) - ✅ 已完成
- [x] Emby 服务器连接
- [x] 媒体库浏览
- [x] 视频播放器
- [x] 本地媒体播放
- [x] 播放进度记忆

### 第二阶段 (v1.1) - 开发中
- [ ] 字幕加载和切换
- [ ] 画质选择
- [ ] 搜索功能
- [ ] 播放列表
- [ ] Android 移动端

### 第三阶段 (v1.2) - 规划中
- [ ] iOS 版本
- [ ] 音频/有声书
- [ ] 电子书阅读
- [ ] 多设备同步

### 第四阶段 (v2.0) - 规划中
- [ ] Android TV 版本
- [ ] 漫画阅读
- [ ] 服务端实现
- [ ] 元数据自动抓取

## 🤝 贡献

欢迎贡献代码！请遵循以下步骤：

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📝 变更日志

### v1.0.0 (2026-06-03)
- 🎉 首次发布
- ✨ Emby 服务器连接功能
- ✨ 本地媒体播放
- ✨ 精美的 UI 设计
- 🐛 已知问题已记录

## ❓ 常见问题

### Q: 连接不上 Emby 服务器怎么办？
**A:** 请检查:
1. 服务器地址是否正确
2. 服务器是否在线
3. 网络是否通畅
4. 防火墙设置

### Q: 播放卡顿怎么办？
**A:** 尝试:
1. 降低画质（功能开发中）
2. 使用本地播放
3. 检查网络速度

### Q: 如何反馈问题？
**A:** 在 [Issues](https://github.com/lover520f/ebox/issues) 中提交问题

## 📄 开源协议

本项目采用 MIT 协议 - 详见 [LICENSE](LICENSE) 文件

## 🙏 鸣谢

- [Flutter](https://flutter.dev) - 跨平台 UI 框架
- [Emby](https://emby.media) - 媒体服务器
- [Video Player](https://pub.dev/packages/video_player) - 视频播放插件

## 📮 联系方式

- 项目地址：https://github.com/lover520f/ebox
- 问题反馈：https://github.com/lover520f/ebox/issues

---

**Made with ❤️ by MonkeyCode AI**  
**Last Updated**: 2026-06-03
