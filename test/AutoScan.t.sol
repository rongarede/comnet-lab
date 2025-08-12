// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/lib/LibRead.sol";

contract AutoScanTest is Test {
    LibRead public libRead;

    event PriceRequested(address indexed asset, uint256 price, uint8 scale);
    event AccountingQueried(uint256 cash, uint256 borrows, uint256 reserves);

    function setUp() public {
        libRead = new LibRead();
    }

    function testPriceOfRevertsWithZeroAddress() public {
        vm.expectRevert("ZERO_ADDRESS");
        libRead.priceOf(address(0));
    }

    function testPriceOfEmitsEvent() public {
        address asset = address(0x123);

        vm.expectEmit(true, false, false, true);
        emit PriceRequested(asset, 1e8, 8);

        (uint256 price, uint8 scale) = libRead.priceOf(asset);

        assertEq(price, 1e8);
        assertEq(scale, 8);
    }

    function testAccountingEmitsEvent() public {
        vm.expectEmit(false, false, false, true);
        emit AccountingQueried(1000000e6, 800000e6, 50000e6);

        (uint256 cash, uint256 borrows, uint256 reserves, uint8 baseDecimals) = libRead.accounting();

        assertEq(cash, 1000000e6);
        assertEq(borrows, 800000e6);
        assertEq(reserves, 50000e6);
        assertEq(baseDecimals, 6);
    }
}
