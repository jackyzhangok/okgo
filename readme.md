# okgo — 新项目开发流程包

> “**许愿式项目开发**”[新项目从零到交付]的标准流程包：**6 个阶段、3 道闸门、1 套文档**。
> 一份技能，四种工具通用：**WorkBuddy / Cursor / Codex / DeepSeek Harness（DSH）**，也兼容 Claude Code 等任何支持 `SKILL.md` 的 agent。
> 安装只需一句：「安装 okgo 技能：`https://github.com/jackyzhangok/okgo`」——自动克隆、校验、软链，不用复制。
> 新项目里说一句「按 okgo 启动」，它会**自动建立 `AGENTS.md`** 和流程文档，不用你复制模板。
> 想「一句话做完」，说「**许愿模式**」：默认决策 + 自检闸门 + 自动复核（见第 6 节）。
> 本文件是**使用方法与流程图**；细则看 `references/`，片段模板看 `assets/`。

---

## 1. 它解决什么问题

新项目最常见的失败不是「不会写代码」，而是：

- 没写验收标准就开始写，做完说不清是否完成；
- 文档散落在会话里，换个人/AI 接手就重来；
- 门禁一套在本地、一套在 CI，两边绿灯但线上炸；
- 测试为了变绿被改宽，缺陷被「绿」掩盖；
- 自己审自己，宣布完成。

这个技能把上述问题变成**可执行的顺序 + 可复现的证据**。核心公式：

```text
完整性 = 可枚举的验收清单 × 自动化检查 × 独立复核
```

---

## 2. 目录结构

```text
okgo/
├── SKILL.md                        # 技能入口：何时用、三条铁律、自动生成 AGENTS.md、阶段闸门
├── readme.md                       # 本文件：安装、使用方法、完整流程
├── references/
│   ├── workflow-manual.md          # 完整流程手册 → 自动落地为 docs/architecture/workflow.md
│   ├── wish-mode.md                # 许愿模式协议：默认决策、自检闸门、自动复核、硬停条件
│   └── agents-template.md          # 项目规则模板 → agent 自动生成为项目根 AGENTS.md
├── scripts/
│   └── install.sh                  # 一键安装/升级：复制、校验、软链到已有工具目录
└── assets/
    ├── task-contract.md            # 任务契约片段
    ├── acceptance-checklist.md     # 验收清单片段（功能/边界/集成/卫生）
    ├── assumption-ledger.md        # 假设账本片段（wish 模式必填）
    ├── requirement.md              # Requirement + Scenario 片段
    ├── plan-task.md                # 计划中的单个 task 片段
    ├── delivery-card.md            # 交付卡片片段
    └── defect-report.md            # 缺陷单片段

dist/okgo.zip                       # 打包产物：整个技能压成的分发包（可直接导入/上传）
```

> `dist/` 只是分发副本，不属于技能规范的一部分；解压后仍以 `okgo/SKILL.md` 为根。

