# E 宝盒 (ebox) - Windows 打包发布指南

## 📦 打包前的准备工作

### 1. 确保所有依赖已安装

在项目根目录执行：
```bash
cd client
flutter pub get
```

### 2. 检查 Flutter 环境

```bash
flutter doctor -v
```

确保：
- ✅ Flutter 版本正常
- ✅ Windows 工具链已安装
- ✅ Chrome (可选)
- ✅ Visual Studio 已安装

### 3. 配置应用信息

打开 `client/pubspec.yaml`，确认以下信息：
```yaml
name: ebox_client
description: E 宝盒 - 跨平台媒体中心客户端
version: 1.0.0+1  # 版本号
```

## 🚀 Windows 打包步骤

### 方法一：快速打包（推荐）

```bash
cd client
flutter build windows --release
```

打包完成后，文件位置：
```
client/build/windows/runner/Release/
├── ebox_client.exe          # 主程序
├── data/                     # 数据文件夹
├── flutter_windows.dll      # Flutter 运行时
└── 其他依赖文件
```

### 方法二：清理后打包

```bash
cd client
flutter clean
flutter pub get
flutter build windows --release
```

### 方法三：带符号打包（用于发布）

```bash
cd client
flutter build windows --release --split-debug-info=build/symbols
```

## 📁 打包后的文件

打包完成后，你会得到以下文件：

```
Release/
├── ebox_client.exe          # 主程序（约 15-25MB）
├── data/icudtl.dat          # ICU 数据
├── flutter_windows.dll      # Flutter 引擎
├── flutter_plugin_*.dll     # 插件文件
├── glfw3.dll                # GLFW 库
├── msyys-2.dll              # MSYS2 运行时
└── ...其他依赖
```

## 🎁 创建安装包（可选）

### 使用 Inno Setup 创建安装程序

1. **下载并安装 Inno Setup**
   - 官网：https://jrsoftware.org/isdl.php
   - 推荐使用 Inno Script Studio 可视化编辑

2. **创建安装脚本** (`install_script.iss`)

```iss
[Setup]
AppName=E 宝盒
AppVersion=1.0.0
AppPublisher=MonkeyCode AI
DefaultDirName={pf}\ebox
DefaultGroupName=E 宝盒
OutputDir=installer_output

[Files]
Source: "build\windows\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\E 宝盒"; Filename: "{app}\ebox_client.exe"
Name: "{autodesktop}\E 宝盒"; Filename: "{app}\ebox_client.exe"
```

3. **编译安装脚本**
   - 打开 Inno Script Studio
   - 加载 `install_script.iss`
   - 点击"编译"
   - 输出文件：`installer_output/setup.exe`

## 📤 发布到 GitHub

### 1. 创建压缩包

```bash
cd client/build/windows/runner/Release
# Windows 下使用右键压缩，或：
7z a -tzip ebox-v1.0.0-windows.zip *
```

### 2. 上传到 GitHub Releases

1. 访问：https://github.com/lover520f/ebox/releases
2. 点击 "Create a new release"
3. 填写：
   - Tag version: `v1.0.0`
   - Release title: `E 宝盒 v1.0.0 MVP`
   - Description: 发布说明
4. 上传 `ebox-v1.0.0-windows.zip`
5. 点击 "Publish release"

## 📋 发布说明模板

```markdown
# E 宝盒 v1.0.0 MVP

## 🎉 新功能
- ✅ 支持连接 Emby 服务器
- ✅ 支持本地视频播放
- ✅ 精美的 Hills 风格深色主题
- ✅ 海报墙展示
- ✅ 播放进度记忆
- ✅ 倍速播放、字幕选择

## 📦 安装说明
1. 下载 `ebox-v1.0.0-windows.zip`
2. 解压到任意目录
3. 双击运行 `ebox_client.exe`

## ⚠️ 注意事项
- 需要 .NET Framework 4.5+
- 需要 Visual C++ Redistributable
- Windows 10 64 位及以上

## 🐛 已知问题
- 字幕功能开发中
- 画质切换功能开发中

## 📱 下一版本计划
- Android 移动端
- 音频/有声书支持
- 漫画阅读功能
```

## 🔧 常见问题

### Q: 打包时提示 "Build failed"
**A:** 检查以下几点:
1. 是否安装了 Visual Studio 2022
2. 是否勾选了"使用 C++ 的桌面开发"
3. Windows 10 SDK 是否安装
4. 尝试执行 `flutter clean` 后重新打包

### Q: 运行时报错 "找不到 flutter_windows.dll"
**A:** 确保发布时包含所有依赖文件：
- `flutter_windows.dll`
- `data/` 文件夹
- 所有 `.dll` 文件

### Q: 安装包太大（超过 100MB）
**A:** 正常大小应该在 50-80MB。如果太大：
1. 检查是否包含了不必要的文件
2. 使用压缩工具压缩
3. 考虑按需下载资源

### Q: 杀毒软件报毒
**A:** 这是误报，因为 Flutter 应用使用了动态链接库。可以：
1. 添加杀毒软件白名单
2. 对程序进行数字签名
3. 在发布说明中告知用户

## ✨ 优化建议

### 1. 减小包体积
```bash
# 使用 strip 工具去除调试符号
strip build/windows/runner/Release/*.dll
```

### 2. 添加数字签名
- 购买代码签名证书
- 使用 signtool.exe 签名
- 增加用户信任度

### 3. 创建便携版
直接发布整个 `Release` 文件夹的压缩包，用户无需安装即可使用。

## 📊 包大小参考

- **源代码**: ~5MB
- **打包后（未压缩）**: ~150MB
- **打包后（ZIP 压缩）**: ~50-70MB
- **安装版**: ~60-80MB

## 🎯 验证清单

打包前检查：
- [ ] 版本号正确
- [ ] 应用名称正确
- [ ] 功能测试完整
- [ ] 无控制台错误
- [ ] 性能良好

打包后检查：
- [ ] 所有依赖文件齐全
- [ ] 可以正常运行
- [ ] 所有功能可用
- [ ] 文件大小合理
- [ ] 压缩后体积合适

发布前检查：
- [ ] README 已更新
- [ ] 发布说明完整
- [ ] 测试过安装包
- [ ] GitHub Release 创建完成

---

**最后更新**: 2026-06-03  
**适用版本**: 1.0.0  
**平台**: Windows 10/11 64 位
