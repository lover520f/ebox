@echo off
REM E 宝盒 Windows 打包脚本 (批处理版本)
REM 使用方式：双击运行 build-windows.bat

echo 🚀 开始构建 E 宝盒 Windows 版本...

REM 进入客户端目录
cd client

REM 清理之前的构建
echo 🧹 清理旧构建...
call flutter clean

REM 获取依赖
echo 📦 安装依赖...
call flutter pub get

REM 检查 Flutter 环境
echo 🔍 检查 Flutter 环境...
call flutter doctor -v

REM 构建 Windows 版本
echo 🏗️  构建 Windows 版本...
call flutter build windows --release

REM 构建完成
echo.
echo ✅ Windows 版本构建完成！
echo.
echo 📁 发布文件位置：
echo    client\build\windows\runner\Release\
echo.
echo 🎉 构建完成！
echo.
echo 下一步:
echo 1. 测试 ebox_client.exe 是否能正常运行
echo 2. 检查所有功能是否正常
echo 3. 创建 GitHub Release 并上传压缩包
echo.

pause
