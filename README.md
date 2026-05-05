# vibe-workflow

一套 Claude Code skills，覆盖从需求到部署的完整开发工作流。

## Skills

| Skill | 说明 |
|-------|------|
| `/feat` | 接收需求 → 设计评审 → 创建分支 → 实现 → 自动提交发 PR |
| `/git-commit` | Conventional commit 提交，feature 分支自动 push 并询问是否发 PR |
| `/git-pr` | 创建 PR，在对话中展示 diff 供 review，approve 后自动合并 |
| `/deploy` | 拉取最新 master，运行 `deploy.sh` 部署到线上 |
| `/git-tag` | 部署验证通过后打语义化版本 tag，作为回滚基准点 |
| `/rollback` | 线上出问题时快速回滚到最近的稳定 tag 并重新部署 |

### 工作流串联

```
/feat → /git-commit → /git-pr → merge → /deploy → /git-tag
                                              ↑
                                         /rollback（紧急回滚）
```

## 安装

在你的项目目录下运行：

```bash
curl -fsSL https://raw.githubusercontent.com/jeremylsh/vibe-workflow/master/install.sh | bash
```

或指定目标项目路径：

```bash
curl -fsSL https://raw.githubusercontent.com/jeremylsh/vibe-workflow/master/install.sh | bash -s -- /path/to/project
```

重复运行即可更新到最新版本。

## 前置依赖

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- `git` + `gh` CLI（`/git-pr` 需要，运行 `brew install gh` 安装）
- 项目根目录下需要有 `deploy.sh`（`/deploy` 和 `/rollback` 需要）
