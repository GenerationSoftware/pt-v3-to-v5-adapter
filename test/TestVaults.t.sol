// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Test, Vm } from "forge-std/Test.sol";

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

    uint256 fork;
    uint256 forkBlock = 20986731;

    V3PrizePoolLiquidatorAdapter usdcAdapter;
    V3PrizePoolLiquidatorAdapter daiAdapter;

    function setUp() public {
        fork = vm.createFork(vm.rpcUrl("mainnet"), forkBlock);
        // fork = vm.createFork(vm.rpcUrl("mainnet"));
        vm.selectFork(fork);

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
        vm.startPrank(GOV);
        USDC_PRIZE_POOL.setPrizeStrategy(usdcAdapter);
        DAI_PRIZE_POOL.setPrizeStrategy(daiAdapter);
        usdcAdapter.setLiquidationPair(GOV);
        daiAdapter.setLiquidationPair(GOV);
        usdcAdapter.pullFunds();
        daiAdapter.pullFunds();
        vm.stopPrank();
    }
}
