// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

/// @title An interface that allows a contract to listen to token mint, transfer and burn events.
interface V5PrizePoolInterface {
    function contributePrizeTokens(address _prizeVault, uint256 _amount) external returns (uint256);
    function getContributedBetween(address _vault, uint24 _startDrawIdInclusive, uint24 _endDrawIdInclusive) external view returns (uint256);
}
