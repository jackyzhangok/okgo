---
name: okgo
description: Use when starting a project from scratch, rebuilding a module, or standing up a new subsystem; when asked what order to build things in, what documents a new repo needs, or how to write or auto-create AGENTS.md rules; or when a project has no AGENTS.md, no acceptance criteria, no walking skeleton, no delivery gates, or no independent review. Triggers 新项目、立项、从零开始、greenfield、开发顺序、项目流程、AGENTS.md 模板、自动创建 AGENTS.md、验收清单、交付门禁.
---

# okgo — 新项目开发流程

把「想法 → 可交付项目」固化为 **6 个阶段、3 道闸门、1 套文档**。

分工只有一句：**规则写进项目根 `AGENTS.md`，执行路径写进 `docs/architecture/workflow.md`**。
本技能会**自动创建这两份文件**（模板在 `references/`，片段在 `assets/`），用户不需要复制粘贴。

## 三条铁律

1. **没有验收标准，不进入实现。**
2. **没有先失败的测试，不写生产代码。**
3. **没有独立复核，不宣布完成。**

违反任一条时，回到上一步，不要「先做着看」。

## 何时使用

- 新项目、新子系统、需要重建的旧模块（默认 L2，不得降级）
- 团队或 AI 需要一份「先做什么、后做什么、产出什么、怎么证明做完了」的共识
- 仓库缺 `AGENTS.md`、缺验收清单、缺门禁、缺复核环节
- 要把这套流程落成仓库里的 `AGENTS.md` + `docs/architecture/workflow.md`

**不适用**：单文件小改、修 typo、已有流程下的 L0/L1 小修（除非任务就是把流程落地到仓库）。

## 启动动作：自动生成 AGENTS.md（不要让用户复制粘贴）

当前项目没有 `AGENTS.md` 时，**由你直接创建**。禁止输出「请把模板复制到项目根」让用户自己动手。

仅在任务涉及**新项目、立项或要求落地规则**时创建；用户只是咨询流程问题，不必创建。

**1. 检测（命中即停）**

- 项目根已有 `AGENTS.md` → 直接使用，不新建、不覆盖；
- 向上找到仓库根 / 工作区根的 `AGENTS.md` → 使用它，不重复创建；
- 都没有 → 进入第 2 步。

**2. 生成**

读取 `references/agents-template.md`，写到项目根 `AGENTS.md`。只填能确定的事实：

| 占位符 | 来源 |
|---|---|
| `{{PROJECT_NAME}}` | `package.json` 的 `name`，否则目录名 |
| `{{PKG_MANAGER}}` | 锁文件：`pnpm-lock.yaml`→pnpm、`yarn.lock`→yarn、`bun.lockb`→bun、`package-lock.json`→npm |
| `{{LANGUAGE_RUNTIME}}` / `{{FRAMEWORK}}` / `{{DATABASE}}` | `package.json`、`pyproject.toml`、`go.mod`、`Cargo.toml`、`composer.json`、`.nvmrc` / `.python-version`、`docker-compose.yml`、`.env.example` |
| `{{DEV_CMD}}` 等命令 | 只填构建文件里**真实存在**的脚本；没有就写 `待确认` |

规则：

- **不编造**命令、端口、数据库；确不定就写 `待确认`，并在文末追加「待确认项」清单（定稿后删除）。
- 生成的文件里**不得残留 `{{...}}`**。
- 删掉不适用的门禁条目，但 **lint / type-check / test / build / 依赖检查不得删**。

**3. 收尾**

- 回报：`已创建 <路径>`、填了哪些项、待确认几项；
- 已有 `AGENTS.md` 时：读取并列出缺哪些章节/门禁，问是否补，**绝不整体覆盖**；
- 不自动 commit（除非用户要求）。

**4. 一并落地流程文档（默认执行，已存在则跳过）**

- `docs/architecture/workflow.md` ← `references/workflow-manual.md`；
- `docs/design/README.md`：不存在则创建，并登记 workflow 的索引行；
- 阶段 0 的其余骨架（`readme.md` / `prd.md` / `project_plan.md` / `docs/plans/` / `changes/` / `artifacts/ui/`）在用户确认「按阶段 0 起步」后创建，**不覆盖已有文件**。

之后按下面的阶段推进，每阶段过闸门；需要片段时从 `assets/` 取，不要手搓格式。

## 安装 / 升级自己（不要让用户复制目录）

用户说「安装 okgo」「升级 okgo」「装到某工具」时，**你直接执行**：复制、校验、建软链、报告调用方式。

```bash
# 已有本仓库
bash scripts/install.sh

# 只有 GitHub 地址
git clone --depth 1 https://github.com/jackyzhangok/okgo.git ~/.agents/skills/okgo
bash ~/.agents/skills/okgo/scripts/install.sh

# 装到指定工具
bash scripts/install.sh ~/.dsh/skills/okgo
```

