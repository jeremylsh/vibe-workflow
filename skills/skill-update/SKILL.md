---
name: skill-update
description: 重新运行 vibe-workflow 安装脚本，将本地 skills 更新到远端 master 的最新版本。会覆盖本地 skill 文件，必须由用户手动输入 /skill-update 触发，不得自动调用。
command: /skill-update
---

## Skill Update 助手

将本地安装的 vibe-workflow skills 更新到远端 master 的最新版本。

**注意**：此命令会覆盖本地 skill 文件，执行前确认本地无未提交的 skill 改动。

### 工作流程

#### 第一步：执行安装脚本

```bash
curl -fsSL https://raw.githubusercontent.com/jeremylsh/vibe-workflow/master/install.sh | bash
```

实时输出安装脚本的执行日志。

#### 第二步：输出结果

成功：

```
Skills 已更新到最新版本。
```

失败：展示完整错误输出，不重试，等待用户处理。

### 注意事项

- 只响应用户手动输入的 `/skill-update` 命令，不得由其他 skill 自动调用
- 执行前无需额外确认，用户手动输入命令本身即视为确认
