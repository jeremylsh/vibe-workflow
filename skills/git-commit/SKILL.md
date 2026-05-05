---
name: git-commit
description: 使用 conventional commit 规范提交代码。feature 分支自动 push 远端后询问是否发起 PR；master 分支受保护，禁止本地直接 push，只能通过 PR 合入。
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

**禁止直接 push**。提交成功后，输出提示并结束：

```
✓ fix(config): update timeout value

master 分支受保护，不允许本地直接 push。
请切换到 feature 分支，通过 PR 将改动合入 master：

  git checkout -b fix/config-timeout
  git cherry-pick <commit>
  /git-commit → /git-pr
```

> master 的所有变更必须通过 PR 留痕，禁止 `git push origin master`，更不能 `--force`。

### 最佳实践

- 每次只包含一个逻辑变更
- 不 commit 敏感文件（.env、credentials 等）

### 示例触发语

- "帮我提交当前的改动"
- "提交这个 bug 修复"
- "/git-commit"（由 /feat 自动触发）
