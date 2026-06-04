# 用户指令记忆

本文件记录了用户的指令、偏好和教导，用于在未来的交互中提供参考。

## 格式

### 用户指令条目
用户指令条目应遵循以下格式：

[用户指令摘要]
- Date: [YYYY-MM-DD]
- Context: [提及的场景或时间]
- Instructions:
  - [用户教导或指示的内容，逐行描述]

### 项目知识条目
Agent 在任务执行过程中发现的条目应遵循以下格式：

[项目知识摘要]
- Date: [YYYY-MM-DD]
- Context: Agent 在执行 [具体任务描述] 时发现
- Category: [运维部署|构建方法|测试方法|排错调试|工作流协作|环境配置]
- Instructions:
  - [具体的知识点，逐行描述]

## 去重策略
- 添加新条目前，检查是否存在相似或相同的指令
- 若发现重复，跳过新条目或与已有条目合并
- 合并时，更新上下文或日期信息
- 这有助于避免冗余条目，保持记忆文件整洁

## 条目

[项目构建与发布 - Flutter Windows 应用]
- Date: 2026-06-04
- Context: Agent 在执行 E 宝盒 v1.0.0 构建、测试和发布任务时发现
- Category: 构建方法 | 运维部署
- Instructions:
  - Flutter Windows 构建输出路径：client/build/windows/x64/runner/Release/
  - 构建生成的可执行文件名：client.exe（Flutter 默认名称）
  - 使用 GitHub Actions workflow_dispatch 触发手动构建
  - GitHub Actions 工作流文件路径：.github/workflows/build-windows-simple.yml
  - 工作流步骤：Checkout → Setup Flutter → Create and Push Tag → Enable Windows Support → Build Windows → Verify Build → Create ZIP → Upload to Release
  - Tag 创建后才能发布 GitHub Release，需要在工作流中显式指定 tag_name 参数
  - 使用 softprops/action-gh-release 发布 Release
  - 便携版 ZIP 包路径：dist/ebox-v1.0.0-portable.zip，大小约 12.29 MB
  - Release URL: https://github.com/lover520f/ebox/releases
  - 构建时间约 4-5 分钟
  - GitHub CLI 命令：gh workflow run "Build Windows Release" --ref master --field version=v1.0.0
  - 监控构建命令：gh run view <run-id>
