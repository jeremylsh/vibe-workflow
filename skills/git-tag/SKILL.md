---
name: git-tag
description: 在 deploy 之前，给当前 master HEAD 打语义化版本 tag，作为本次生产发布的版本标识和 rollback 基准点。
command: /git-tag
---

## Git Tag 助手

本 skill 在 `/git-pr` 合并后、`/deploy` 执行前触发，给当前 master HEAD 打版本 tag，**确保每次生产部署都有对应的版本号**。tag 是 `/rollback` 的回滚基准点，也是生产发布的可追溯凭证。

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
3. 拉取最新代码（`git pull origin master --ff-only`）
4. 查看已有 tag，确定下一个版本号（`git tag --sort=-v:refname | head -10`）
5. 检查 HEAD 是否已有 tag（`git tag --points-at HEAD`）——若已有则展示并询问是否继续
6. 向用户展示建议版本号，**等待确认**
7. 创建带注释的 tag（`git tag -a <version> -m "<message>"`）
8. 推送 tag 到远端（`git push origin <version>`）
9. 确认推送成功，输出 tag 信息

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

版本 tag 已推送到远端，现在可以运行 /deploy 将此版本部署到线上。
```

### 注意事项

- **必须**确认在 master 分支上再打 tag
- 推送前向用户展示版本号，确认后再执行
- tag 只标记 commit，不修改任何分支，对 master 分支历史无影响
- 不要在未完整合并的功能分支上打 release tag
- 避免删除已推送的 tag，如需修正应打新 tag（如 v1.2.1）
- 若部署后出现问题、需要修复后发布，新修复版本打新 tag（v1.2.1），不重打旧 tag

### 标准发布顺序

```
/feat → /git-commit → /git-pr → /git-tag → /deploy
```

### 示例触发语

- "/git-tag"
- "PR 合了，打个 tag 准备发布"
- "打一个 v1.2.0 的 tag"
- "这次是 bug 修复，打 patch tag"
- "新功能上线，打 minor tag"
