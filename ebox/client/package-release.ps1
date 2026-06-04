#!/usr/bin/env pwsh
# E 宝盒 Windows 自动打包脚本 (PowerShell)
# 使用方式：.\package-release.ps1

$ErrorActionPreference = "Stop"

Write-Host "🚀 开始构建 E 宝盒 Windows 版本..." -ForegroundColor Green
Write-Host ""

# 进入客户端目录
Set-Location $PSScriptRoot/client

# 1. 检查 Flutter
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Flutter 未安装！请先安装 Flutter SDK。" -ForegroundColor Red
    Write-Host "下载地址：https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
    exit 1
}

# 2. Flutter 版本
Write-Host "📊 Flutter 版本:" -ForegroundColor Cyan
flutter --version
Write-Host ""

# 3. 清理
Write-Host "🧹 清理旧构建..." -ForegroundColor Cyan
flutter clean

# 4. 安装依赖
Write-Host "📦 安装依赖..." -ForegroundColor Cyan
flutter pub get

# 5. 构建
Write-Host "🏗️  构建 Windows Release 版本..." -ForegroundColor Cyan
Write-Host "   (这可能需要 5-10 分钟)" -ForegroundColor Gray
flutter build windows --release

# 6. 验证
if (Test-Path "build\windows\runner\Release\ebox_client.exe") {
    Write-Host ""
    Write-Host "✅ 构建成功！" -ForegroundColor Green
    Write-Host ""
    
    # 7. 创建输出目录
    New-Item -ItemType Directory -Force -Path "dist" | Out-Null
    
    # 8. 便携版
    Write-Host "📦 创建便携版 (.zip)..." -ForegroundColor Cyan
    $portableZip = "../dist/ebox-v1.0.0-portable.zip"
    Compress-Archive -Path "build\windows\runner\Release\*" -DestinationPath $portableZip -Force
    
    $zipSize = (Get-Item $portableZip).Length / 1MB
    Write-Host "✅ 便携版已创建：$portableZip ({0:F2} MB)" -ForegroundColor Green -f $zipSize
    
    # 9. 创建安装版 (如果存在 Inno Setup)
    $innoSetup = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
    if (Test-Path $innoSetup) {
        Write-Host ""
        Write-Host "📦 创建安装版 (.exe)..." -ForegroundColor Cyan
        
        # 检查安装脚本
        if (Test-Path "installer_script.iss") {
            & $innoSetup "installer_script.iss"
            
            if (Test-Path "dist\ebox-v1.0.0-setup.exe") {
                $exeSize = (Get-Item "dist\ebox-v1.0.0-setup.exe").Length / 1MB
                Write-Host "✅ 安装版已创建：dist\ebox-v1.0.0-setup.exe ({0:F2} MB)" -ForegroundColor Green -f $exeSize
            } else {
                Write-Host "⚠️  安装版创建失败，请手动检查 Inno Setup 配置" -ForegroundColor Yellow
            }
        } else {
            Write-Host "⚠️  未找到 installer_script.iss，跳过安装版创建" -ForegroundColor Yellow
        }
    } else {
        Write-Host ""
        Write-Host "💡 提示：安装 Inno Setup 可以创建安装版 (.exe)" -ForegroundColor Cyan
        Write-Host "   或者直接使用便携版也可以正常分发" -ForegroundColor Gray
    }
    
    # 10. 大小统计
    Write-Host ""
    Write-Host "📊 构建统计:" -ForegroundColor Cyan
    Write-Host "   便携版 (ZIP): {0:F2} MB" -f $zipSize
    if (Test-Path "dist\ebox-v1.0.0-setup.exe") {
        $exeSize = (Get-Item "dist\ebox-v1.0.0-setup.exe").Length / 1MB
        Write-Host "   安装版 (EXE): {0:F2} MB" -f $exeSize
    }
    
    # 11. 下一步指引
    Write-Host ""
    Write-Host "🎯 下一步:" -ForegroundColor Cyan
    Write-Host "   1. 访问 GitHub Releases: https://github.com/lover520f/ebox/releases" -ForegroundColor White
    Write-Host "   2. 创建 Release (编辑 v1.0.0)" -ForegroundColor White
    Write-Host "   3. 上传 dist 文件夹中的压缩包" -ForegroundColor White
    Write-Host "   4. 复制发布说明 (参考 RELEASE_NOTES_v1.0.0.md)" -ForegroundColor White
    Write-Host "   5. 点击 Publish release" -ForegroundColor White
    Write-Host ""
    
    # 12. 测试程序 (可选)
    Write-Host "💡 测试程序:" -ForegroundColor Cyan
    Write-Host "   运行 .\build\windows\runner\Release\ebox_client.exe 验证是否正常工作" -ForegroundColor Gray
    Write-Host ""
    
} else {
    Write-Host ""
    Write-Host "❌ 构建失败！请检查错误信息。" -ForegroundColor Red
    exit 1
}
