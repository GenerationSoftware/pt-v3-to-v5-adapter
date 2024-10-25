// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/utils/introspection/IERC165.sol";
import "./V3TokenListenerInterface.sol";

/// @title An interface that allows a contract to listen to token mint, transfer and burn events.
interface V5VaultInterface {
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);
    function sponsor(uint256 _assets) external returns (uint256);
}
