---
name: git-commit
description: 使用 conventional commit 规范提交代码。feature 分支自动 push 远端后询问是否发起 PR；master 分支需用户确认后再 push。
command: /git-commit
---

## Git Commit 助手

### Commit Message 格式

```
<type>(<scope>): <subject>
```

- subject 一句话概括核心变更，不超过 50 字符
- 不加 body，除非有必须说明的非显而易见的原因
- type：`feat` / `fix` / `refactor` / `docs` / `style` / `test` / `chore`

### 工作流程

1. `git status` + `git diff` 了解改动
2. Stage 具体文件（不用 `git add .`）
3. 生成 commit message，**向用户确认后**提交
4. 提交成功后，根据当前分支执行不同策略：

#### 非 master 分支（feature / fix / refactor 等）

直接 push 到远端：

```bash
git push origin <current-branch> --set-upstream
```

push 成功后询问：

```
✓ feat(auth): add JWT login flow

已推送到远端。发起 PR？
```

用户确认后触发 `/git-pr`（直接发起 PR，无需再次 push）；用户拒绝则结束。

#### master 分支

提交成功后**先警告，再询问**：

```
✓ fix(config): update timeout value

当前在 master 分支，确认要 push 到远端吗？
```

用户确认后执行 `git push origin master`；用户拒绝则结束，改动保留在本地。

### 最佳实践

- 每次只包含一个逻辑变更
- 不 commit 敏感文件（.env、credentials 等）

### 示例触发语

- "帮我提交当前的改动"
- "提交这个 bug 修复"
- "/git-commit"（由 /feat 自动触发）
