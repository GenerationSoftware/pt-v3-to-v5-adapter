// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/utils/introspection/IERC165.sol";

/// @title An interface that allows a contract to listen to token mint, transfer and burn events.
interface V3PrizePoolInterface {
  /// @notice Called by the prize strategy to award prizes.
  /// @dev The amount awarded must be less than the awardBalance()
  /// @param to The address of the winner that receives the award
  /// @param amount The amount of assets to be awarded
  /// @param controlledToken The address of the asset token being awarded
  function award(
    address to,
    uint256 amount,
    address controlledToken
  ) external;

  /// @notice Captures any available interest as award balance.
  /// @dev This function also captures the reserve fees.
  /// @return The total amount of assets to be awarded for the current prize
  function captureAwardBalance() external returns (uint256);
}
