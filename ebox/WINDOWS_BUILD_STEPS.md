# E 宝盒 Windows 构建指南

## 📦 构建前准备

### 1. 安装 Flutter SDK

**下载地址**: https://docs.flutter.dev/get-started/install/windows

**安装步骤**:
1. 下载 Flutter Windows Package (`flutter_windows_3.x.x-stable.zip`)
2. 解压到 `C:\src\flutter` (或其他位置)
3. 添加环境变量:
   - 右键"此电脑" → "属性"
   - "高级系统设置" → "环境变量"
   - 找到 `Path` → 编辑 → 新建
   - 添加 `C:\src\flutter\bin`
   - 确定保存

4. 验证安装:
   ```cmd
   flutter --version
   flutter doctor -v
   ```

### 2. 安装 Visual Studio

**下载地址**: https://visualstudio.microsoft.com/zh-hans/vs/

**安装时勾选**:
- ✅ 使用 C++ 的桌面开发
- ✅ Windows 10 SDK

### 3. 检查 Flutter 环境

```cmd
flutter doctor -v
```

**必须全绿的项目**:
- ✅ Flutter (已安装)
- ✅ Windows Version
- ✅ Visual Studio - Complete Edition

---

## 🚀 构建步骤

### 方法一: 使用批处理脚本 (简单)

1. 打开命令提示符 (Win + R → 输入 `cmd` → 回车)
2. 进入项目目录:
   ```cmd
   cd C:\路径\ebox\client
   ```
3. 运行打包脚本:
   ```cmd
   build-windows.bat
   ```
4. 等待构建完成 (约 5-10 分钟)

### 方法二: 手动构建 (详细)

#### 1. 清理之前的构建
```cmd
cd C:\路径\ebox\client
flutter clean
```

#### 2. 安装依赖
```cmd
flutter pub get
```

#### 3. 构建 Windows 版本
```cmd
flutter build windows --release
```

#### 4. 构建完成后

**输出目录**: `client\build\windows\runner\Release\`

**包含文件**:
```
Release/
├── ebox_client.exe          # 主程序 (~25MB)
├── data/                     # 数据文件夹
├── flutter_windows.dll      # Flutter 引擎
├── flutter_plugin_*.dll     # 各插件文件
└── ...其他依赖文件
```

**总大小**: 约 130-150MB (解压后)

---

## 📦 创建发布包

### 便携版 (.zip)

1. 进入 Release 目录:
   ```cmd
   cd client\build\windows\runner\Release
   ```

2. 选择所有文件 (Ctrl + A)

3. 右键 → 发送到 → 压缩 (zipped) 文件夹

4. 重命名为: `ebox-v1.0.0-portable.zip`

**便携版大小**: 约 70-80MB (压缩后)

### 安装版 (.exe)

#### 1. 下载 Inno Setup

**下载地址**: https://jrsoftware.org/isdl.php

下载 `innosetup-6.x.exe` 并安装。

#### 2. 创建安装脚本

在 `client` 目录创建文件 `installer_script.iss`:

```iss
#define MyAppName "E 宝盒"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "MonkeyCode AI"
#define MyAppURL "https://github.com/lover520f/ebox"

