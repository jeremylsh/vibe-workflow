---
name: git-pr
description: 在 /git-commit 已 push 远端的基础上，发起到 master 的 Pull Request，在对话中展示 diff 供用户 review，用户 approve 后自动合并。
command: /git-pr
---

## Git PR 助手

本 skill 由 `/git-commit` 用户确认后触发。代码由 `/git-commit` 负责 push，本 skill 只负责创建 PR、展示 diff、等待用户 approve 后合并。

### SSH 强制要求

**必须使用 SSH 连接 GitHub，禁止使用 HTTPS。**

执行任何操作前验证 remote URL：

```bash
git remote get-url origin
```

- 合法：`git@github.com:<org>/<repo>.git`
- 非法：`https://github.com/<org>/<repo>.git`

若为 HTTPS，**立即停止**，提示用户修复（见故障排查）。

### 工作流程

#### 第一步：前置检查

```bash
# 确认不在 master 分支
git branch --show-current

# 确认工作区干净
git status

# 确认远端分支已存在（由 /git-commit 已 push）
git ls-remote --heads origin <current-branch>
```

若工作区有未提交改动，提示先运行 `/git-commit`。
若远端分支不存在，提示先运行 `/git-commit` 完成 push。

#### 第二步：收集 diff 信息

```bash
git log origin/master..HEAD --oneline         # commit 列表
git diff origin/master...HEAD --stat          # 文件级改动统计
git diff origin/master...HEAD                 # 完整 diff（提取核心片段用）
```

#### 第三步：创建 Pull Request

全程非交互式，不打开浏览器：

```bash
gh pr create \
  --base master \
  --title "<从 commit message 提取的一句话标题>" \
  --body "<一到三句话概括改动内容>" \
  --no-maintainer-edit
```

- `--title` 和 `--body` 必须完整填入，不留空占位符
- 禁止使用 `--fill`（触发交互编辑器）
- 若 PR 已存在，用 `gh pr view --json url,number -q '"\(.number) \(.url)"'` 获取，不重复创建

#### 第四步：在对话中展示 diff，等待 review

```
PR #<number> <PR URL>

改动文件（X 新增 / Y 修改）：
  src/auth/login.ts    （新增，+38）  JWT 登录接口，签发 access/refresh token
  src/auth/refresh.ts  （新增，+15）  用 refresh token 换取新 access token
  src/routes/index.ts  （修改，+3）   注册登录相关路由

核心逻辑：
  [最能体现改动意图的关键代码片段，10-20 行，不贴完整 diff]

回复"approve"合并，或告诉我需要调整什么。
```

diff 摘要原则：
- 文件清单列全，每个文件一句话说明改了什么
- 核心片段只取最能体现意图的部分
- 改动极简单时（如只改配置、只加路由）可省略代码片段

#### 第五步：处理用户回复

**用户 approve**（"ok"、"没问题"、"合并"、"lgtm" 等均视为确认）：

```bash
gh pr review --approve -b "LGTM"
gh pr merge --merge --delete-branch
```

```
已合并 #<number>，分支 feat/<name> 已删除。
运行 /deploy 部署到线上。
```

**用户提出修改意见**：记录要求，回到实现阶段修改，完成后重新触发 `/git-commit` → `/git-pr`。

### 故障排查

遇到任何失败，不要直接退出，按错误类型引导用户排查：

#### remote 使用 HTTPS

```
检测到 remote 使用 HTTPS，需切换为 SSH。确认 SSH key 已添加到 GitHub 后运行：

  git remote set-url origin git@github.com:<org>/<repo>.git

切换后告诉我，我会重新尝试。
```

#### Permission denied (publickey)

依次询问用户：
1. "本机是否已生成 SSH key？运行 `ls ~/.ssh/id_*.pub` 确认。"
2. "SSH key 是否已添加到 GitHub？Settings → SSH and GPG keys 查看。"
3. "运行 `ssh -T git@github.com` 的输出是什么？"

根据回答给出修复命令：
- 未生成 key：`ssh-keygen -t ed25519 -C "your@email.com"`
- key 未加到 GitHub：引导复制 `~/.ssh/id_ed25519.pub` 添加到 GitHub
- ssh-agent 未加载：`eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519`

#### Connection timed out

询问："运行 `curl -I https://github.com` 能否正常返回？"
若网络正常但 SSH 超时，建议 SSH over HTTPS（443 端口）：

```
# ~/.ssh/config 添加：
Host github.com
  Hostname ssh.github.com
  Port 443
```

#### gh CLI 未登录

```bash
gh auth status   # 查看状态
gh auth login    # 重新登录（协议选 SSH）
```

#### 未知错误

展示完整错误信息，询问："出现这个错误前你做了什么操作？"

### 注意事项

- 只能从 feature/fix/refactor 分支发起 PR，禁止从 master 发 PR
- review 在对话中完成，GitHub PR 作为审计记录保留
- 本 skill 不负责 push，push 由 `/git-commit` 完成

### 前置依赖

- `gh` CLI 已安装：`brew install gh`（Linux 参考 https://github.com/cli/cli）
- 已通过 SSH 登录 GitHub：`gh auth login`（协议选 SSH）

### 示例触发语

- "/git-pr"（由 /git-commit 用户确认后触发）
- "帮我发起 PR"
