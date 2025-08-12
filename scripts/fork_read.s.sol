// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

// Compound V3 Comet 接口定义
struct TotalsBasic {
    uint64 baseSupplyIndex;
    uint64 baseBorrowIndex; 
    uint64 trackingSupplyIndex;
    uint64 trackingBorrowIndex;
    uint104 totalSupplyBase;
    uint104 totalBorrowBase;
    uint40 lastAccrualTime;
    uint8 pauseFlags;
}

interface IComet {
    function totalsBasic() external view returns (TotalsBasic memory);
    function getReserves() external view returns (int256);
    function totalSupply() external view returns (uint256);
}

contract ForkReadScript is Script {
    string constant REPORT_FILE = "reports/W1D3-fork.md";
    
    function run() external {
        // 从环境变量读取 RPC URL 和市场合约地址
        string memory rpcUrl = vm.envString("RPC_URL");
        address marketAddress = vm.envAddress("MARKET");
        
        console2.log("=== Fork Read Script ===");
        console2.log("RPC URL:", rpcUrl);
        console2.log("Market Address:", marketAddress);
        
        // 创建并切换到指定的 fork
        uint256 forkId = vm.createSelectFork(rpcUrl);
        console2.log("Fork ID:", forkId);
        
        // 获取当前区块号
        uint256 blockNumber = block.number;
        console2.log("Current Block Number:", blockNumber);
        
        // 创建 Compound V3 Comet 接口实例
        IComet comet = IComet(marketAddress);
        
        // 调用 Compound V3 函数获取三个会计量
        uint256 totalSupply;
        uint256 totalBorrows; 
        int256 reserves;
        
        try comet.totalsBasic() returns (TotalsBasic memory totals) {
            totalSupply = uint256(totals.totalSupplyBase);
            totalBorrows = uint256(totals.totalBorrowBase);
            console2.log("Total Supply Base:", totalSupply);
            console2.log("Total Borrow Base:", totalBorrows);
        } catch Error(string memory reason) {
            console2.log("totalsBasic() failed:", reason);
            revert("Failed to get totals");
        }
        
        try comet.getReserves() returns (int256 _reserves) {
            reserves = _reserves;
            console2.log("Reserves:", reserves);
        } catch Error(string memory reason) {
            console2.log("getReserves() failed:", reason);
            revert("Failed to get reserves");
        }
        
        console2.log("=== Summary ===");
        console2.log("Block:", blockNumber);
        console2.log("Total Supply:", totalSupply);
        console2.log("Total Borrows:", totalBorrows);
        console2.log("Reserves:", reserves);
        
        // 序列化数据并写入报告文件
        string memory json = "fork_data";
        vm.serializeUint(json, "block_number", blockNumber);
        vm.serializeUint(json, "total_supply_base", totalSupply);
        vm.serializeUint(json, "total_borrow_base", totalBorrows);
        string memory finalJson = vm.serializeInt(json, "reserves", reserves);
        
        // 生成 Markdown 格式的报告内容 (分段处理避免堆栈过深)
        string memory header = string.concat(
            "# W1D3 Fork Reading Report\n\n",
            "**Contract Address:** `", vm.toString(marketAddress), "`\n\n",
            "**Block Number:** ", vm.toString(blockNumber), "\n\n"
        );
        
        string memory metrics = string.concat(
            "### Three Key Metrics (Compound V3)\n\n",
            "| Metric | Value |\n",
            "|--------|---------|\n",
            "| Total Supply Base | ", vm.toString(totalSupply), " |\n", 
            "| Total Borrow Base | ", vm.toString(totalBorrows), " |\n",
            "| Reserves | ", vm.toString(reserves), " |\n\n"
        );
        
        string memory data = string.concat(
            "### Raw JSON Data\n\n",
            "```json\n",
            finalJson, "\n",
            "```\n\n"
        );
        
        string memory verification = string.concat(
            "### Verification\n\n",
            "- [OK] RPC connectivity established\n", 
            "- [OK] Fork created successfully\n",
            "- [OK] Market contract accessible\n",
            "- [OK] All three metrics retrieved\n"
        );
        
        string memory report = string.concat(header, metrics, data, verification);
        
        // 写入文件
        vm.writeFile(REPORT_FILE, report);
        console2.log("Report written to:", REPORT_FILE);
        console2.log("=== Script Completed Successfully ===");
    }
}