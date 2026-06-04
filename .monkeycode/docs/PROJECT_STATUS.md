# E 宝盒 (ebox) 项目开发进度

## 项目概述
E 宝盒是一款跨平台媒体中心应用，支持 Emby 服务器和本地媒体库，提供视频、音频、电子书、漫画等多种媒体类型的播放和管理功能。

**技术栈**: Flutter (客户端) + Go (服务端)  
**目标平台**: Windows, Android, iOS, Android TV  
**当前阶段**: 第一阶段 MVP (Windows 桌面端 + 视频播放)

## 开发进度

### ✅ 已完成 (2026-06-03)

#### 1. 项目初始化
- [x] Flutter 客户端项目结构
- [x] Go 服务端项目结构
- [x] 依赖配置 (pubspec.yaml, go.mod)

#### 2. 核心架构
- [x] 主题系统 (Hills 风格深色主题)
- [x] 路由配置 (go_router)
- [x] 状态管理 (Provider)
- [x] 本地存储 (Hive)

#### 3. 数据模型
- [x] User (用户模型)
- [x] MediaLibrary (媒体库模型)
- [x] MediaItem (媒体项模型)
- [x] EmbyServer (服务器配置模型)
- [x] PlaybackState (播放状态模型)

#### 4. 服务层
- [x] EmbyApiClient (Emby API 客户端)
- [x] StorageService (本地存储服务)

#### 5. Provider
- [x] ServerProvider (服务器状态管理)
- [x] MediaProvider (媒体库状态管理) - 待完善
- [x] PlayerProvider (播放器状态管理) - 待完善

#### 6. 页面
- [x] WelcomePage (欢迎页)
- [ ] ServerListPage (服务器列表) - 开发中
- [ ] ServerAddPage (添加服务器) - 开发中
- [ ] HomePage (主页) - 待开发
- [ ] LibraryPage (媒体库) - 待开发
- [ ] MediaDetailPage (媒体详情) - 待开发
- [ ] VideoPlayerPage (视频播放器) - 待开发
- [ ] SettingsPage (设置) - 待开发

### 🚧 进行中
- 服务器管理模块开发

### 📋 待开发

#### 第一阶段 MVP (当前阶段)
- [ ] 服务器管理完整功能
- [ ] 媒体库浏览
- [ ] 视频播放器核心功能
- [ ] 本地媒体播放
- [ ] Windows 打包

#### 第二阶段
- [ ] Android 移动端适配
- [ ] 音频/有声书播放
- [ ] 电子书阅读

#### 第三阶段
- [ ] Android TV 端适配
- [ ] 漫画阅读
- [ ] 多设备进度同步

#### 第四阶段
- [ ] 性能优化
- [ ] 主题切换
- [ ] 发布准备

## 快速开始

### 环境要求
- Flutter SDK 3.x
- Go 1.21+
- Windows 10/11 (开发环境)

### 运行客户端
```bash
cd client
flutter pub get
flutter run -d windows
```

### 构建 Windows 应用
```bash
cd client
flutter build windows --release
```

## 项目结构
```
ebox/
├── client/          # Flutter 客户端
│   ├── lib/
│   │   ├── config/     # 配置 (主题、路由)
│   │   ├── models/     # 数据模型
│   │   ├── services/   # 服务层 (API、存储)
│   │   ├── providers/  # 状态管理
│   │   ├── pages/      # 页面
│   │   └── widgets/    # 可复用组件
│   └── pubspec.yaml
├── server/          # Go 服务端
│   ├── cmd/
│   ├── internal/
│   └── go.mod
└── .monkeycode/     # 项目文档
    ├── docs/
    └── specs/
```

## 相关文档
- [需求文档](./specs/2026-06-03-phase1-mvp/requirements.md)
- [技术设计](./specs/2026-06-03-phase1-mvp/design.md)
- [任务清单](./specs/2026-06-03-phase1-mvp/tasklist.md)

---

**最后更新**: 2026-06-03
