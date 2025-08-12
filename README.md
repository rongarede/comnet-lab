# comnet-lab · DeFi Lending · Compound v3 (USDC)

**目的**：这是一个可复现实验 + 可合 PR 的借贷协议沙盒。先用最小成本把"验证→护栏（不变式）→小 PR→数据化"的闭环跑通，再逐步扩展。

**当前状态**：Stage A · Week 1（已建立骨架与基线：LibRead / Handler / Invariant，forge test 绿，gas-snapshot 已生成）

## 🎯 目标与里程碑

- **30 天（至 2025-09-08）**：合并 ≥1 个小 PR（测试/文档/输入校验）、发布 1 个 mainnet-fork 最小清算脚本、技术笔记《会计不变式入门》
- **60 天（至 2025-10-08）**：功能级 PoC 合并 ≥1、不变式覆盖 ≥10、上线 1 个 The Graph 子图
- **90 天（至 2025-11-07）**：testnet 清算机器人 MVP、≥1 个"中等影响"会计/安全修正 PR、审计小报告

## 🗂️ 仓库结构（最小集）

```
src/
  lib/
    LibRead.sol           # 只读门面：统一读取会计量/指数/利用率/价格/账户
test/
  Invariant.t.sol         # 不变式入口（W1 先 smoke，后续替换为 ACC/IDX/U/LQ 等）
  handlers/
    Handler.sol           # 状态化动作生成器（W2 起供 supply/withdraw/borrow/repay）
tools/
  graphviz/               # 调用图 .dot/.svg
reports/                  # 复现实验与周报、环境记录
.gas-snapshot             # gas 基线（PR 必对比）
foundry.toml
```

## ⚙️ 先决条件

- Foundry ≥ 1.2.3（与 CI 固定一致）
- （可选）Graphviz（调用图）、Slither（静态分析）
- （做 fork 时）MAINNET_RPC_URL 环境变量

## 🚀 快速起步

```bash
forge build && forge test -vv
forge snapshot     # 生成/更新 .gas-snapshot
```

## 🔍 不变式（Invariants）

W1 先 smoke，W1–W2 逐步落地以下核心不变式（用 LibRead 统一 ε/精度）：

- **ACC-001 会计守恒**：cash + borrows − reserves ≈ onchainBaseBalance ± ε
- **ACC-002 非负性**（池/账户维度）
- **ACC-003 总量一致**（Sum-of-Parts）
- **IDX-001 指数单调**（supplyIndex/borrowIndex 不下降）
- **U-001 利用率边界**（0 ≤ U ≤ 1e18）
- **LQ-001 清算对账一致**（Δdebt ≈ seized×price×(1−discount) ± ε）

建议运行参数（也可写在 foundry.toml）：

```bash
FOUNDRY_INVARIANT_DEPTH=100 FOUNDRY_INVARIANT_RUNS=200 forge test -vv
```

## 🧪 主网分叉（mainnet-fork）

- **市场**：USDC（Compound v3 / Comet）
- **固定区块号**：**18500000**（通过 `fork.json` 锁定，确保可重现结果）
- **第一版脚本**：
  - `scripts/fork_read.s.sol`（只读三会计量，验证 RPC 与地址）
  - `scripts/fork_liquidation_min.s.sol`（零回退清算测试：自建仓位→价格模拟→absorb+buyCollateral→三大断言）

### 固定区块号 Fork

为确保实验可重现，所有 fork 脚本均锁定在**区块 18500000**：

```json
// fork.json
{
  "blockNumber": 18500000,
  "network": "mainnet",
  "description": "Fixed fork block for Compound v3 liquidation testing"
}
```

脚本会优先从 `fork.json` 读取区块号，确保每次运行环境一致。

### 运行示例

```bash
# 设置环境变量
export RPC_URL=https://mainnet.infura.io/v3/YOUR_KEY
export MOCK_MODE=1

# 只读测试（验证连接性）
forge script scripts/fork_read.s.sol --fork-url $RPC_URL --ffi -v

# 完整清算测试（包含三大断言）
forge script scripts/fork_liquidation_min.s.sol --fork-url $RPC_URL --ffi -v
```

### 清算测试断言

脚本包含三个核心断言（零回退设计）：
- **债务减少公式**：`expected = min(debtBefore, seizedCollateral × price × (1-discount))`
- **清算者盈亏**：PnL ≥ 0
- **事件验证**：AbsorbDebt + AbsorbCollateral 事件一致性

## ⛽ Gas 基线与回归守门

- **建立/更新**：`forge snapshot` → 产出 `.gas-snapshot`
- **PR Gate**：CI 中强制对比 `.gas-snapshot`（有 diff 先解释再合，关键路径 >+5% 必需理由）
- **建议**在 PR 描述写清：受影响函数、变动百分比、原因、去留结论

## 🤖 CI（GitHub Actions，最小集）

- `forge build && forge test`
- `forge snapshot + 强制 diff .gas-snapshot`（有差异即红）
- 固定 Foundry/solc 版本，避免漂移
- （可选）Slither（过滤低噪路径），fork 冒烟放 workflow_dispatch 或 nightly

## 🔧 PR 规范（小步可合）

- 单 PR 聚焦一个问题，<300 行、影响文件 <5
- 先 RFC/Issue，明确 DOD，再写代码
- 必带：测试（不变式/回归）、gas 对比、（如涉及）fork 复现实验的区块号+命令+日志
- 可回滚优先；不可逆改动（存储布局/外部接口/权限）需要单独评审与冷静期

## 🗺️ 路线（Stage A → C 概览）

- **A（W1–W2）**：工具打通→最小清算→6→10 条不变式→小 PR #1/#2
- **B（W3–W8）**：Handler + Δ-不变式 + 压测 + The Graph 子图
- **C（W9–W12）**：清算机器人 dry-run → testnet →（预言机模块 或 审计笔记）

## ⚠️ 免责声明

本仓库用于研究与测试；脚本在主网仅用于只读或最小复现实验。任何交易/参数改动请先在 fork 上验证，并遵循仓库的 PR Gate。