脚本行为（已是默认）：

- 复制 `SKILL.md` / `readme.md` / `references/` / `assets/` / `scripts/`；
- 校验 `name: okgo` 与必备文件，失败即报错退出；
- 对**已存在**的工具技能目录建 `okgo` 软链；已存在的同名目录**不覆盖**，只报告；
- 打印 `/okgo`、`$okgo`、`@okgo` 的调用提示。

禁止：让用户自己解压/复制目录、让用户手动建软链、安装后不验证。

## 阶段与闸门

| # | 阶段 | 关键产出 | 闸门 |
|---|---|---|---|
| 0 | 立项准备 | 仓库能跑：`install → check → build → serve`；文档骨架；CI 只调一条 `check` | — |
| 1 | 契约与验收 | 任务契约 + 验收清单（功能/边界/集成/卫生）+ 规格 | **闸门 1：用户确认目标与验收项** |
| 2 | 设计 | `design.md`（数据/接口/权限/失败/安全）；有 UI 时设计系统 | **闸门 2：用户 review 设计** |
| 3 | 计划 | 可执行的 TDD 步骤级 task，Task 1 是 walking skeleton | 计划可执行 |
| 4 | 骨架 + 分片实现 | 每 task：红 → 绿 → 回归 → 提交 | 测试先红后绿 |
| 5 | 自动闸门 | `check` + `build` + `serve` + E2E + 截图 + 卫生扫描 | 全绿且有本次证据 |
| 6 | 独立复核 | 验收条目表 + 缺陷单 → 修复 → 再复核 → 交付卡片 | **闸门 3：独立复核通过** |

## 不可协商的约束

- **规模预算**：单次变更 ≤8 文件、净增 ≤400 行；超出**动手前**确认并拆分。
- **新增依赖先问**，并说明现有依赖为什么不够。
- **测试不可投机**：不得改/放宽/删断言让门禁变绿；改动测试必须单独列出理由。
- **文档与代码同轮完成**，未同步 = 未完成。
- **完成 = 证据**：本次运行的命令、退出码、关键输出、截图路径；「应该没问题」不算完成。
- **永不编造**：API、路径、命令、依赖名、测试结果，不确定就查或说不知道。
- **复核者不改代码**，改了就要换人复核；L2 不得自我豁免。

## 需要用户拍板时才停

worktree 是否隔离、执行方式（单人 / 每 task 双上下文）、加依赖、超预算、改门禁阈值或基线、UI 视觉方向、合并策略。

其余情况（规格未覆盖的取舍）**不要停下来问**：做决定并留痕。

```text
Ruling: <决定> — <理由> — <错了的代价>
```

## 红色信号（出现即停手）

| 想法/动作 | 现实 |
|---|---|
| 「验收标准先不写，边做边定」 | 没有验收标准的实现无法判定完成 |
| 「先写实现，回头补测试」 | 删掉重来，不保留当参考 |
| 「只跑相关测试就够了」 | 未跑全量 = 未验证 |
| 「改个断言就能过」 | 这是伪造证据，不是修复 |
| 「前端隐藏了就安全了」 | 后端未授权 = 漏洞 |
| 「文档最后一起补」 | 最后通常不会补 |
| 「我自己看过，没问题」 | 实现者自查不算独立复核 |

## 文件导航

| 文件 | 用途 |
|---|---|
| `readme.md` | **使用方法与完整流程**（安装到各工具、三步落地、阶段详解、FAQ） |
| `scripts/install.sh` | **一键安装/升级**：复制、校验、软链到已有工具目录、打印调用方式 |
| `references/workflow-manual.md` | 完整流程手册，落地为 `docs/architecture/workflow.md` |
| `references/agents-template.md` | `AGENTS.md` 全文模板；由你读取后**自动生成**项目根 `AGENTS.md`，不是给用户复制的 |
| `assets/task-contract.md` | 任务契约片段 |
| `assets/acceptance-checklist.md` | 验收清单片段（功能/边界/集成/卫生） |
| `assets/requirement.md` | Requirement + Scenario 片段 |
| `assets/plan-task.md` | 计划中的单个 task 片段 |
| `assets/delivery-card.md` | 交付卡片片段 |
| `assets/defect-report.md` | 缺陷单片段 |

## 常见错误

| 错误 | 修正 |
|---|---|
| 把 L2 新项目当 L1 直接开写 | 新项目默认 L2，只升不降 |
| 计划按「模块」拆而不是按「可验证行为」拆 | 每个 task 一个可测行为 + 一个提交 |
| 门禁本地一套、CI 一套 | CI 只调用同一条 `check` |
| 用「不适用」搪塞验收项 | 只能填：通过 / 不适用（附理由）/ 未验证（附原因与建议验法） |
| 复核只读代码不跑命令 | 每个「通过」必须给可复现证据 |
