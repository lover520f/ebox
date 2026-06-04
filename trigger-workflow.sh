#!/bin/bash
# 手动触发 GitHub Actions 工作流
# 使用 GitHub API 触发 workflow_dispatch

REPO="lover520f/ebox"
WORKFLOW_ID="build-windows.yml"
BRANCH="master"
VERSION="v1.0.0"

echo "🚀 手动触发 GitHub Actions 工作流..."
echo ""

# 检查是否设置了 GITHUB_TOKEN
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ 错误：需要设置 GITHUB_TOKEN 环境变量"
    echo ""
    echo "请在 GitHub 上生成 Personal Access Token:"
    echo "1. 访问：https://github.com/settings/tokens"
    echo "2. 创建新 token (勾选 repo 权限)"
    echo "3. 复制 token 并设置环境变量:"
    echo "   export GITHUB_TOKEN=your_token_here"
    echo ""
    exit 1
fi

# 触发工作流
echo "📤 发送触发请求到 GitHub..."
RESPONSE=$(curl -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.github.com/repos/$REPO/actions/workflows/$WORKFLOW_ID/dispatches" \
  -d "{\"ref\":\"$BRANCH\",\"inputs\":{\"version\":\"$VERSION\"}}")

# 检查结果
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 工作流触发成功！"
    echo ""
    echo "🔗 查看构建进度："
    echo "   https://github.com/$REPO/actions"
    echo ""
    echo "⏱️ 预计完成时间：10-15 分钟"
    echo ""
    echo "📋 执行步骤:"
    echo "   1. ✅ 工作流已触发"
    echo "   2. ⏳ GitHub Actions 正在启动..."
    echo "   3. ⏳ 安装 Flutter 环境"
    echo "   4. ⏳ 编译 Windows 版本"
    echo "   5. ⏳ 创建 ZIP 压缩包"
    echo "   6. ⏳ 创建 GitHub Release"
    echo "   7. ⏳ 上传文件"
    echo ""
else
    echo ""
    echo "❌ 工作流触发失败"
    echo "响应：$RESPONSE"
    echo ""
    echo "请检查:"
    echo "1. GITHUB_TOKEN 是否正确"
    echo "2. 仓库是否有 Actions 权限"
    echo "3. 工作流文件是否正确"
fi
