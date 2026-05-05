---
name: deploy
description: 拉取最新 master 分支代码，运行项目标准的 deploy.sh 脚本完成部署，输出部署结果。
command: /deploy
---

## Deploy 助手

本 skill 在用户 merge PR 后手动触发，负责将最新 master 代码部署到线上环境。运行环境为部署服务器（deploy agent 所在机器）。

### 工作流程

#### 第一步：前置检查

```bash
# 确认在项目根目录
pwd

# 确认 deploy.sh 存在且可执行
ls -la deploy.sh

# 确认 git 状态干净
git status
```

若 deploy.sh 不存在，停止并提示用户：项目根目录下需要有 `deploy.sh` 文件。

#### 第二步：拉取最新 master

```bash
git fetch origin
git checkout master
git pull origin master --ff-only
```

使用 `--ff-only` 确保只做 fast-forward，若遇到冲突立即停止并报告，不自动 merge。

拉取后输出最新的 commit 信息：

```bash
git log -3 --oneline
```

#### 第三步：确认部署

输出当前将要部署的版本信息，**等待用户确认**后再执行：

```
## 即将部署

**最新 commit**: abc1234 feat(auth): add JWT login flow
**时间**: 2000-01-01 10:30
**作者**: Jeremy

确认部署？(直接回复"是"或"确认"继续)
```

#### 第四步：执行部署

```bash
bash deploy.sh 2>&1
```

实时输出 deploy.sh 的执行日志。

#### 第五步：输出部署结果

部署成功：

```
## 部署成功

**版本**: abc1234 feat(auth): add JWT login flow
**耗时**: 42s

请验证线上功能是否正常。
验证通过后运行 /git-tag 打版本 tag。
```

部署失败：

```
## 部署失败

**错误信息**: [deploy.sh 的错误输出]

deploy.sh 以非零退出码结束，线上环境未变更。
请检查错误信息，修复后重新运行 /deploy。
```

### deploy.sh 规范

各项目的 `deploy.sh` 需遵循以下约定，以便本 skill 正确判断部署结果：
- 成功时退出码为 `0`
- 失败时退出码为非 `0`
- 部署过程中的关键步骤打印到 stdout

### 注意事项

- 部署前必须等待用户确认，避免误触发
- 使用 `--ff-only` 拉取，确保 master 分支历史干净
- deploy.sh 执行失败时不重试，报告错误等待人工处理
- 不修改 deploy.sh 本身，只负责调用

### 示例触发语

- "/deploy"
- "帮我部署"
- "PR 合了，部署一下"
- "上线最新代码"
