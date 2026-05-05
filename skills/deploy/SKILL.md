---
name: deploy
description: 在 master 分支打好版本 tag 后，将该 tag 对应的代码部署到线上环境。
command: /deploy
---

## Deploy 助手

本 skill 在用户 merge PR 后手动触发，负责将 master 最新代码部署到线上环境。**每次生产部署必须对应一个版本 tag**，确保所有发布均可追溯。

### 工作流程

#### 第一步：前置检查

```bash
# 确认 deploy.sh 存在且可执行
ls -la deploy.sh

# 确认 git 状态干净
git status
```

若 deploy.sh 不存在，停止并提示：项目根目录下需要有 `deploy.sh` 文件。

#### 第二步：拉取最新 master

```bash
git fetch origin
git checkout master
git pull origin master --ff-only
```

使用 `--ff-only` 确保只做 fast-forward，若遇到冲突立即停止并报告，不自动 merge。

#### 第三步：检查版本 tag

```bash
# 获取当前 HEAD 的 commit hash
HEAD_COMMIT=$(git rev-parse HEAD)

# 检查该 commit 是否已有 tag
git tag --points-at HEAD
```

- **有 tag**：使用该 tag 作为本次部署版本，继续下一步。
- **没有 tag**：**停止部署**，提示用户：

```
## 需要先打版本 tag

当前 master HEAD (abc1234) 尚未打版本 tag。
生产部署必须对应一个版本号，请先运行 /git-tag 完成打标后再执行 /deploy。
```

> 每次生产发布都必须有对应的 tag，这是代码可追溯的基础。

#### 第四步：确认部署

输出当前将要部署的版本信息，**等待用户确认**后再执行：

```
## 即将部署

**版本 tag**: v1.2.0
**Commit**: abc1234 feat(auth): add JWT login flow
**时间**: 2026-05-04 10:45
**作者**: Jeremy

确认部署？(直接回复"是"或"确认"继续)
```

#### 第五步：执行部署

```bash
bash deploy.sh 2>&1
```

实时输出 deploy.sh 的执行日志。

#### 第六步：输出部署结果

部署成功：

```
## 部署成功

**版本**: v1.2.0 (abc1234)
**耗时**: 42s

线上已运行 v1.2.0，请验证线上功能是否正常。
若发现问题，运行 /rollback 可快速回滚到上一个稳定版本。
```

部署失败：

```
## 部署失败

**版本**: v1.2.0 (abc1234)
**错误信息**: [deploy.sh 的错误输出]

deploy.sh 以非零退出码结束，线上环境未变更。
请检查错误信息，修复后重新运行 /deploy。
```

### deploy.sh 规范

各项目的 `deploy.sh` 需遵循以下约定：
- 成功时退出码为 `0`
- 失败时退出码为非 `0`
- 部署过程中的关键步骤打印到 stdout

### 注意事项

- 部署前必须有版本 tag，无 tag 需先运行 `/git-tag`
- 部署前必须等待用户确认，避免误触发
- 使用 `--ff-only` 拉取，确保 master 分支历史干净
- deploy.sh 执行失败时不重试，报告错误等待人工处理
- 不修改 deploy.sh 本身，只负责调用

### 示例触发语

- "/deploy"
- "帮我部署"
- "PR 合了，部署一下"
- "上线最新代码"
