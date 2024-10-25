// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Test, Vm } from "forge-std/Test.sol";

import { FixedPriceLiquidationPair, FixedPriceLiquidationPairFactory } from "pt-v5-fixed-price-liquidator/FixedPriceLiquidationPairFactory.sol";
import { FixedPriceLiquidationRouter } from "pt-v5-fixed-price-liquidator/FixedPriceLiquidationRouter.sol";

import { console2 } from "forge-std/console2.sol";

import {
    V3PrizePoolLiquidatorAdapter,
    V3PrizePoolInterface,
    V5PrizePoolInterface,
    IERC20
} from "../src/V3PrizePoolLiquidatorAdapter.sol";

contract TestVaults is Test {

    V5PrizePoolInterface public constant V5_PRIZE_POOL = V5PrizePoolInterface(0x7865D01da4C9BA2F69B7879e6d2483aB6B354d95);
    V3PrizePoolInterface public constant DAI_PRIZE_POOL = V3PrizePoolInterface(0xEBfb47A7ad0FD6e57323C8A42B2E5A6a4F68fc1a);
    address public constant DAI_CONTROLLED_TOKEN = 0x334cBb5858417Aee161B53Ee0D5349cCF54514CF;
    V3PrizePoolInterface public constant USDC_PRIZE_POOL = V3PrizePoolInterface(0xde9ec95d7708B8319CCca4b8BC92c0a3B70bf416);
    address public constant USDC_CONTROLLED_TOKEN = 0xD81b1A8B1AD00Baa2D6609E0BAE28A38713872f7;
    address public constant GOV = 0x42cd8312D2BCe04277dD5161832460e95b24262E;
    IERC20 public constant DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 public constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address public constant V5_VAULT = 0x9eE31E845fF1358Bf6B1F914d3918c6223c75573;
    IERC20 public constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    uint256 fork;
    uint256 forkBlock = 20986731;

    V3PrizePoolLiquidatorAdapter usdcAdapter;
    V3PrizePoolLiquidatorAdapter daiAdapter;

    FixedPriceLiquidationPairFactory pairFactory;
    FixedPriceLiquidationRouter router;

    function setUp() public {
        fork = vm.createFork(vm.rpcUrl("mainnet"), forkBlock);
        // fork = vm.createFork(vm.rpcUrl("mainnet"));
        vm.selectFork(fork);

        pairFactory = new FixedPriceLiquidationPairFactory();
        router = new FixedPriceLiquidationRouter(pairFactory);

        usdcAdapter = new V3PrizePoolLiquidatorAdapter(
            USDC_PRIZE_POOL,
            USDC_CONTROLLED_TOKEN,
            V5_PRIZE_POOL,
            V5_VAULT,
            GOV
        );

        daiAdapter = new V3PrizePoolLiquidatorAdapter(
            DAI_PRIZE_POOL,
            DAI_CONTROLLED_TOKEN,
            V5_PRIZE_POOL,
            V5_VAULT,
            GOV
        );

    }

    function testPullFunds() public {
        console2.log("USDC balance", USDC.balanceOf(GOV));
        console2.log("DAI balance", DAI.balanceOf(GOV));

        vm.startPrank(GOV);
        USDC_PRIZE_POOL.setPrizeStrategy(usdcAdapter);
        DAI_PRIZE_POOL.setPrizeStrategy(daiAdapter);
        usdcAdapter.setLiquidationPair(GOV);
        daiAdapter.setLiquidationPair(GOV);
        usdcAdapter.pullFunds();
        daiAdapter.pullFunds();
        vm.stopPrank();

        console2.log("USDC balance", USDC.balanceOf(GOV));
        console2.log("DAI balance", DAI.balanceOf(GOV));
    }

    function testLiquidate() public {
        address usdcPair = address(pairFactory.createPair(
            usdcAdapter,
            address(WETH),
            address(USDC),
            0.5 ether,
        0));
        address daiPair = address(pairFactory.createPair(
            usdcAdapter,
            address(WETH),
            address(DAI),
            0.5 ether,
        0));

        vm.startPrank(GOV);
        USDC_PRIZE_POOL.setPrizeStrategy(usdcAdapter);
        DAI_PRIZE_POOL.setPrizeStrategy(daiAdapter);
        usdcAdapter.setLiquidationPair(GOV);
        daiAdapter.setLiquidationPair(GOV);
        usdcAdapter.pullFunds();
        daiAdapter.pullFunds();
        usdcAdapter.setLiquidationPair(usdcPair);
        daiAdapter.setLiquidationPair(daiPair);
        vm.stopPrank();

        console2.log("GOV USDC balance", USDC.balanceOf(address(GOV)));
        console2.log("GOV DAI balance", DAI.balanceOf(address(GOV)));

        // progress time
        // vm.warp(block.timestamp + 300 days);
        vm.roll(block.number + 1851428);

        console2.log("USDC balance before", USDC.balanceOf(address(this)));
        console2.log("DAI balance before", DAI.balanceOf(address(this)));

        // liquidate
        deal(address(WETH), address(this), 0.5 ether);
        WETH.approve(address(router), 1 ether);
        router.swapExactAmountOut(
            FixedPriceLiquidationPair(usdcPair),
            address(this),
            4000e6,
            1 ether,
            block.timestamp + 100
        );

        console2.log("USDC balance", USDC.balanceOf(address(this)));
        console2.log("DAI balance", DAI.balanceOf(address(this)));
    }
}
