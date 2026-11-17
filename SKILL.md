---
name: okgo
description: Use when starting a project from scratch, rebuilding a module, or standing up a new subsystem; when asked what order to build things in, what documents a new repo needs, or how to write AGENTS.md rules; or when a project has no acceptance criteria, no walking skeleton, no delivery gates, or no independent review. Triggers 新项目、立项、从零开始、greenfield、开发顺序、项目流程、AGENTS.md 模板、验收清单、交付门禁.
---

# okgo — 新项目开发流程

把「想法 → 可交付项目」固化为 **6 个阶段、3 道闸门、1 套文档**。

分工只有一句：**规则写进项目根 `AGENTS.md`，执行路径写进 `docs/architecture/workflow.md`**。
本技能同时提供这两份文件的模板与全套片段模板。

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

## 落地三步（先做这个，再谈实现）

1. `references/agents-template.md` → 复制为项目根 `AGENTS.md`；替换所有 `{{...}}` 占位符；删掉不适用的门禁，但 **lint / type-check / test / build / 依赖检查不得删**。
2. `references/workflow-manual.md` → 复制为 `docs/architecture/workflow.md`；在 `docs/design/README.md` 的索引里登记。
3. 按下面的阶段推进，每阶段过闸门；需要片段时从 `assets/` 取，不要手搓格式。

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
| `references/workflow-manual.md` | 完整流程手册，落地为 `docs/architecture/workflow.md` |
| `references/agents-template.md` | `AGENTS.md` 全文模板，落地为项目根规则 |
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
