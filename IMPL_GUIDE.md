# E 宝盒 (ebox) - 极简实施指南

## 📦 项目当前状态

**✅ 已完成的核心工作:**
1. ✅ 项目结构设计
2. ✅ Flutter 客户端框架搭建
3. ✅ Hills 风格深色主题系统
4. ✅ 数据模型定义 (User, MediaLibrary, MediaItem, EmbyServer, PlaybackState)
5. ✅ Emby API 客户端服务
6. ✅ 本地存储服务 (Hive 数据库)
7. ✅ 状态管理 Provider (ServerProvider, MediaProvider, PlayerProvider)
8. ✅ 欢迎页面
9. ✅ 服务器管理页面 (列表、添加)
10. ✅ 主页框架
11. ✅ 设置页面
12. ✅ 路由配置
13. ✅ 需求文档 + 技术设计文档

**⚠️ 待完成的关键页面:**
- 媒体库页面 (部分实现)
- 媒体详情页
- 视频播放器页面 (核心功能)
- 本地媒体页面

## 🚀 快速开始 (给完全不懂代码的你)

### 步骤 1: 安装 Flutter

**Windows 用户:**

1. 下载 Flutter SDK:
   - 访问：https://docs.flutter.dev/get-started/install/windows
   - 下载 "Flutter Windows Package"

2. 解压到 `C:\src\flutter`

3. 添加环境变量:
   - 按 `Win + X`，选择"系统"
   - 点击"高级系统设置"
   - 点击"环境变量"
   - 找到 `Path`，点击"编辑"
   - 新建，添加：`C:\src\flutter\bin`
   - 确定保存

4. 验证安装:
   打开命令提示符 (Win + R, 输入 `cmd`), 输入:
   ```
   flutter --version
   ```
   看到版本号即成功！

### 步骤 2: 安装 Visual Studio

1. 下载 Visual Studio 2022 Community (免费):
   https://visualstudio.microsoft.com/

2. 安装时勾选:**"使用 C++ 的桌面开发"**

### 步骤 3: 获取项目代码

选项 A - 使用 Git (推荐):
```bash
cd C:\Users\你的用户名\Desktop
git clone https://github.com/你的账号/ebox.git
cd ebox/client
```

选项 B - 直接复制:
- 复制整个 `ebox` 文件夹到你的桌面

### 步骤 4: 安装依赖

```bash
cd C:\Users\你的用户名\Desktop\ebox\client
flutter pub get
```

### 步骤 5: 运行应用

```bash
flutter run -d windows
```

如果一切正常，E 宝盒应用将启动！

### 步骤 6: 打包成 EXE

```bash
flutter build windows --release
```

打包完成后的位置:
```
C:\Users\你的用户名\Desktop\ebox\client\build\windows\runner\Release\ebox_client.exe
```

## 📱 如何使用 E 宝盒

### 第一次使用

1. **启动应用**
   - 看到欢迎页面，点击"开始使用"

2. **添加 Emby 服务器**
   - 点击右上角"+"添加服务器
   - 输入服务器地址：`http://你的服务器IP:8096`
   - 输入服务器名称（可选）：如"我家里的 Emby"
   - 点击"测试连接"确认可以连接
   - 输入用户名和密码（如果有）
   - 点击"保存"

3. **连接服务器**
   - 在服务器列表点击你的服务器
   - 选择"连接"

4. **浏览媒体库**
   - 看到电影、电视剧等媒体库
   - 点击任意媒体库浏览内容

5. **播放视频**
   - 点击电影/电视剧封面
   - 点击"播放"按钮开始观看

## 🛠️ 我为你准备的技术文档

### 在 `.monkeycode/` 目录下:

```
.monkeycode/
├── docs/
│   └── PROJECT_STATUS.md      # 项目进度文档
└── specs/
    └── 2026-06-03-phase1-mvp/
        ├── requirements.md    # 需求文档 (功能说明)
        ├── design.md          # 技术设计文档 (架构说明)
        └── tasklist.md        # 任务清单 (开发计划)
```

## 📋 接下来的开发步骤

如果你想继续完善项目，我会帮你完成以下内容:

### 1. 媒体库页面 (1-2 天)
- 海报墙网格展示
- 电影/电视剧分类
- 筛选和排序

### 2. 媒体详情页 (1-2 天)
- 电影/电视剧详情展示
- 演员列表
- 选集功能

### 3. 视频播放器 (3-5 天)
- 播放/暂停/快进
- 进度条
- 字幕加载
- 倍速播放
- 画质选择

### 4. 本地媒体 (2-3 天)
- 扫描本地文件夹
- 播放本地视频

## 💡 常见问题解答

### Q: Flutter 安装失败怎么办？
**A:** 尝试以下方法:
1. 检查网络，可能需要使用代理
2. 使用国内镜像:
   ```
   set PUB_HOSTED_URL=https://pub.flutter-io.cn
   set FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
   ```

### Q: 编译 Windows 版本失败？
**A:** 确保:
1. 安装了 Visual Studio 2022
2. 安装时勾选了"使用C++的桌面开发"
3. Windows 10 SDK 已安装

### Q: 连接不到 Emby 服务器？
**A:** 检查:
1. 服务器地址是否正确 (`http://IP 地址：8096`)
2. 电脑和服务器是否在同一网络
3. 服务器是否正常运行

### Q: 打包后的 EXE 文件怎么分享？
**A:** 打包完成后，整个 `Release` 文件夹可以复制给其他人使用，包括:
- `ebox_client.exe` (主程序)
- `data/` (数据文件夹)
- 其他依赖文件

## 🎯 项目目标

**第一阶段 (当前):** Windows 桌面版 MVP
- Emby 服务器连接
- 视频播放基础功能
- 本地媒体播放

**第二阶段:** 移动端 + 更多媒体类型
- Android 手机版本
- iOS 版本
- 音频/有声书
- 电子书

**第三阶段:** TV 端 + 高级功能
- Android TV版本
- 漫画阅读
- 多设备进度同步

## 📞 需要帮助？

随时告诉我你的问题，我会帮你:
- 解决安装问题
- 继续开发剩余功能
- 修改 UI 设计
- 添加新功能

---

**文档版本**: 1.0  
**创建日期**: 2026-06-03  
**适用于**: 完全不懂代码的用户
