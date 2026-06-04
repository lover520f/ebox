@echo off
REM ========================================
REM E 宝盒 v1.0.0 - 一键构建脚本
REM ========================================

echo.
echo ==========================================
echo   E 宝盒 v1.0.0 - GitHub Actions 触发器
echo ==========================================
echo.

REM 检查 gh 是否安装
where gh >nul 2>nul
if %errorlevel% neq 0 (
    echo [1/3] 正在安装 GitHub CLI...
    winget install GitHub.cli --silent --accept-package-agreements --accept-source-agreements
    if %errorlevel% neq 0 (
        echo.
        echo 安装失败，请手动访问：
        echo https://github.com/lover520f/ebox/actions
        echo.
        pause
        exit /b 1
    )
)

echo.
echo [1/3] GitHub CLI 已安装
echo.
echo [2/3] 请登录 GitHub...
echo.

gh auth login

if %errorlevel% neq 0 (
    echo.
    echo 登录失败，请重试
    pause
    exit /b 1
)

echo.
echo [3/3] 正在触发构建...
echo.

gh workflow run build-windows-simple.yml --field version=v1.0.0

if %errorlevel% equ 0 (
    echo.
    echo ==========================================
    echo   构建已启动！
    echo ==========================================
    echo.
    echo 查看进度：
    echo https://github.com/lover520f/ebox/actions
    echo.
    echo 预计完成时间：15 分钟
    echo.
) else (
    echo.
    echo 触发失败，请手动操作：
    echo https://github.com/lover520f/ebox/actions
    echo.
)

pause
