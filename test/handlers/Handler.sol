// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Handler {
    address[] internal actors;
    address internal baseAsset;
    address[] internal collateralAssets;

    // TODO: Implement supply(uint256 amount) with input boundary convergence
    // TODO: Implement withdraw(uint256 amount) with balance constraints
    // TODO: Implement borrow(uint256 amount) with collateral factor limits
    // TODO: Implement repay(uint256 amount) with debt ceiling constraints
    // TODO: Add liquidate() action for underwater positions
    // TODO: Add time-based actions (accrueInterest, updateIndices)

    function setActors(address[] calldata _actors) external {
        // TODO: Validate actor addresses and set reasonable bounds
        actors = _actors;
    }

    function setAssets(address base, address[] calldata cols) external {
        // TODO: Validate asset addresses against Comet configuration
        baseAsset = base;
        collateralAssets = cols;
    }

    // Placeholder action for Day1 selector binding and smoke testing
    function noop() external {
        // TODO: Replace with actual supply/withdraw/borrow/repay implementations
        // This function exists only to ensure Handler has callable functions for testing
    }

    // TODO: Add helper functions for:
    // - _boundActorIndex(uint256 actorSeed) returns (uint256)
    // - _boundAssetIndex(uint256 assetSeed) returns (uint256)
    // - _boundAmount(uint256 amountSeed, uint256 maxAmount) returns (uint256)
    // - _selectRandomActor(uint256 seed) returns (address)
    // - _selectRandomCollateral(uint256 seed) returns (address)

    // TODO: Add state tracking for:
    // - Total actions executed
    // - Per-actor action counts
    // - Failed action attempts
    // - Ghost variables for invariant verification
}
