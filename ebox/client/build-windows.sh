#!/bin/bash

# E 宝盒 Windows 打包脚本
# 使用方式：./build-windows.sh

set -e

echo "🚀 开始构建 E 宝盒 Windows 版本..."

# 进入客户端目录
cd client

# 清理之前的构建
echo "🧹 清理旧构建..."
flutter clean

# 获取依赖
echo "📦 安装依赖..."
flutter pub get

# 检查 Flutter 环境
echo "🔍 检查 Flutter 环境..."
flutter doctor -v

# 构建 Windows 版本
echo "🏗️  构建 Windows 版本..."
flutter build windows --release

# 构建完成
echo "✅ Windows 版本构建完成！"
echo ""
echo "📁 发布文件位置："
echo "   client/build/windows/runner/Release/"
echo ""
echo "📦 创建压缩包..."

# 进入 Release 目录
cd build/windows/runner/Release

# 创建版本号文件
VERSION="1.0.0"
BUILD_DATE=$(date +%Y%m%d)

# 创建压缩包（如果系统支持）
if command -v zip &> /dev/null; then
    zip -r ../../../ebox-v${VERSION}-windows-${BUILD_DATE}.zip *
    echo "📦 压缩包已创建：ebox-v${VERSION}-windows-${BUILD_DATE}.zip"
fi

echo ""
echo "🎉 构建完成！"
echo ""
echo "下一步:"
echo "1. 测试 ebox_client.exe 是否能正常运行"
echo "2. 检查所有功能是否正常"
echo "3. 创建 GitHub Release 并上传压缩包"
