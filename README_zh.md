# Superspec（中文说明）

**规格驱动开发 + 超级能力**

Superspec 是一个面向 AI 编程 CLI 的代理技能，将
[spec-kit](https://github.com/github/spec-kit) 项目治理与
[obra/superpowers](https://github.com/obra/superpowers) 代理能力
统一到一个开发工作流中。它兼容所有支持 spec-kit 的编程代理，
包括 [Claude Code](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code)、
[Codex CLI](https://github.com/openai/codex) 等。

Spec-kit 提供文档结构和治理（宪章、规格、计划、任务）。
Superpowers 提供深度澄清（头脑风暴）、智能任务拆解（计划编写）和工程执行纪律（TDD、子代理驱动开发、代码审查）。

## 架构概览

![AI助力: 端到端开发工作流（SDD）](assets/workflow-overview-zh.png)

工作流编排 6 个阶段——从项目定义到工程实现——spec-kit 负责治理文档，superpowers 提供智能澄清、任务拆解和执行能力。

## 安装

### 快速安装

```bash
# 克隆仓库
git clone https://github.com/WangX0111/superspec.git

# 安装到代理的技能目录（选择其一）：
# Claude Code
ln -sf "$(pwd)/superspec" ~/.claude/skills/superspec
# Codex CLI
ln -sf "$(pwd)/superspec" ~/.codex/skills/superspec
# 其他代理（通用约定）
ln -sf "$(pwd)/superspec" ~/.agents/skills/superspec
```

### 手动安装

将整个 `superspec/` 目录复制到代理的技能目录。各平台常见路径：

| 代理 | 技能目录 |
|------|---------|
| Claude Code | `~/.claude/skills/superspec` |
| Codex CLI | `~/.codex/skills/superspec` |
| 其他 | `~/.agents/skills/superspec` 或查阅代理文档 |

### 可选：安装 Superpowers

Superspec 可以独立工作，但安装 superpowers 技能可获得增强能力：

```bash
# 安装 obra/superpowers（具体方式请参见其仓库）
# 技能应放置在 ~/.agents/skills/ 或 .agents/skills/
```

## 命令列表

| 命令 | 说明 |
|------|------|
| `/speckit.superspec.status` | 显示当前进度并建议下一步操作 |
| `/speckit.constitution` | 创建或更新项目治理原则 |
| `/speckit.specify` | 创建功能规格（含用户故事） |
| `/speckit.superspec.brainstorm` | 深入探索边界情况，完善规格文档 |
| `/speckit.plan` | 创建技术实现方案 |
| `/speckit.superspec.tasks` | 生成分阶段任务清单 |
| `/speckit.superspec.execute` | 以 TDD + 子代理编排方式执行实现 |
| `/speckit.superspec.review` | 对照规格进行代码审查 |
| `/speckit.checklist` | 生成上下文相关的检查清单 |

## 可中断恢复

所有项目状态以纯文本（Markdown + YAML）持久化——治理资产（宪章）在 `.specify/memory/` 下，
每个功能的状态（规格、计划、任务、进度）在 `specs/NNN-*/` 下。
会话中断时——代理超时、用户离开、CLI 崩溃——不会丢失任何进度。
在新会话中运行 `/speckit.superspec.status` 即可查看中断点：

```
Superspec 项目状态
==================
宪章: 已完成
功能:
  001-user-auth    [####------] 执行中 (阶段 5/6) — 11/19 任务完成
  002-photo-upload [##--------] 头脑风暴 (阶段 2/6) — 2 个待解决问题

建议下一步: /speckit.superspec.execute 001
```

每个命令会自动检测之前的进度并从中断点恢复——跳过已完成的工作，从未解决的问题或未完成的任务继续。

## 快速开始

### 1. 初始化项目治理

```
/speckit.constitution 我的项目
```

创建 `.specify/` 目录结构，并引导你定义核心原则、技术栈和质量门禁。

### 2. 编写第一个功能规格

```
/speckit.specify "用户邮箱密码登录认证"
```

在 `specs/001-user-authentication/spec.md` 创建功能规格，包含用户故事、需求和成功标准。

### 3. 头脑风暴边界情况

```
/speckit.superspec.brainstorm specs/001-user-authentication/spec.md
```

代理逐个提出探索性问题，发现你可能没有想到的边界条件、错误场景、安全隐患和用户体验陷阱。

### 4. 规划与执行

```
/speckit.plan                  # 创建技术实现方案
/speckit.superspec.tasks                 # 生成任务拆解
/speckit.superspec.execute               # 以 TDD 纪律和检查点方式实现
/speckit.superspec.review                # 对照规格验证实现
```

## 真实样例

想看 spec-kit + superspec 实际跑完一遍的成果？查看
[`examples/static-landing-page/`](examples/static-landing-page/) ——
这是一次真实 Claude Code 会话完整走完 7 阶段（宪章 → 规格 → 头脑风暴 →
计划 → 任务 → 执行 → 审查）后落到磁盘上的所有产物原样副本。

直接用浏览器打开
[`examples/static-landing-page/web/index.html`](examples/static-landing-page/web/index.html)
即可看到 AI 生成的落地页。配套
[样例 README](examples/static-landing-page/README.md) 详细说明了产生过程，
以及如何用 [`scripts/e2e-agent-claude.sh`](scripts/e2e-agent-claude.sh)
复现这次快照。

## 工作流

```
宪章 → 规格 → 头脑风暴 → 计划 → 任务 → 执行 → 审查
                ↑     ↓
                └─────┘（反复迭代直到规格完善）
```

每个阶段都有明确的门禁——在推进前验证前置条件。人工检查点确保你控制推进节奏。

## Superpowers 集成

当安装了 obra/superpowers 技能时，superspec 会自动检测并使用：

| Superspec 命令 | 增强来源 | 降级方案 |
|----------------|----------|----------|
| `brainstorm` | `brainstorming` 技能 | 内置提问协议 |
| `tasks` | `writing-plans` 技能 | 基于模板的拆解 |
| `execute` | `executing-plans` + `subagent-driven-development` + `test-driven-development` | 顺序执行+手动确认 |
| `review` | `requesting-code-review` 技能 | 内置审查清单 |

详见 [superpowers-bridge.md](references/superpowers-bridge.md)。

## 许可证

MIT
