---
name: rollback
description: 线上出现问题时快速回滚，将线上环境恢复到上一个稳定的 tag 版本部署，master 分支代码不变。
command: /rollback
---

## Rollback 助手

本 skill 用于紧急回滚，将**线上运行的代码**恢复到上一个稳定 tag 版本。**master 分支历史完全不变**，团队可以在 master 上继续开发和修复，通过正常 PR 流程发布新版本。

### 核心原则

- **只回滚部署，不回滚代码**：master 分支保持不动，回滚是让线上运行旧版本的代码
- **有据可查**：所有变更均通过 PR 合入，master 历史完整，无 force push
- **修复正常进行**：回滚后在 master 上继续修复，PR 合并后打新 tag（如 v1.1.2）再发布

### 工作流程

#### 第一步：查找回滚目标

```bash
# 拉取最新 tag 信息
git fetch --tags

# 列出最近 5 个 tag（按版本号倒序）
git tag --sort=-v:refname | head -5
```

同时获取每个 tag 对应的 commit 信息：

```bash
git for-each-ref --sort=-v:refname --format '%(refname:short) %(objectname:short) %(subject) %(creatordate:short)' refs/tags | head -5
```

输出格式：

```
## 可用的回滚版本

  v1.1.1  xyz9999  feat(export): add CSV export     2026-05-04  ← 当前线上版本
  v1.0.1  abc1234  fix(auth): fix token expiry       2026-04-28  ← 建议回滚目标
  v1.0.0  def5678  feat(auth): add JWT login flow    2026-04-20

当前 master HEAD: xyz9999  feat(export): add CSV export (与线上版本一致，不会改动)
```

#### 第二步：确认回滚目标

默认建议回滚到**当前版本的上一个 tag**（即上表第二条）。若用户希望回滚到更早版本，可指定 tag 名。

**等待用户确认**，输出回滚说明：

```
## 确认回滚

将执行以下操作：

1. git checkout v1.0.1        # 切换到目标 tag 的代码（detached HEAD）
2. bash deploy.sh             # 以该版本代码重新部署线上环境
3. git checkout master        # 切回 master（master 分支不受影响）

**本次回滚**：v1.1.1 → v1.0.1
**master 分支**：保持不变（仍在 xyz9999，后续修复在此继续）

确认回滚到 v1.0.1？回复"确认回滚"继续。
```

#### 第三步：执行回滚部署

用户确认后，依次执行：

```bash
# 切换到目标 tag（detached HEAD，不影响任何分支）
git checkout <target-tag>

# 以该版本代码重新部署
bash deploy.sh 2>&1

# 切回 master（保证工作区回到正常状态）
git checkout master
```

#### 第四步：输出回滚结果

成功：

```
## 回滚成功

**回滚版本**: v1.0.1 (abc1234)
**部署耗时**: 38s

线上已恢复到 v1.0.1 版本，master 分支未变更。
请验证线上功能是否恢复正常。

后续步骤：
- 在 master 上修复问题，通过 PR 合入
- 合入后运行 /git-tag 打新版本（如 v1.1.2）
- 再运行 /deploy 重新发布
```

失败：

```
## 回滚失败

**阶段**: [git checkout / deploy.sh]
**错误**: [具体错误信息]

master 分支未受影响，请人工介入处理部署问题。
```

### 注意事项

- **绝不** `git reset --hard` 或 `git push --force` master 分支
- rollback 使用 detached HEAD 检出目标 tag，仅影响部署，不改变任何分支指针
- 若 deploy.sh 执行失败，git checkout 已完成但部署未成功，需人工排查
- 回滚完成后，团队在 master 上正常开发修复，通过 PR 流程发布新版本

### 标准修复流程（回滚后）

```
回滚到 v1.0.1
  → 在 master 修复问题（正常开发）
  → /git-commit → /git-pr → 合并到 master
  → /git-tag（打 v1.1.2）
  → /deploy（发布 v1.1.2）
```

### 示例触发语

- "/rollback"
- "线上挂了，快速回滚"
- "回滚到上一个版本"
- "回滚到 v1.0.1"
