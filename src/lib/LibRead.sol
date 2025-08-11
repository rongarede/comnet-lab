// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IRead {
    function accounting() external view returns (uint256 cash, uint256 borrows, uint256 reserves, uint8 baseDecimals);
    function onchainBaseBalance() external view returns (uint256 balance, uint8 baseDecimals);
    function indices() external view returns (uint256 supplyIndex, uint256 borrowIndex);
    function utilization() external view returns (uint256 u1e18);
    function priceOf(address asset) external view returns (uint256 price, uint8 scale);
    function userBasic(address user) external view returns (uint256 baseDebt, uint256 baseSupply, uint256 hf1e18);
    function userCollateral(address user, address asset)
        external
        view
        returns (uint256 collBalance, uint256 value1e18);
    function liquidationParams(address asset) external view returns (uint256 discount1e18);
    function eps(uint8 decimals) external view returns (uint256 epsilon);
}

contract LibRead is IRead {
    // TODO: Connect to actual Comet contract's totalsBasic() for cash/borrows/reserves
    function accounting() external pure returns (uint256 cash, uint256 borrows, uint256 reserves, uint8 baseDecimals) {
        cash = 1000000e6; // 1M USDC (6 decimals)
        borrows = 800000e6; // 800K USDC borrowed
        reserves = 50000e6; // 50K USDC reserves
        baseDecimals = 6; // USDC decimals
    }

    // TODO: Connect to actual base token balanceOf(comet)
    function onchainBaseBalance() external pure returns (uint256 balance, uint8 baseDecimals) {
        balance = 1050000e6; // 1.05M USDC balance
        baseDecimals = 6; // USDC decimals
    }

    // TODO: Connect to Comet's getSupplyRate()/getBorrowRate() and compound to indices
    function indices() external pure returns (uint256 supplyIndex, uint256 borrowIndex) {
        supplyIndex = 1e15; // 1.0 supply index (15 decimals)
        borrowIndex = 1e15; // 1.0 borrow index (15 decimals)
    }

    // TODO: Connect to Comet's getUtilization() - returns 18 decimal utilization
    function utilization() external pure returns (uint256 u1e18) {
        u1e18 = 8e17; // 80% utilization (18 decimals)
    }

    // TODO: Connect to Comet's getPrice() - typically returns 8 decimal USD price
    function priceOf(address asset) external pure returns (uint256 price, uint8 scale) {
        asset; // silence unused warning
        price = 1e8; // $1.00 USD price (8 decimals)
        scale = 8; // Price scale factor
    }

    // TODO: Connect to Comet's userBasic() for principal/present value calculations
    function userBasic(address user) external pure returns (uint256 baseDebt, uint256 baseSupply, uint256 hf1e18) {
        user; // silence unused warning
        baseDebt = 100000e6; // 100K USDC debt
        baseSupply = 150000e6; // 150K USDC supply
        hf1e18 = 15e17; // 1.5 health factor (18 decimals)
    }

    // TODO: Connect to Comet's userCollateral() and calculate USD value
    function userCollateral(address user, address asset)
        external
        pure
        returns (uint256 collBalance, uint256 value1e18)
    {
        user; // silence unused warning
        asset; // silence unused warning
        collBalance = 1e18; // 1.0 collateral token
        value1e18 = 2000e18; // $2000 USD value (18 decimals)
    }

    // TODO: Connect to Comet's liquidationFactor for asset
    function liquidationParams(address asset) external pure returns (uint256 discount1e18) {
        asset; // silence unused warning
        discount1e18 = 95e16; // 9.5% liquidation discount (18 decimals)
    }

    // TODO: Calculate appropriate epsilon based on asset decimals
    function eps(uint8 decimals) external pure returns (uint256 epsilon) {
        if (decimals == 6) {
            epsilon = 1; // 1 unit for USDC (6 decimals)
        } else {
            epsilon = 1e12; // 1e12 units for 18-decimal tokens
        }
    }
}
