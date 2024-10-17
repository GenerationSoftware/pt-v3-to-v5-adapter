// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console2.sol";

import "@openzeppelin/access/Ownable.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";
import "@pt-v5-liquidator-interfaces/ILiquidationSource.sol";

import "./interface/V3PrizePoolInterface.sol";
import "./interface/V5PrizePoolInterface.sol";
import "./interface/V3TokenListenerInterface.sol";

/*

Vaults:

V3 DAI Prize Pool: 0xebfb47a7ad0fd6e57323c8a42b2e5a6a4f68fc1a
V3 USDC Prize Pool: 0xde9ec95d7708b8319ccca4b8bc92c0a3b70bf416



*/

contract V3PrizePoolLiquidatorAdapter is
    ILiquidationSource,
    Ownable,
    V3TokenListenerInterface
{
    bytes4 public constant ERC165_INTERFACE_ID_ERC165 = 0x01ffc9a7;
    bytes4 public constant ERC165_INTERFACE_ID_TOKEN_LISTENER = 0xff5e34e7;

    V3PrizePoolInterface immutable v3PrizePool;
    address immutable controlledToken;
    IERC20 immutable underlyingToken;
    V5PrizePoolInterface immutable v5PrizePool;
    address immutable v5Vault;

    address liquidationPair;

    constructor(
        V3PrizePoolInterface _v3PrizePool,
        address _controlledToken,
        V5PrizePoolInterface _v5PrizePool,
        address _v5Vault
    ) Ownable(msg.sender) {
        v3PrizePool = _v3PrizePool;
        controlledToken = _controlledToken;
        underlyingToken = IERC20(_v3PrizePool.token());
        v5PrizePool = _v5PrizePool;
        v5Vault = _v5Vault;
    }

    function setLiquidationPair(address _liquidationPair) external onlyOwner {
        liquidationPair = _liquidationPair;
    }

    /**
     * @notice Get the available amount of tokens that can be swapped.
     * @param tokenOut Address of the token to get available balance for
     * @return uint256 Available amount of `token`
     */
    function liquidatableBalanceOf(
        address tokenOut
    ) external returns (uint256) {
        if (tokenOut == address(underlyingToken)) {
            return v3PrizePool.captureAwardBalance();
        }
    }

    /**
     * @notice Transfers tokens to the receiver
     * @param sender Address that triggered the liquidation
     * @param receiver Address of the account that will receive `tokenOut`
     * @param tokenOut Address of the token being bought
     * @param amountOut Amount of token being bought
     */
    function transferTokensOut(
        address sender,
        address receiver,
        address tokenOut,
        uint256 amountOut
    ) external onlyLiquidationPair returns (bytes memory) {
        require(tokenOut == address(underlyingToken), "invalid token");
        v3PrizePool.award(address(this), amountOut, controlledToken);
        v3PrizePool.withdrawInstantlyFrom(
            address(this),
            amountOut,
            controlledToken,
            0
        );
        underlyingToken.transfer(receiver, amountOut);
    }

    /**
     * @notice Verifies that tokens have been transferred in.
     * @param tokenIn Address of the token being sold
     * @param amountIn Amount of token being sold
     * @param transferTokensOutData Data returned by the corresponding transferTokensOut call
     */
    function verifyTokensIn(
        address tokenIn,
        uint256 amountIn,
        bytes calldata transferTokensOutData
    ) external onlyLiquidationPair {
        v5PrizePool.contributePrizeTokens(v5Vault, amountIn);
    }

    /**
     * @notice Get the address that will receive `tokenIn`.
     * @param tokenIn Address of the token to get the target address for
     * @return address Address of the target
     */
    function targetOf(address tokenIn) external returns (address) {
        return address(v5PrizePool);
    }

    /**
     * @notice Checks if a liquidation pair can be used to liquidate the given tokenOut from this source.
     * @param _tokenOut The address of the token to liquidate
     * @param _liquidationPair The address of the liquidation pair that is being checked
     * @return bool True if the liquidation pair can be used, false otherwise
     */
    function isLiquidationPair(
        address _tokenOut,
        address _liquidationPair
    ) external returns (bool) {
        return
            liquidationPair == _liquidationPair &&
            _tokenOut == address(underlyingToken);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) external view returns (bool) {
        return (interfaceId == ERC165_INTERFACE_ID_ERC165 ||
            interfaceId == ERC165_INTERFACE_ID_TOKEN_LISTENER);
    }

    function beforeTokenMint(
        address _to,
        uint256 _amount,
        address _controlledToken,
        address _referrer
    ) external override {}
    function beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount,
        address _controlledToken
    ) external override {}

    modifier onlyLiquidationPair() {
        require(
            msg.sender == liquidationPair,
            "V3PrizePoolLiquidatorAdapter: caller is not the liquidation pair"
        );
        _;
    }
}
