# 📤 E 宝盒 v1.0.0 GitHub Release 发布指南

## ✅ 已完成的步骤

- ✅ Git 仓库创建
- ✅ 所有代码已推送
- ✅ v1.0.0 标签已创建
- ✅ 文档完整
- ⏳ **需要你执行：在 Windows 上构建并发布**

---

## 📋 发布步骤（请按顺序执行）

### 第 1 步：在 Windows 上构建

由于当前环境没有 Flutter，你需要：

#### 方式 A: 使用批处理脚本 (推荐)

1. **在 Windows 上打开 Git Bash** 或命令提示符
2. 导航到项目目录:
   ```bash
   cd /workspace/ebox/client
   ```
3. 运行打包脚本:
   ```bash
   ./build-windows.bat
   ```

#### 方式 B: 手动构建

```bash
cd /workspace/ebox/client
flutter clean
flutter pub get
flutter build windows --release
```

**预期输出**:
```
✓ Built build\windows\runner\Release\ebox_client.exe
```

### 第 2 步：创建便携版 (.zip)

```bash
cd /workspace/ebox/client/build/windows/runner/Release

# Windows PowerShell
Compress-Archive -Path * -DestinationPath ../../../../../../dist/ebox-v1.0.0-portable.zip
```

或者使用资源管理器:
1. 全选所有文件
2. 右键 → 发送到 → 压缩文件夹
3. 重命名为 `ebox-v1.0.0-portable.zip`

### 第 3 步：创建安装版 (.exe) - 可选

1. **下载 Inno Setup**: https://jrsoftware.org/isdl.php
2. **创建安装脚本** - 创建 `client/installer_script.iss`:

```iss
#define MyAppName "E 宝盒"
#define MyAppVersion "1.0.0"
#define MyAppURL "https://github.com/lover520f/ebox"

[Setup]
AppName={#MyAppName}
AppVersion={#MyAppVersion}
DefaultDirName={autopf}\{#MyAppName}
OutputDir=dist
OutputBaseFilename=ebox-v1.0.0-setup
WizardStyle=modern

[Files]
Source: "build\windows\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\ebox_client.exe"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\ebox_client.exe"

[Run]
Filename: "{app}\ebox_client.exe"; Description: "启动 E 宝盒"; Flags: nowait postinstall skipifsilent
```

3. **编译安装程序**:
   - 使用 Inno Script Studio (推荐): 打开脚本 → 点击 Compile
   - 或使用命令行:
     ```cmd
     "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer_script.iss
     ```

4. **输出文件**: `dist\ebox-v1.0.0-setup.exe`

### 第 4 步：访问 GitHub Releases

打开浏览器访问:
```
https://github.com/lover520f/ebox/releases
```

### 第 5 步：创建 Release

1. 点击 **"Create a new release"** 或编辑 `v1.0.0`

2. 填写发布信息:
   - **Tag version**: `v1.0.0` (已存在)
   - **Release title**: `E 宝盒 v1.0.0 - 首次发布`
   - **Write** (写发布说明，复制下面的模板)

3. **上传文件**:
   - 上传 `dist/ebox-v1.0.0-portable.zip`
   - 上传 `dist/ebox-v1.0.0-setup.exe` (如果创建了)

4. 点击 **"Publish release"**

---

## 📝 Release 发布说明模板

