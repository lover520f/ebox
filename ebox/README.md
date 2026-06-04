# E 宝盒 (ebox) - 给完全不懂代码的用户的实施指南

## 📋 项目说明

我已经为你设计并开始开发一款名为**E 宝盒 (ebox)** 的跨平台影视软件，功能类似 Emby 客户端，但界面完全模仿 Hills 播放器的精美设计。

### 核心功能
✅ 连接 Emby 服务器观影  
✅ 本地视频播放  
✅ 支持电影、电视剧分类  
✅ 精美的海报墙界面  
✅ 播放进度记忆  
✅ 支持字幕、倍速播放  

### 支持平台
- ✅ Windows 电脑 (第一阶段 - 当前)
- ⏳ Android 手机 (第二阶段)
- ⏳ Android TV 电视 (第三阶段)
- ⏳ iPhone/iPad (第三阶段)

## 🎯 你目前的位置

**第一阶段 MVP 开发中** - 已完成基础架构和核心服务，剩余页面开发中。

## 📦 你需要做的事情 (按顺序)

### 第 1 步：安装必要软件

#### 1.1 安装 Git
下载地址：https://git-scm.com/download/win
- 下载安装包
- 双击运行
- 全部默认选项即可

#### 1.2 安装 Flutter SDK
下载地址：https://docs.flutter.dev/get-started/install/windows

**安装步骤:**
1. 下载 Flutter Windows 安装包
2. 解压到 `C:\src\flutter` (或其他路径)
3. 添加 Flutter 到系统环境变量：
   - 右键"此电脑" → "属性" → "高级系统设置"
   - "环境变量" → 找到"Path"
   - 编辑 → 新建 → 添加 `C:\src\flutter\bin`
   - 确定保存

4. 验证安装：
   打开命令提示符，输入：
   ```
   flutter --version
   ```

#### 1.3 安装 Android Studio (可选，用于 Android 开发)
如果只需要 Windows 版本，可以跳过这一步。

#### 1.4 安装 Visual Studio (用于 Windows 开发)
下载 Visual Studio 2022 Community Edition:
https://visualstudio.microsoft.com/

安装时勾选：
- "使用 C++ 的桌面开发"

### 第 2 步：获取项目代码

打开命令提示符，执行：

```bash
cd C:\Users\你的用户名\Desktop
git clone https://github.com/你的账号/ebox.git
```

或者，如果你还没有创建 GitHub 仓库，我可以帮你配置本地项目。

### 第 3 步：安装依赖

```bash
cd ebox/client
flutter pub get
```

### 第 4 步：运行应用

```bash
flutter run -d windows
```

如果一切正常，你会看到 E 宝盒应用启动！

### 第 5 步：打包成可执行文件

```bash
flutter build windows --release
```

打包完成后，EXE 文件位置：
```
ebox/build/windows/runner/Release/ebox_client.exe
```

你可以把这个文件发给其他人使用！

## 🎨 界面预览

### 设计风格
- **深色主题**: 深蓝黑色背景，护眼舒适
- **渐变点缀**: 紫蓝色渐变，科技感十足
- **圆角设计**: 所有卡片都是圆角，现代感强
- **大字体**: 清晰易读

### 主要页面
1. **欢迎页**: 大 Logo + "开始使用"按钮
2. **服务器列表**: 显示已配置的 Emby 服务器
3. **主页**: 媒体库网格展示
4. **海报墙**: 电影/电视剧封面展示
5. **播放器**: 全屏播放界面

## 🔧 常见问题

### Q1: Flutter 安装失败
**解决方案**: 
- 确保网络通畅
- 使用国内镜像：`export PUB_HOSTED_URL=https://pub.flutter-io.cn`

### Q2: Windows 编译失败
**解决方案**:
- 确认安装了 Visual Studio
- 确认勾选了"使用 C++ 的桌面开发"

### Q3: 连接 Emby 服务器失败
**解决方案**:
- 检查服务器地址是否正确
- 确保服务器在线
- 检查用户名密码

## 📞 技术支持

如果在开发过程中遇到问题，请随时告诉我！

## 🚀 下一步计划

我会继续完成以下功能：
1. ✅ 服务器管理页面 (进行中)
2. ✅ 主页和媒体库
3. ✅ 视频播放器
4. ✅ Windows 打包

完成后，你将拥有一个**完整的、可运行的**Windows 版本 E 宝盒！

---

**创建日期**: 2026-06-03  
**作者**: MonkeyCode AI 助手
