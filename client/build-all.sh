#!/bin/bash

set -e

echo "===== E 宝盒 v5.0.0 全平台构建 ====="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}开始构建...${NC}"

# 清理
echo -e "${YELLOW}清理旧的构建...${NC}"
flutter clean

# 获取依赖
echo -e "${YELLOW}获取依赖...${NC}"
flutter pub get

# 构建 Windows 版本
echo -e "${YELLOW}构建 Windows 版本...${NC}"
flutter build windows --release
echo -e "${GREEN}✓ Windows 构建完成${NC}"

# 构建 Android Mobile 版本
echo -e "${YELLOW}构建 Android Mobile 版本...${NC}"
flutter build apk --flavor mobile -t lib/main/main_mobile.dart --release
echo -e "${GREEN}✓ Android Mobile 构建完成${NC}"

# 构建 Android TV 版本
echo -e "${YELLOW}构建 Android TV 版本...${NC}"
flutter build apk --flavor tv -t lib/main/main_tv.dart --release
echo -e "${GREEN}✓ Android TV 构建完成${NC}"

# 构建 Android App Bundle (用于 Google Play)
echo -e "${YELLOW}构建 Android App Bundle...${NC}"
flutter build appbundle --release
echo -e "${GREEN}✓ Android App Bundle 构建完成${NC}"

echo -e "${GREEN}===== 所有构建完成 =====${NC}"
echo ""
echo "构建产物位置:"
echo "  Windows: build/windows/runner/Release/"
echo "  Android Mobile: build/app/outputs/flutter-apk/app-mobile-release.apk"
echo "  Android TV: build/app/outputs/flutter-apk/app-tv-release.apk"
echo "  App Bundle: build/app/outputs/bundle/release/"