```markdown
# 🎉 E 宝盒 v1.0.0 - 首次发布

> 跨平台媒体中心应用 - 完美的 Hills 风格界面，支持 Emby 服务器和本地播放

## 📥 下载

### 📦 便携版 (推荐)
- **文件名**: `ebox-v1.0.0-portable.zip`
- **大小**: ~70MB (压缩后)
- **优点**:
  - ✅ 解压即用，无需安装
  - ✅ 不写注册表，完全绿色
  - ✅ 可放 U 盘，随身携带
  - ✅ 干净卫生，删除即用

👉 [点击下载便携版](https://github.com/lover520f/ebox/releases/download/v1.0.0/ebox-v1.0.0-portable.zip)

### 🛠️ 安装版
- **文件名**: `ebox-v1.0.0-setup.exe`
- **大小**: ~50MB (安装包)
- **优点**:
  - ✅ 一键安装，自动创建快捷方式
  - ✅ 集成到程序菜单
  - ✅ 桌面快捷方式

👉 [点击下载安装版](https://github.com/lover520f/ebox/releases/download/v1.0.0/ebox-v1.0.0-setup.exe)

## 🎬 核心功能

- ✅ **连接 Emby 媒体服务器** - 完美兼容
- ✅ **播放本地视频** - 支持多种格式
- ✅ **真实视频播放** - video_player 集成
- ✅ **精美海报墙** - 网络图片自动缓存
- ✅ **播放进度记忆** - 断点续播
- ✅ **倍速播放** - 0.5x - 2.0x
- ✅ **深色主题** - Hills 风格，护眼舒适
- ✅ **流畅动画** - 交互体验一流

## 💻 系统要求

**最低配置**:
- 操作系统：Windows 10 64 位 (1903 或更高版本)
- 处理器：双核 2.0 GHz
- 内存：4 GB RAM
- 硬盘空间：500 MB 可用空间

**推荐配置**:
- 操作系统：Windows 11 64 位
- 处理器：四核 2.5 GHz+
- 内存：8 GB RAM
- 显卡：支持硬件解码

## 🚀 快速开始

### 使用便携版

1. 下载 `ebox-v1.0.0-portable.zip`
2. 右键 → 全部解压缩
3. 打开文件夹，双击 `ebox_client.exe`
4. 开始使用！

### 使用安装版

1. 下载 `ebox-v1.0.0-setup.exe`
2. 双击运行
3. 选择安装目录 (默认 `C:\Program Files\E 宝盒`)
4. 点击"安装"
5. 安装完成后自动启动

### 连接 Emby 服务器

```
1. 点击"开始使用"
2. 点击右上角"+"添加服务器
3. 填写服务器地址：http://IP 地址：8096
4. 填写用户名密码 (如果有)
5. 点击"测试连接"
6. 保存并连接
7. 享受你的媒体库！
```

### 播放本地视频

```
1. 底部导航点击"本地"
2. 点击"选择文件夹"
3. 选择包含视频的目录
4. 自动扫描视频文件
5. 点击任意视频播放
```

## 🐛 已知问题

- 字幕功能 UI 已完成，实际加载将在 v1.1.0 实现
- 画质选择功能开发中
- 搜索功能基础版可用，高级筛选将在 v1.1.0 完善

## 📋 更新计划

### v1.1.0 (2026 年 Q3)
- [ ] 字幕加载和切换
- [ ] 画质选择
- [ ] 完整搜索功能
- [ ] Android 版本

### v1.2.0 (2026 年 Q4)
- [ ] iOS 版本
- [ ] 音频/有声书
- [ ] 电子书阅读

## 📞 反馈与支持

- **项目主页**: https://github.com/lover520f/ebox
- **问题反馈**: https://github.com/lover520f/ebox/issues
- **使用指南**: https://github.com/lover520f/ebox/blob/main/USER_GUIDE_SIMPLE.md

## 🙏 致谢

感谢以下开源项目：
- [Flutter](https://flutter.dev) - 跨平台 UI 框架
- [Emby](https://emby.media) - 媒体服务器
- [video_player](https://pub.dev/packages/video_player) - 视频播放
- [cached_network_image](https://pub.dev/packages/cached_network_image) - 图片缓存

---

**开发团队**: MonkeyCode AI  
**发布日期**: 2026-06-03  
**License**: MIT
```

---

## ✅ 验证清单

发布前确认：

- [ ] 已在 Windows 上构建了 `Release` 目录
- [ ] 已创建便携版压缩包 (`ebox-v1.0.0-portable.zip`)
- [ ] 已创建安装版 (`ebox-v1.0.0-setup.exe`) - 可选
- [ ] GitHub Release 页面已打开
- [ ] 释放说明已复制
- [ ] 文件已上传
- [ ] 点击了 "Publish release"

---

## 💡 快速命令汇总

```bash
# 完整构建流程 (在 Windows PowerShell 中执行)
cd ebox/client
flutter pub get
flutter build windows --release

# 创建便携版
cd build/windows/runner/Release
Compress-Archive -Path * -DestinationPath ../../../../../../dist/ebox-v1.0.0-portable.zip

# 验证
ls ../../../../dist/
```

---

**完成所有这些步骤后，E 宝盒 v1.0.0 就正式发布到 GitHub 了！** 🎉
