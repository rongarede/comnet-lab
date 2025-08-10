# ClaudeCode 指南：Solidity/Foundry Compound v3 集成骨架

## 项目背景
你是一名 Solidity/Foundry 工程师，正在为一个 Foundry 项目创建最小可编译骨架，该项目后续将集成 Compound v3 (Comet)。项目使用 Foundry 1.2.3 和 Solc 0.8.27。

## 任务概述
生成恰好 3 个源文件，构成"Day1 骨架" - 可编译、测试全绿，但不连接主网或导入 Comet。这些文件将成为未来 Compound v3 集成的基础。

## 输出要求

### 格式规则
- **只输出代码块** - 不要任何解释性文字
- 每个代码块前用一行注明目标路径
- 按指定顺序输出文件
- 代码必须可直接保存和运行

### 技术要求
- 许可证：`// SPDX-License-Identifier: MIT`
- 编译指令：`pragma solidity ^0.8.20;`
- 依赖：仅 `forge-std`，无外部导入
- 所有单位/精度必须清晰标注（如 1e6/1e18）
- 包含 TODO 注释指明后续实现
- 必须通过：`forge build && forge test`

## 文件规格

### 1. src/lib/LibRead.sol（只读适配器骨架）
**作用**：为测试与不变式提供单一读数入口（会计量/指数/利用率/价格/账户），与协议实现解耦。

**必需的 IRead 接口**：
```solidity
interface IRead {
    function accounting() external view returns (uint256 cash, uint256 borrows, uint256 reserves, uint8 baseDecimals);
    function onchainBaseBalance() external view returns (uint256 balance, uint8 baseDecimals);
    function indices() external view returns (uint256 supplyIndex, uint256 borrowIndex);
    function utilization() external view returns (uint256 u1e18);
    function priceOf(address asset) external view returns (uint256 price, uint8 scale);
    function userBasic(address user) external view returns (uint256 baseDebt, uint256 baseSupply, uint256 hf1e18);
    function userCollateral(address user, address asset) external view returns (uint256 collBalance, uint256 value1e18);
    function liquidationParams(address asset) external view returns (uint256 discount1e18);
    function eps(uint8 decimals) external view returns (uint256 epsilon);
}
```

**实现要求**：
- 合约 `LibRead` 实现 `IRead`
- 返回合理的占位值
- 注释说明后续将对接哪些 Comet 方法（如 totalsBasic、getUtilization、getPrice、userBasic）
- 在注释中指定每个返回值的精度（如 price 的 scale 是 1e8 或 1e18）

### 2. test/handlers/Handler.sol（状态化动作生成器骨架）
**作用**：为 Foundry 的 invariant 测试提供最小可用的动作入口。Day1 保持空壳，Day2 起添加动作实现。

**必需组件**：
- 合约 `Handler` 包含：
  - `setActors(address[] calldata actors)` - 仅存储，无逻辑
  - `setAssets(address base, address[] calldata cols)` - 仅存储，无逻辑
  - `function noop() external {}` - 用于 Day1 selector 绑定/smoke 测试
- 内部存储：参与者数组、base/抵押资产数组
- TODO 注释标明将来会实现 supply/withdraw/borrow/repay 与输入边界收敛

### 3. test/Invariant.t.sol（不变式入口骨架）
**作用**：集中声明性质。Day1 先跑 smoke 测试，保证测试绿色与结构稳定。

**必需组件**：
- 导入语句：
  - `import "forge-std/Test.sol";`
  - `import {LibRead, IRead} from "../src/lib/LibRead.sol";`
- 合约 `InvariantSmoke is Test`：
  - `IRead internal R;`
  - `setUp()`：初始化 `R = new LibRead();`（后续会替换为实际实现）
  - 可选：占位地址常量
  - `function invariant_smoke() external view { assertTrue(true); }` - 单一断言验证框架
- 注释说明 Day2 将把 smoke 替换为 6 条核心不变式（ACC/IDX/U 等），并通过 targetSelector 绑定 Handler

## 验收标准
- 保存这 3 个文件后：`forge build && forge test -vv` 必须全绿（允许无害警告）
- 无外部网络依赖或主网 fork 需求
- 除 `forge-std` 外无第三方导入
- 输出恰好 3 个代码块，不含其他内容

## 代码生成指导
生成代码时：
1. 创建完整、可编译的文件结构
2. 使用语义合理的占位值
3. 包含全面的 TODO 注释指明未来实现点
4. 即使实现是骨架式的，接口也要完整
5. 保持命名规范和代码风格的一致性
6. 清晰记录所有精度假设

## 占位值示例
- Supply/Borrow 指数：1e15（表示 1.0，15 位小数）
- 利用率：5e17（表示 50%，18 位小数）
- 价格：1e8（USD 价格，8 位小数）
- 健康因子：15e17（表示 1.5，18 位小数）
- 小数位：USDC 为 6，大多数代币为 18

## 未来集成说明
这些骨架将通过以下阶段演进：
- Day 2：连接实际 Comet 合约
- Day 3：实现 Handler 动作（supply、withdraw、borrow、repay）
- Day 4：添加完整不变式（会计、指数、利用率等）
- Day 5：集成主网 fork 进行真实测试

记住：这是一个必须架构合理同时保持最小化和可编译的基础。

## 执行指令
当你收到这个任务时，请：
1. **只生成三个代码块**，不要任何额外文字
2. 每个代码块前标注文件路径
3. 确保代码可以直接复制保存并通过编译测试
4. 使用清晰的 TODO 注释标记未来扩展点
5. 保持所有函数签名完整，即使当前返回占位值
