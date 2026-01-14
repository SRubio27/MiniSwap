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

contract RemoveLiquidity is AMMTestBases {
    function testRevertByInsufficientLpTokenBalance() public {
        vm.startPrank(user);
        uint256 lpTokensToRemove = IERC20(lpToken).balanceOf(user);

        vm.expectRevert("INSUFFICIENT_LPTOKEN_BALANCE");
        amm.removeLiquidity(user, lpTokensToRemove + 1);

        vm.stopPrank();
    }

    function testRemoveLiquidityCorrectly() public {
        uint256 wethAmount = 1;
        uint256 usdcAmount = 3;
        _addInitialLiquidity(wethAmount, usdcAmount);

        vm.startPrank(owner);
        uint256 lpTokensToRemove = IERC20(lpToken).balanceOf(owner);

        uint256 userUsdcBefore_ = IERC20(usdc).balanceOf(owner);
        uint256 userWethBefore_ = IERC20(weth).balanceOf(owner);
        (uint256 contractWethBefore_, uint256 contractUsdcBefore_) = amm
            .getReserves();
        amm.removeLiquidity(owner, lpTokensToRemove);
        uint256 userUsdcAfter_ = IERC20(usdc).balanceOf(owner);
        uint256 userWethAfter_ = IERC20(weth).balanceOf(owner);
        uint256 userLpTokensAfter_ = IERC20(lpToken).balanceOf(owner);
        (uint256 contractUsdcAfter_, uint256 contractWethAfter_) = amm
            .getReserves();

        // uint256 userUsdcAdded = userUsdcAfter_ - userUsdcBefore_;
        // uint256 userWethAdded = userWethAfter_ - userWethBefore_;

        uint256 contractUsdcRemoved = contractUsdcBefore_ - contractUsdcAfter_;
        uint256 contractWethRemoved = contractWethBefore_ - contractWethAfter_;

        assertEq(userLpTokensAfter_, 0);
        assertEq(userUsdcAfter_ - userUsdcBefore_, contractUsdcRemoved);
        assertEq(userWethAfter_ - userWethBefore_, contractWethRemoved);
        // assert(userWethBefore_ == userWethAfter_ - contractWethRemoved);

        vm.stopPrank();

        // Calcular valores de monedas al hacer removeLiquidity,
        //  probar los intereses haciendo transacciones gigantes
    }
}
