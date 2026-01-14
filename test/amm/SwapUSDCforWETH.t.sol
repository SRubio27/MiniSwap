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

contract SwapUSDCforWETH is AMMTestBases {
    function testSwapUSDCforWETHRevertByAmountCanNotBeZero() public {
        uint256 wethAmount = 10;
        uint256 usdcAmount = 30;
        _addInitialLiquidity(wethAmount, usdcAmount);

        vm.startPrank(user);

        vm.expectRevert("AMOUNTIN_CANNOT_BE_ZERO");
        amm.swapUSDCforWETH(user, 0, 0);

        vm.stopPrank();
    }

    function testSwapUSDCforWETHRevertByReservesCanNotBeZero() public {
        vm.startPrank(user);

        vm.expectRevert("NO_LIQUIDITY");
        amm.swapUSDCforWETH(user, 1, 0);

        vm.stopPrank();
    }

    function testSwapUSDCforWETHRevertByZlippageExceeded() public {
        uint256 wethAmount = 10;
        uint256 usdcAmount = 30;
        _addInitialLiquidity(wethAmount, usdcAmount);

        vm.startPrank(user);

        vm.expectRevert("SLIPPAGE_EXCEEDED");
        amm.swapUSDCforWETH(user, 1, 1e3);

        vm.stopPrank();
    }

    function testSwapUSDCforWETHCorrectly() public {
        uint256 wethAmount = 10;
        uint256 usdcAmount = 30;
        _addInitialLiquidity(wethAmount, usdcAmount);

        vm.startPrank(user);
        uint256 usdcToSwap = 5 * 1e6;

        (uint256 contractWethBefore_, uint256 contractUsdcBefore_) = amm
            .getReserves();

        uint256 userWethBefore_ = weth.balanceOf(user);
        uint256 userUsdcBefore_ = usdc.balanceOf(user);
        uint256 kBefore = contractUsdcBefore_ * contractWethBefore_;

        amm.swapUSDCforWETH(user, usdcToSwap, 1);

        (uint256 contractWethAfter_, uint256 contractUsdcAfter_) = amm
            .getReserves();
        uint256 userWethAfter_ = weth.balanceOf(user);
        uint256 userUsdcAfter_ = usdc.balanceOf(user);
        uint256 kAfter = contractUsdcAfter_ * contractWethAfter_;

        assert(kAfter >= kBefore);
        assertEq(
            userUsdcBefore_ - userUsdcAfter_,
            contractUsdcAfter_ - contractUsdcBefore_
        );
        assertEq(
            userWethAfter_ - userWethBefore_,
            contractWethBefore_ - contractWethAfter_
        );

        vm.stopPrank();
    }
}
