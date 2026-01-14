//  SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {LPToken} from "src/LPToken.sol";
import {AMM} from "src/AMM.sol";

import {WETHMock} from "test/mocks/WETHMock.sol";
import {USDCMock} from "test/mocks/USDCMock.sol";
import {AMMTestBases} from "test/helpers/AMMTestBase.t.sol";

import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "lib/openzeppelin-contracts/contracts/utils/math/Math.sol";

contract SwapWETHforUSDC is AMMTestBases {
    function testSwapWETHforUSDCRevertByAmountCanNotBeZero() public {
        uint256 wethAmount = 10;
        uint256 usdcAmount = 30;
        _addInitialLiquidity(wethAmount, usdcAmount);

        vm.startPrank(user);

        vm.expectRevert("AMOUNTIN_CANNOT_BE_ZERO");
        amm.swapWETHforUSDC(user, 0, 0);

        vm.stopPrank();
    }

    function testSwapWETHforUSDCRevertByReservesCanNotBeZero() public {
        vm.startPrank(user);

        vm.expectRevert("NO_LIQUIDITY");
        amm.swapWETHforUSDC(user, 1, 0);

        vm.stopPrank();
    }

    function testSwapWETHforUSDCBRevertByZlippageExceeded() public {
        uint256 wethAmount = 10;
        uint256 usdcAmount = 30;
        _addInitialLiquidity(wethAmount, usdcAmount);

        vm.startPrank(user);

        vm.expectRevert("SLIPPAGE_EXCEEDED");
        amm.swapWETHforUSDC(user, 1, 1e3);

        vm.stopPrank();
    }

    function testSwapWETHforUSDCCorrectly() public {
        uint256 wethAmount = 100;
        uint256 usdcAmount = 300000;
        _addInitialLiquidity(wethAmount, usdcAmount);

        vm.startPrank(user);
        uint256 wethToSwap = 1e18;

        (uint256 contractWethBefore_, uint256 contractUsdcBefore_) = amm
            .getReserves();

        uint256 userWethBefore_ = weth.balanceOf(user);
        uint256 userUsdcBefore_ = usdc.balanceOf(user);
        uint256 kBefore = contractUsdcBefore_ * contractWethBefore_;

        amm.swapWETHforUSDC(user, wethToSwap, 2500);

        (uint256 contractWethAfter_, uint256 contractUsdcAfter_) = amm
            .getReserves();
        uint256 userWethAfter_ = weth.balanceOf(user);
        uint256 userUsdcAfter_ = usdc.balanceOf(user);
        uint256 kAfter = contractUsdcAfter_ * contractWethAfter_;

        assert(kAfter >= kBefore);
        assertEq(
            userUsdcAfter_ - userUsdcBefore_,
            contractUsdcBefore_ - contractUsdcAfter_
        );
        assertEq(
            userWethBefore_ - userWethAfter_,
            contractWethAfter_ - contractWethBefore_
        );

        vm.stopPrank();
    }
}