[Setup]
AppId={{你的 UUID}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=..\..\..\LICENSE
OutputDir=installer_output
OutputBaseFilename=ebox-v1.0.0-setup
SetupIconFile=..\assets\app_icon.ico
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=user
ArchitecturesAllowed=x64

[Languages]
Name: "chinesesimp"; MessagesFile: "compiler:Languages\ChineseSimp.isl"
Name: "english"; MessagesFile: "compiler:Languages\English.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1; Check: not IsAdminInstallDir

[Files]
Source: "build\windows\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\ebox_client.exe"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\ebox_client.exe"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\ebox_client.exe"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\ebox_client.exe"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
```

#### 3. 使用 Inno Script Studio (可视化编辑器)

1. 下载安装 Inno Script Studio (免费)
   - 下载：https://www.innoscriptstudio.com/innoscript-studio/

2. 打开 `installer_script.iss`

3. 点击 "Compile" (编译) 按钮

4. 输出文件：`client\installer_output\ebox-v1.0.0-setup.exe`

#### 4. 或使用命令行 (高级)

```cmd
set IS_PATH="C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
ISCC installer_script.iss
```

---

## 📊 包大小参考

| 文件类型 | 大小 | 说明 |
|----------|------|------|
| **源码** | ~30MB | Git 仓库 |
| **便携版 (.zip)** | ~70MB | 解压即用 |
| **安装版 (.exe)** | ~50MB | 安装后~150MB |

---

## ✅ 验证清单

### 构建前检查
- [ ] Flutter SDK 已安装
- [ ] Visual Studio 已安装
- [ ] `flutter doctor` 全绿
- [ ] `pubspec.yaml` 依赖完整

### 构建后验证
- [ ] `release` 目录存在
- [ ] `ebox_client.exe` 存在
- [ ] 所有 `.dll` 文件存在
- [ ] 可以运行 `ebox_client.exe`

### 发布前检查
- [ ] 便携版压缩包已创建
- [ ] 安装版已编译 (可选)
- [ ] 两个包都能正常运行
- [ ] 所有功能测试通过

---

## 🎯 快速打包脚本 (PowerShell)

保存为 `package-all.ps1`，右键 PowerShell 运行:

```powershell
Write-Host "🚀 开始构建 E 宝盒 Windows 版本..."

# 进入客户端目录
Push-Location client

# 清理
Write-Host "🧹 清理旧构建..."
flutter clean

# 安装依赖
Write-Host "📦 安装依赖..."
flutter pub get

# 构建
Write-Host "🏗️  构建 Windows 版本..."
flutter build windows --release

# 验证
if (Test-Path "build\windows\runner\Release\ebox_client.exe") {
    Write-Host "✅ 构建成功！"
    
    # 创建输出目录
    New-Item -ItemType Directory -Force -Path "dist"
    
    # 便携版
    Write-Host "📦 创建便携版 (.zip)..."
    $portablePath = "dist\ebox-v1.0.0-portable.zip"
    Compress-Archive -Path "build\windows\runner\Release\*" -DestinationPath $portablePath -Force
    
    Write-Host "✅ 便携版已创建：$portablePath"
    Write-Host "💡 提示：使用 Inno Setup 创建安装版 (installer_script.iss)"
    
    # 大小统计
    $zipSize = (Get-Item $portablePath).Length / 1MB
    Write-Host "📊 便携版大小：{0:F2} MB" -f $zipSize
} else {
    Write-Host "❌ 构建失败！请检查错误信息。"
}

Pop-Location
```

---

## 📝 发布到 GitHub

### 1. 访问 GitHub Releases
https://github.com/lover520f/ebox/releases

### 2. 创建 Release
1. 选择 `v1.0.0` 标签 (已创建)
2. 填写发布信息
3. 上传 `ebox-v1.0.0-portable.zip`
4. 上传 `ebox-v1.0.0-setup.exe` (如果创建了)
5. 填写发布说明 (使用 RELEASE_NOTES_v1.0.0.md)

### 3. 发布说明模板

```markdown
# E 宝盒 v1.0.0 - 首次发布

## 下载

### 便携版 (.zip)
- 推荐下载
- 解压即用
- 不写注册表
- 可放 U 盘

👉 [下载 ebox-v1.0.0-portable.zip](https://github.com/lover520f/ebox/releases/download/v1.0.0/ebox-v1.0.0-portable.zip)

### 安装版 (.exe)
- 传统安装方式
- 自动创建快捷方式
- 可添加到系统菜单

👉 [下载 ebox-v1.0.0-setup.exe](https://github.com/lover520f/ebox/releases/download/v1.0.0/ebox-v1.0.0-setup.exe)

## 系统要求
Windows 10/11 64 位
```

---

## 🎯 注意事项

### 常见问题

**Q: flutter doctor 显示红色 X**
- 安装 Visual Studio 2022
- 确保勾选"使用 C++ 的桌面开发"
- 重启电脑后重试

**Q: 编译失败**
- 运行 `flutter clean` 后重试
- 检查 `pubspec.yaml` 格式
- 查看错误日志

**Q: 打包后只有 30MB**
- 确保使用了 `--release` 参数
- 检查所有依赖文件是否包含

---

**最后更新**: 2026-06-03  
**适用版本**: 1.0.0
