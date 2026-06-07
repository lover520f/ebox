#!/bin/bash
echo "🔍 E 宝盒构建调试脚本"
echo "========================"
echo ""

# 1. 检查 Flutter 环境
echo "1️⃣ 检查 Flutter 环境..."
if command -v flutter &> /dev/null; then
  flutter --version
else
  echo "❌ Flutter 未安装 (这是正常的，CI 环境才有)"
fi
echo ""

# 2. 检查关键文件
echo "2️⃣ 检查关键配置文件..."
FILES=(
  "client/pubspec.yaml"
  "client/lib/main.dart"
  "client/.github/workflows/build.yml"
)

for file in "${FILES[@]}"; do
  if [ -f "/workspace/$file" ]; then
    echo "✅ $file 存在"
  else
    echo "❌ $file 缺失"
  fi
done
echo ""

# 3. 检查 pubspec 格式
echo "3️⃣ 验证 pubspec.yaml 格式..."
if grep -q "^name: ebox" /workspace/client/pubspec.yaml; then
  echo "✅ name 正确"
else
  echo "❌ name 错误"
fi

if grep -q "environment:" /workspace/client/pubspec.yaml; then
  echo "✅ environment 存在"
else
  echo "❌ environment 缺失"
fi

if grep -q "dependencies:" /workspace/client/pubspec.yaml; then
  echo "✅ dependencies 存在"
else
  echo "❌ dependencies 缺失"
fi
echo ""

# 4. 检查 main.dart
echo "4️⃣ 检查 main.dart..."
if grep -q "import 'package:flutter/material.dart'" /workspace/client/lib/main.dart; then
  echo "✅ Flutter import 存在"
else
  echo "❌ Flutter import 缺失"
fi

if grep -q "void main()" /workspace/client/lib/main.dart; then
  echo "✅ main 函数存在"
else
  echo "❌ main 函数缺失"
fi

if grep -q "void runApp" /workspace/client/lib/main.dart; then
  echo "✅ runApp 调用存在"
else
  echo "❌ runApp 调用缺失"
fi
echo ""

# 5. 检查 workflow
echo "5️⃣ 检查 GitHub Actions workflow..."
if grep -q "actions/checkout@v4" /workspace/client/.github/workflows/build.yml; then
  echo "✅ checkout action 存在"
else
  echo "❌ checkout action 缺失"
fi

if grep -q "flutter-action" /workspace/client/.github/workflows/build.yml; then
  echo "✅ flutter action 存在"
else
  echo "❌ flutter action 缺失"
fi

if grep -q "flutter build apk" /workspace/client/.github/workflows/build.yml; then
  echo "✅ build apk 命令存在"
else
  echo "❌ build apk 命令缺失"
fi
echo ""

# 6. 查看最近提交
echo "6️⃣ 最近提交记录:"
cd /workspace && git log --oneline -5
echo ""

# 7. 查看 tag
echo "7️⃣ 当前 tags:"
cd /workspace && git tag | grep "v5" | tail -5
echo ""

echo "========================"
echo "📊 调试完成"
echo ""
echo "🔗 请查看 GitHub Actions 日志获取详细错误:"
echo "   https://github.com/lover520f/ebox/actions"
echo ""
echo "💡 提示：点击失败的 job，展开每个步骤查看红色错误信息"
