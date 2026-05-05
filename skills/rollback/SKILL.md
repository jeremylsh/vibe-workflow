---
name: rollback
description: 线上出现问题时快速回滚，将 master 重置到最近的稳定 tag 版本，并重新运行 deploy.sh 部署。
command: /rollback
---

## Rollback 助手

本 skill 用于紧急回滚，将 master 分支强制重置到最近一个稳定 tag 版本并重新部署。操作不可逆，执行前会明确告知影响并等待用户确认。

### 工作流程

#### 第一步：查找回滚目标

```bash
# 列出最近 5 个 tag（按版本号倒序）
git fetch --tags
git tag --sort=-v:refname | head -5
```

输出格式：

```
## 可用的回滚版本

  v1.2.0  abc1234  feat(auth): add JWT login flow        2026-05-04 10:45
  v1.1.3  def5678  fix(payment): fix timeout on retry    2026-04-28 15:20
  v1.1.2  ghi9012  fix(api): handle null response        2026-04-20 09:10
  ...

当前 master HEAD: xyz9999  feat(export): add CSV export  2026-05-04 11:30
```

#### 第二步：确认回滚目标

默认建议回滚到最近一个 tag（即上表第一条）。若用户希望回滚到更早版本，可指定 tag 名。

**等待用户确认**，输出回滚警告：

```
## 确认回滚

将执行以下操作（不可逆）：

1. git reset --hard v1.2.0
   master 分支将丢弃 v1.2.0 之后的所有 commit
2. git push origin master --force
   远端 master 将被强制覆盖
3. bash deploy.sh
   重新部署 v1.2.0 版本

**丢失的 commit（将从 master 历史中移除）**：
  xyz9999  feat(export): add CSV export  (已在 PR #42 合并)

确认回滚到 v1.2.0？回复"确认回滚"继续。
```

#### 第三步：执行回滚

用户确认后，依次执行：

```bash
# 切换到 master 并重置到目标 tag
git checkout master
git reset --hard <target-tag>

# 强制推送到远端（覆盖远端 master）
git push origin master --force

# 重新部署
bash deploy.sh 2>&1
```

#### 第四步：输出回滚结果

成功：

```
## 回滚成功

**回滚版本**: v1.2.0
**Commit**: abc1234 feat(auth): add JWT login flow
**部署耗时**: 38s

线上已恢复到 v1.2.0 版本。
请验证线上功能是否恢复正常。
```

失败：

```
## 回滚失败

**阶段**: [git reset / git push / deploy.sh]
**错误**: [具体错误信息]

请人工介入处理。
```

### 注意事项

- 回滚会强制覆盖远端 master，**丢失 tag 之后的所有 commit 历史**，必须用户明确确认
- 被丢弃的 commit 不会真正消失（在 git reflog 中可找回），但远端历史会变更
- 若 deploy.sh 执行失败，git 回滚已完成，需人工排查部署问题
- 回滚完成后，若需要继续开发，dev agent 应重新从最新 master 拉取代码

### 示例触发语

- "/rollback"
- "线上挂了，快速回滚"
- "回滚到上一个版本"
- "回滚到 v1.1.3"