遵循 [Agent Skills 规范](https://agentskills.io/specification)：`SKILL.md` 必需，`references/`、`assets/`、`scripts/` 可选。**没有运行时专属依赖**，文件路径一律相对于技能目录解析，因此可以整体复制、软链或打包分发。

分工一句话：**A 讲「怎么走」（流程手册），B 讲「必须遵守什么」（`AGENTS.md`）**。

---

## 3. 安装与调用

安装分两步：**把技能放到工具能找到的位置**，再**按该工具的方式调用**。装好不等于会用——四个工具的调用语法不同，见 3.2 / 3.3。

### 3.0 一条指令安装（零复制，推荐）

对 agent 直接说：

```text
安装 okgo 技能：https://github.com/jackyzhangok/okgo
```

它会自己完成：克隆到 `~/.agents/skills/okgo` → 校验 `name: okgo` 与必备文件 → 给**已存在**的工具技能目录建软链 → 报告调用方式。你不用复制、解压、建软链。

想自己敲命令也可以，一行：

```bash
git clone --depth 1 https://github.com/jackyzhangok/okgo.git ~/.agents/skills/okgo \
  && bash ~/.agents/skills/okgo/scripts/install.sh
```

`scripts/install.sh` 做四件事：

1. 复制 `SKILL.md` / `readme.md` / `references/` / `assets/` / `scripts/`；
2. 校验技能名与必备文件，不一致就报错退出；
3. 对 `~/.dsh/skills`、`~/.agents/skills`、`~/.cursor/skills`、`~/.codex/skills`、`~/.claude/skills`、`~/.workbuddy/skills`、`~/.codebuddy/skills` 中**已存在**的目录建 `okgo` 软链；已存在的同名目录**不覆盖**；
4. 打印 `/okgo`、`$okgo`、`@okgo` 的调用提示。

| 需求 | 命令 |
|---|---|
| 默认安装（跨工具共用目录） | `bash scripts/install.sh` |
| 装到指定工具 | `bash scripts/install.sh ~/.dsh/skills/okgo` |
| 只安装、不建软链 | `bash scripts/install.sh --no-link` |
| 升级 | 再跑一次（覆盖技能文件；不动项目里的 `AGENTS.md`） |

### 3.1 安装路径

整个 `okgo/` 目录放进对应目录即可，无需改任何内容。推荐直接用 3.0 的脚本，它会一次装好并建好软链。

| 工具 | 用户级（全局） | 项目级（随仓库走） |
|---|---|---|
| **WorkBuddy** | `~/.workbuddy/skills/okgo/` | `<项目>/.workbuddy/skills/okgo/` |
| **CodeBuddy IDE** | `~/.codebuddy/skills/okgo/` | `<项目>/.codebuddy/skills/okgo/` |
| **Cursor** | `~/.cursor/skills/okgo/` | `<项目>/.cursor/skills/okgo/` |
| **Codex CLI** | `~/.codex/skills/okgo/` | `<项目>/.codex/skills/okgo/` |
| **DeepSeek Harness（DSH）** | `~/.dsh/skills/okgo/` | `<仓库>/.dsh/skills/okgo/` |
| **Claude Code** | `~/.claude/skills/okgo/` | `<项目>/.claude/skills/okgo/` |
| **跨工具共用** | `~/.agents/skills/okgo/` | `<项目>/.agents/skills/okgo/` |

说明：

- **只想维护一份**：放在 `~/.agents/skills/`，再软链到各工具目录（`ln -s`），避免多处副本漂移。
- **团队共享**：把技能目录提交进仓库，用项目级路径（如 `.cursor/skills/`、`.codex/skills/`），新人克隆即生效。
- **打包分发**：`dist/okgo.zip` 可直接上传导入（WorkBuddy 支持「上传/导入技能包」），其他工具解压后放到上表目录即可。
- **不支持 skills 的工具**：把 `SKILL.md` 的内容贴进该工具的项目规则文件（如 `.cursor/rules/*.mdc`、`AGENTS.md`、自定义 system prompt），`references/` 作为随仓库文档保留。

### 3.2 三种调用方式

支持 `SKILL.md` 的工具都采用**渐进式披露**：平时只把 `name` + `description` 放进上下文（约 100 词），命中后才读 `SKILL.md`，`references/`、`assets/` 再按需读取。所以「装了没反应」通常是描述没命中，不是没装上。

| 方式 | 怎么发生 | 什么时候用 |
|---|---|---|
| **自动触发** | 描述命中 `description` 里的触发词（新项目、立项、AGENTS.md、验收清单、开发顺序…） | 日常首选，最省事 |
| **显式调用** | 用该工具的语法点名技能（见 3.3），或直接说「用 okgo 技能」 | 首轮就要用，或技能被别的技能抢走 |
| **手动兜底** | 把 `SKILL.md` 贴进对话/规则文件，`references/` 按路径引用 | 工具不支持 skills，或临时会话 |

### 3.3 各工具怎么调用

| 工具 | 显式调用 | 自动触发 | 要点 |
|---|---|---|---|
| **WorkBuddy / CodeBuddy** | 输入 `/` 选 `okgo`；或对话里点名「用 okgo 技能」 | 描述匹配即自动调用 | `@` 是引用文件，不是调技能 |
| **Cursor** | `/okgo` 运行；`@okgo` 作为上下文附加 | 启动时自动发现，Agent 自行判断 | `/okgo` 只作用于当前一条消息 |
| **Codex CLI / IDE** | `$okgo`（如 `$okgo 帮我启动新项目`） | 描述匹配自动选择 | `/` 保留给内置命令，不能自定义斜杠 |
| **DSH** | `/okgo` 斜杠命令；或说「使用 okgo 技能」 | 会话注入技能目录，命中后加载 | 模型与 `/` 默认都可调用 |

#### WorkBuddy / CodeBuddy

1. 在对话输入框输入 `/`，在技能列表里选 `okgo`；
2. 或直接说：「用 okgo 技能，帮我启动一个…」；
3. 自动触发靠 `description` 的触发词，命中「新项目 / 立项 / AGENTS.md / 验收清单」等会自行调用；
4. 在 **设置 → Skills** 可查看、启用/禁用、导入（`dist/okgo.zip` 可直接上传）。

> 装多了技能容易被别的技能抢走；这时在提示词里点名「用 okgo 技能」即可纠偏。

#### Cursor

1. 在 Agent 聊天框输入 `/`，搜索并选择 `okgo` —— 只附加到这一条消息；
2. 输入 `@okgo` 把它作为上下文附加；
3. 想整个会话常驻：选中后按 `Option+Enter`（Mac）/ `Alt+Enter`（Windows）作为 Custom Mode；
4. 启动时 Cursor 自动发现 `.cursor/skills/`、`.agents/skills/`，也会按描述自行判断。

#### Codex CLI / IDE

1. 在提示词里写 `$okgo`（例：`$okgo 帮我启动新项目`）；
2. 输入 `/skills` 查看已加载技能，确认 `okgo` 在列表里；
3. 不提 `$okgo` 时，Codex 也会按 `description` 隐式选择；
4. 项目级技能放 `.codex/skills/okgo/` 或 `.agents/skills/okgo/`，Codex 从仓库根扫描。

> Codex 的 `/` 是内置命令（`/skills`、`/model`、`/plan` 等），**不能**用 `/okgo` 调用自定义技能——必须用 `$okgo`。

#### DSH

1. 输入框输入 `/` 选择技能（发送后自动加载），或直接说「使用 okgo 技能」；
2. 模型侧：会话注入技能目录（名称+描述），命中后调用 `skill` 工具读正文；
3. 默认 `okgo` 对模型可见、`/okgo` 可调用；如需限制，在 frontmatter 加 `disable-model-invocation: true`（模型不可见）或 `user-invocable: false`（`/` 不可用）。

### 3.4 没触发时怎么办

按顺序排查：

1. **确认已安装**：用 3.5 的 `ls` 检查目录；
2. **显式调用**：按 3.3 用 `/okgo`、`@okgo`、`$okgo`，或直接点名；
3. **首句点名**：把「使用 okgo 技能」放在第一句，避免长会话里技能描述被压缩；
4. **换短会话**：上下文过长时技能目录可能被摘要掉，新开会话再试；
5. **手动兜底**：把 `SKILL.md` 贴进对话，或让 agent 直接读路径：

```text
读取 okgo 技能：~/.agents/skills/okgo/SKILL.md，按其中流程执行
```

### 3.5 验证安装与调用

```bash
# 确认四个目录/文件都在（路径按你的工具替换）
ls ~/.dsh/skills/okgo/{SKILL.md,readme.md,references,assets}
```

行为信号（出现任意两条，说明已加载）：

- 发现没有 `AGENTS.md` 时**直接创建**，而不是让你去复制模板；
- 许愿模式下先给**假设账本**，再开工，不反复确认可推断的信息；
- 先要验收标准、先问 5 个问题，而不是直接写代码；
- 提到阶段、闸门、`AGENTS.md`、验收清单；
- 主动去读 `references/workflow-manual.md` 或 `assets/*`；
- 交付时给命令、退出码、截图路径，而不是「应该没问题」。

反信号：不问验收标准直接开写、输出泛泛的「最佳实践」→ 技能没加载，按 3.4 显式调用。

---

## 4. 使用方法：落地到新项目

**自动化边界**（能自动的都不让你动手）：

| 动作 | 谁做 |
|---|---|
| 安装 / 升级技能 | agent 自动（`scripts/install.sh`） |
| 检测并创建 `AGENTS.md` | agent 自动，已有不覆盖 |
| 填充占位符 / 标注待确认 | agent 自动，不编造 |
| 落地 `docs/architecture/workflow.md` + 索引 | agent 自动，已存在跳过 |
| 阶段 0 文档骨架 | agent 自动，不覆盖已有 |
| 七个决策点（wish 模式） | agent 按默认表执行，记入假设账本 |
| 新增依赖 / 改门禁 / 合并 / 推送 / 发布 | 需你确认 |
| 视觉方向 / 合并策略 | 你选择 |

### 步骤 1：立规则（agent 自动完成，不用复制）

在新项目里对 agent 说一句「按 okgo 启动这个项目」，它会：

1. **检测**：项目根或仓库根已有 `AGENTS.md` 就直接用；都没有才创建；
2. **生成**：读取 `references/agents-template.md`，写入项目根 `AGENTS.md`；
3. **填充**：项目名（`package.json` 的 `name` 或目录名）、包管理器（锁文件）、语言/框架/数据库（依赖与配置文件）、命令（只填构建文件里**真实存在**的脚本）；
4. **标记未知**：无法确定的写 `待确认`，文末列「待确认项」，不编造命令；
5. **回报**：已创建、填了 N 项、待确认 M 项。

你只需要确认它列出的待确认项。**已有 `AGENTS.md` 不会被覆盖**：它会先读，列出缺哪些章节/门禁，再问你要不要补。

手动兜底（agent 不可用时）：

```bash
cp ~/.agents/skills/okgo/references/agents-template.md ./AGENTS.md
```

然后替换全部 `{{PLACEHOLDER}}`（见第 9 节）；删除不适用的门禁——**但 `lint` / `type-check` / `test` / `build` / 依赖检查不得删**；没有 UI 的项目删掉设计/截图相关条款。

### 步骤 2：立流程（同样自动）

启动时 agent 会顺带完成，无需你操作：

- 生成 `docs/architecture/workflow.md`（源：`references/workflow-manual.md`）；
- 不存在 `docs/design/README.md` 时创建，并登记 workflow 的索引行；
- 已存在则跳过，不覆盖。

手动兜底：

```bash
mkdir -p docs/architecture docs/design
cp ~/.agents/skills/okgo/references/workflow-manual.md docs/architecture/workflow.md
```

之后团队流程演进只改这一份。

### 步骤 3：按阶段推进

每进入一个阶段，读手册对应章节；需要产出物格式时，从 `assets/` 取片段模板（任务契约、验收清单、Requirement、Task、交付卡片、缺陷单）。

**任何时候只信一件事**：`AGENTS.md`（规则）+ `docs/architecture/workflow.md`（路径）。两者冲突时以 `AGENTS.md` 为准。

---

## 5. 完整流程

> 默认 `guided`：按下面的阶段走，闸门等你确认。想「一句话做完」，用第 6 节的许愿模式；阶段与产出相同，只是闸门改为自检、决策按默认表。

```text
想法
 ├─ 阶段 0  立项准备        → 仓库/文档骨架/基线门禁
 ├─ 阶段 1  契约与验收      → 任务契约 + 验收清单        ★闸门 1
 ├─ 阶段 2  设计            → design.md + 设计系统       ★闸门 2
 ├─ 阶段 3  计划            → 任务计划（TDD 步骤级）
 ├─ 阶段 4  骨架 + 分片实现  → 每 task 红→绿→回归→提交
 ├─ 阶段 5  自动闸门        → check + build + serve + E2E + 截图
 └─ 阶段 6  独立复核        → 缺陷单 → 修复 → 再复核     ★闸门 3
                              → 交付卡片 + 合并
```

### 阶段 0 · 立项准备

目标：项目「能跑、能检查、能记录」，不写业务代码。

- 初始化仓库、`.gitignore`、`.env.example`（只放占位值）
- 定包管理器与目录分层（`apps/` / `libs/` / `tools/`）
- 建文档骨架：`readme.md`、`prd.md`、`project_plan.md`、`docs/design/`、`docs/plans/`、`changes/`、`artifacts/ui/`
- 立最小门禁并聚合成一条 `check`；CI 只调用这一条
- 跑一次全量门禁，把既有红项登记进首个任务契约

**退出标准**：干净环境下 `install → check → build → serve` 四步可复现。

### 阶段 1 · 契约与验收 ★闸门 1

先问清 5 件事（一次问一个，不要一口气抛）：

1. 使用者是谁？在什么场景下打开它？
2. 他要完成的那**一个动词**是什么？
3. 什么算成功？能量化吗？
4. 明确**不做**什么？
5. 有哪些硬约束（技术栈、合规、预算、期限、必须复用的系统）？

产出：任务契约（`assets/task-contract.md`）+ 验收清单（`assets/acceptance-checklist.md`）+ 规格（`assets/requirement.md`）。

验收清单每类至少一条：**功能 / 边界 / 集成 / 卫生**；写不出可执行验证方式的条目，删掉或改写。

**闸门 1**：把「我理解的目标 + 验收项」复述给用户，明确说「确认后我才开始设计/实现」。

### 阶段 2 · 设计 ★闸门 2

技术设计清单：数据模型（表/字段/索引/迁移/回滚）、接口（路径/入参/出参/错误码/分页/幂等）、权限（每个端点校验什么；前端隐藏不算授权）、并发（唯一约束/事务/重复提交）、失败（超时/重试/降级/部分失败）、可观测（结构化日志字段/指标）、安全（输入校验/参数化/输出编码/密钥管理）。

有界面时顺序固定：

1. 定视觉方向——调性、字体、色彩、布局概念，给出 4–6 个命名色值 + 字体角色 + 一版 ASCII 线框；
2. 定设计系统——语义化 token（`--ink` 而不是 `--gray-700`）、层级、间距、圆角、状态（空/加载/错误/禁用/成功）、断点、动效，写入 `.interface-design/system.md`；
3. 用户确认设计系统后，才允许写界面代码。

判断标准：换一个 AI 用同样的 brief 会不会产出几乎一样的界面？会，就还没设计完。

### 阶段 3 · 计划

- 读者是「没看过这个仓库的工程师」：每个 task 写清改哪个文件、函数签名、用哪个测试证明；
- 每个 step 只做一件事且可检验：写失败测试 → 跑到失败 → 最小实现 → 跑到通过 → 全量回归 → 提交；
- **Task 1 固定是 walking skeleton**：目录、数据模型、主入口跑通，能 build、能启动、能冒烟；
- 每个 task 独立可测、可回滚，一个 task 一个提交；
- 列出超出 8 文件 / 400 行预算的批次，提前拆；
- `tasks.md` **最后写**，每条 task 映射验收项 ID。

### 阶段 4 · 骨架与分片实现

隔离：需要时先建 worktree/分支，分支名与任务同名；一人一分支。

选择执行方式并**不来回切换**：

| 方式 | 适用 | 成本 |
|---|---|---|
| 单人执行 | task 较少、上下文连贯、你亲自实现 | 低 |
| 每 task 双上下文 | task 多且独立、需要新鲜视角 | 高 |

执行期间不逐 task 问「要不要继续」，遇以下四种才停：不可逆/破坏性操作、安全敏感操作、工作区外副作用（合并/推送/发布）、计划坏到每条路都是猜。

每个 task 的固定循环：

1. **RED**：写一个会失败的测试，只测一个行为；
2. **验证红**：确认失败原因正确（不是语法或环境问题）；
3. **GREEN**：最小实现让它通过；
4. **验证绿**：该测试 + 全量回归；
5. **REFACTOR**：绿的前提下清理，行为不变；
6. **提交**：一个 task 一个提交，消息写「做了什么 + 为什么」。

铁律：**先写了实现代码？删掉，从测试重来。** 不保留当「参考」。

出 bug 时先系统性调试：复现 → 读全文错误 → 假设 → 一次只改一个变量 → 补回归测试。禁止「先改一行看看」。

### 阶段 5 · 自动闸门与验证

顺序不可颠倒：

| 步骤 | 命令（示例） | 通过标准 |
|---|---|---|
| 1 类型与单测 | `npm run type-check`、`npm test` | exit 0，0 failed |
| 2 全量门禁 | `npm run check` | exit 0 |
| 3 构建 | `npm run build` | exit 0，产物存在 |
| 4 产物运行 | `npm run serve` | 停掉 dev server 后入口可访问 |
| 5 E2E | `node scripts/integration-test.mjs` 等 | 主流程通 |
| 6 UI 验收 | 截图（Playwright 等） | 覆盖默认/空/错误/加载/移动断点，存 `artifacts/ui/` |
| 7 卫生扫描 | 见 `references/workflow-manual.md` §9.4 | 输出为空或有明确理由 |

五维验收逐条给结论：**功能 / 边界 / 集成 / 工程 / 卫生**。每条只能是：通过 / 不适用（附理由）/ 未验证（附原因和建议验法），不允许空白。

识别「假绿」：入口没接上、只测首次进入、权限只在前端、用 `any` 或空 `catch` 压错误、改断言让门禁变绿、用旧截图冒充本次验证。

### 阶段 6 · 独立复核与收尾 ★闸门 3

- **输入只给三样**：任务契约 + 仓库 + diff（base..head）。**不给实现者自我评价**，避免锚定。
- **复核者**：独立子代理 / 新会话 / 另一工具 / 用户本人；实现者自查不算。
- **动作**：逐条运行或观察，每个「通过」给证据（命令输出、`文件:行号`、截图），主动构造反例。
- **输出**：验收条目表 + 缺陷单（见 `assets/defect-report.md`），按严重级别排序。
- **纪律**：复核者不改代码；改了就要换人。
- **闭环**：不通过 → 修复 → 重新复核 → 通过。
- 最后填交付卡片（`assets/delivery-card.md`），再决定合并 / PR / 保留分支，清理工作区。

---

## 6. 许愿模式（wish mode）

一句话交付的可选模式。默认仍是 guided（三闸门）；**只有你说出触发语才切换**。

```text
许愿模式：做一个 <需求>，一路做完，不用问我
```

### 6.1 它改了什么

| | guided（默认） | wish |
|---|---|---|
| 闸门 1 契约 | 等你确认 | 自检 + 记录，继续 |
| 闸门 2 设计 | 等你 review | 自检 + 记录，继续 |
| 闸门 3 复核 | 独立复核 | 独立复核自动触发，最多修 2 轮 |
| 七个决策点 | 逐项问你 | 按默认表执行，记入假设账本 |
| 需求提问 | 一次一个 | 最多 3 个方向性问题，一次问完；不答按默认 |
| 停下来 | 每个闸门 | 只在硬停条件 |

**不变的**：三条铁律、TDD、验收清单、独立复核、证据要求。wish 只改「谁拍板」，不改「要不要验证」。

### 6.2 默认决策（节选）

| 决策 | 默认 |
|---|---|
| 工作区 | 已有仓库建分支；新项目 `git init` + 本地提交 |
| 依赖 | 默认不加；必须加时选最小可用并记入账本 |
| 预算 | 每 task ≤8 文件 / 400 行；超出拆批 |
| 门禁 | 不放宽、不改阈值 |
| 视觉 | 给 2 个方向，按信息密度与惯例选 1 |
| 数据 | 本地替代（SQLite / 内存 / 样例） |
| 合并 | 保留分支，不推送不合并 |
| 部署 | 不做 |

完整表与规则：`references/wish-mode.md`；假设模板：`assets/assumption-ledger.md`。

### 6.3 它仍会停下来

不可逆/破坏性、安全敏感、外部副作用（推送/PR/部署/发布）、付费或系统级安装、预算超 3 倍、需求自相矛盾且无合理默认、环境不可用、复核 2 轮不通过、你打断。

停下时给：卡点 / 已尝试 / 可选方案（含默认推荐）/ 继续所需的最小输入。

### 6.4 你会拿到什么

- 本地可运行的主流程（真实入口）；
- 本次运行的测试与门禁证据（命令、退出码、关键输出）；
- 有 UI 时的截图（默认/空/错误/加载）；
- 假设账本 + 未验证清单；
- 交付报告 + 下一步建议（推送/合并需你确认）。

### 6.5 边界

- **能到**：MVP、内部工具、已有仓库的新功能——「一句话 → 可演示 + 有测试 + 有截图」。
- **到不了**：上线级质量、生产部署、品牌级视觉、合规/支付/多租户权限这类必须人判断的部分。
- 一句话质量决定结果：**目标 + 一个动词 + 硬约束**效果最好。

### 6.6 切回 guided

说「停」「一步一步来」「先确认」立即回到三闸门；已完成部分作为输入，不推倒重来。

---

## 7. 三道闸门

> 以下是 `guided`（默认）的闸门。`wish` 模式下闸门 1 / 2 改为自检 + 记录，闸门 3 由独立复核自动执行，见第 6 节。

| 闸门 | 时机 | 通过条件 | 不通过怎么办 |
|---|---|---|---|
| **闸门 1** | 阶段 1 末 | 用户确认目标 + 验收清单（每条可执行） | 回到提问，不要开始设计 |
| **闸门 2** | 阶段 2 末 | 用户 review `design.md` + 设计系统 | 口头「可以」只允许继续写规格，不允许开工 |
| **闸门 3** | 阶段 6 | 独立复核逐条通过 + 证据齐全 | 修复后换人/换上下文再复核 |

---

## 8. 规模分级

| 级别 | 判定 | 最低流程 | 复核 |
|---|---|---|---|
| L0 | 纯文档/注释/文案，无行为变化 | 相关门禁 + 说明 | 可免 |
| L1 | 单模块行为变更、修 bug | 契约 + 测试 + `check` | 用户抽查 |
| L2 | 新项目、新功能、跨模块、架构/数据/安全 | 契约 + 规格 + 骨架 + 分片 + E2E + 全量门禁 | **独立复核强制** |

**新项目默认 L2**，只升不降；发现隐藏复杂度时升级，不降级。

---

## 9. 占位符

替换 `AGENTS.md` 中的占位符（`{{...}}` 全部替换，不保留）：

| 占位符 | 含义 |
|---|---|
| `{{PROJECT_NAME}}` | 项目名 |
| `{{LANGUAGE_RUNTIME}}` | 语言与运行时版本 |
| `{{FRAMEWORK}}` | 主框架 |
| `{{PKG_MANAGER}}` | 包管理器 |
| `{{DATABASE}}` | 数据库 |
| `{{DEV_CMD}}` | 开发启动命令 |
| `{{TYPE_CMD}}` | 类型检查命令 |
| `{{TEST_CMD}}` | 测试命令 |
| `{{BUILD_CMD}}` | 构建命令 |
| `{{SERVE_CMD}}` | 启动构建产物的命令 |
| `{{CHECK_CMD}}` | 全量门禁聚合命令 |

校验：`grep -n '{{' AGENTS.md` 必须无输出。命令必须与根 `package.json`（或对应构建文件）一致，不一致时以构建文件为准并回改 `AGENTS.md`。

---

## 10. 按项目情况裁剪

| 情况 | 怎么改 |
|---|---|
| 没有 UI | 删除 `frontend-design` / `interface-design` / `webapp-testing` 条款、`artifacts/ui`、截图步骤；设计阶段只保留技术设计 |
| 单周 MVP | 阶段 0–3 压缩到 1 天；1 个骨架 + 3–5 个功能切片；其余照走 |
| 已有项目接入 | 不重建流程：先只落 `AGENTS.md` + 基线门禁，把存量红项登记为基线，只对新增红项负责 |
| 已有 `AGENTS.md` | 以现有文件为准，把本模板当作**差距清单**逐条补齐，不要直接覆盖 |
| 只有一个人 + AI | 阶段 4 用单人执行；复核用独立会话/另一工具；其余不变 |
| 从既有工作区派生 | 额外继承该仓库的分层、私有包策略、依赖方向白名单与既有 `check` 链路 |

---

## 11. 与已有技能的关系

本技能负责**顺序与文档骨架**，不替代具体方法技能：

| 时机 | 可用技能（若已安装） |
|---|---|
| 需求澄清与分类 | `brainstorming` |
| 拆计划 | `writing-plans` |
| 隔离工作区 | `using-git-worktrees` |
| 逐 task 执行 | `executing-plans` / `subagent-driven-development` |
| 写功能 / 修 bug | `test-driven-development` |
| 出 bug | `systematic-debugging` |
| 复核 | `requesting-code-review` / `receiving-code-review` |
| 声称完成前 | `verification-before-completion` |
| 视觉方向 / 设计系统 / 截图验收 | `frontend-design` / `interface-design` / `webapp-testing` |

**优先级**：用户直接指令 > 项目 `AGENTS.md` > 技能默认值。技能默认落点与本流程冲突时，改技能行为，不改项目规则。

---

## 12. 维护

- **单一来源**：手册只维护 `references/workflow-manual.md`，项目侧副本是它的落地版；团队流程变更先改技能，再同步到各仓库。
- **升级方式**：说「升级 okgo」或重跑 `bash scripts/install.sh`；技能文件整体更新，但**项目里的 `AGENTS.md` 不动**——按需对比差异逐条并入，不要整体覆盖。
- **兼容性**：只用 Markdown + YAML frontmatter；唯一的脚本是 `scripts/install.sh`（安装/升级用，可跳过），没有运行时依赖。
- **版本建议**：在发布页记录「技能版本 / 变更点」，项目 `AGENTS.md` 可加一行 `Workflow: okgo vX.Y`。

---

## 13. FAQ

**Q：许愿模式真的什么都不问？**
A：最多问 3 个决定方向的问题（目标用户/核心动词、硬约束、交付边界），一次问完并给默认答案；你不答就按默认走。其余写成假设账本，交付时一起给你审。它不会在可推断的信息上反复确认。

**Q：许愿模式能把项目做到上线吗？**
A：不能。它做到「本地可运行 + 已验证范围 + 证据齐全」；部署、推送、合并、品牌级视觉、合规与支付仍需你确认。

**Q：必须把两份文档都放进项目吗？**
A：`AGENTS.md` 必须（规则要被 agent 读到）；`docs/architecture/workflow.md` 强烈建议（人和 AI 都靠它对齐顺序）。只放一份时优先 `AGENTS.md`。

**Q：怎么安装和升级？**
A：对 agent 说「安装 okgo 技能：https://github.com/jackyzhangok/okgo」或「升级 okgo」即可；它会调 `scripts/install.sh` 完成复制、校验、软链。升级只动技能文件，不动项目里的 `AGENTS.md`。

**Q：安装脚本会不会覆盖我工具目录里已有的同名技能？**
A：不会。脚本只在目标工具目录里**新建** `okgo` 软链；遇到已有同名目录或链接就跳过并报告。安装目标本身（默认 `~/.agents/skills/okgo`）视为升级，会被更新。

**Q：新项目还没有 `AGENTS.md`，要我先复制模板吗？**
A：不用。agent 会自动检测并创建；连 `package.json` 都没有的空仓库也能生成，命令项标 `待确认`，等阶段 0 定稿再补。你只需要回答它问的那 2–3 个问题。

**Q：会不会覆盖我已有的 `AGENTS.md`？**
A：不会。检测到已存在就只读，列出缺哪些章节/门禁，问你要不要补；不会整体覆盖。

**Q：和 Cursor rules / CLAUDE.md 冲突怎么办？**
A：只保留一份权威规则。`CLAUDE.md`、`.cursor/rules` 里写「规则见 AGENTS.md」，正文不复制，避免两份漂移。

**Q：小改动也要走全流程吗？**
A：不用。L0/L1 走快车道（契约 + 测试 + `check` + 用户抽查），但三条铁律不豁免。

**Q：没有子代理工具，怎么做独立复核？**
A：开新会话、换模型/换工具，或让用户本人复核。状态只能标「未完成/待复核」，不得自我豁免。

**Q：门禁全绿就说明做完了吗？**
A：不。门禁只证明最低门槛；功能靠验收清单，边界靠用例，集成靠 E2E，视觉靠截图，需求靠独立复核。

---

## 14. 参考

- Agent Skills 规范：<https://agentskills.io/specification>
- Cursor Skills 文档：<https://cursor.com/docs/agent-sdk/reference/skills>
- WorkBuddy Skills 文档：<https://www.workbuddy.cn/docs/ide/Features/Skills>
- 详细流程与全部命令示例：`references/workflow-manual.md`
- 项目规则全文：`references/agents-template.md`
