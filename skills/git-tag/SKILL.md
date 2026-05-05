---
name: git-tag
description: 线上版本验证稳定后，在 master 分支打语义化版本 tag，作为回滚基准点。
command: /git-tag
---

## Git Tag 助手

本 skill 在 `/deploy` 部署完成、用户验证线上功能稳定后触发，给当前 master 打版本 tag，作为 `/rollback` 的回滚基准点。

### Tag 格式

使用语义化版本（Semantic Versioning）：

```
v<major>.<minor>.<patch>
```

- **major**：不兼容的破坏性变更
- **minor**：向后兼容的新功能
- **patch**：向后兼容的 Bug 修复

示例：`v1.0.0`、`v1.2.3`、`v2.0.0`

### 工作流程

1. 确认当前在 master 分支（`git branch --show-current`）
2. 确认工作区干净（`git status`）
3. 拉取最新代码（`git pull origin master`）
4. 查看已有 tag，确定下一个版本号（`git tag --sort=-v:refname | head -10`）
5. 向用户展示建议版本号，**等待确认**
6. 创建带注释的 tag（`git tag -a <version> -m "<message>"`）
7. 推送 tag 到远端（`git push origin <version>`）
8. 确认推送成功，输出 tag 信息

### 版本号决策规则

- 用户明确指定版本号 → 直接使用
- "打个 patch tag" / "修复发布" → 递增 patch 位
- "打个 minor tag" / "新功能发布" → 递增 minor 位，patch 归零
- "打个 major tag" / "大版本发布" → 递增 major 位，minor 和 patch 归零
- 无任何历史 tag → 从 `v0.1.0` 开始
- 用户未说明类型 → 询问本次发布属于哪种变更类型

### 输出格式

```
## Tag 已打

**版本**: v1.2.0
**Commit**: abc1234 feat(auth): add JWT login flow
**时间**: 2026-05-04 10:45

此版本为回滚基准点。若线上出现问题，运行 /rollback 可快速回滚到此版本。
```

### 注意事项

- **必须**确认在 master 分支上再打 tag
- 推送前向用户展示版本号，确认后再执行
- 不要在未完整合并的功能分支上打 release tag
- 避免删除已推送的 tag，如需修正应打新 tag

### 示例触发语

- "验证没问题，帮我打个 tag"
- "打一个 v1.2.0 的 tag"
- "这次是 bug 修复，打 patch tag"
- "新功能上线，打 minor tag"
