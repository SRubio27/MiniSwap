//  SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {LPToken} from "src/LPToken.sol";
import {AMM} from "src/AMM.sol";
import {WETHMock} from "test/mocks/WETHMock.sol";
import {USDCMock} from "test/mocks/USDCMock.sol";
import {AMMTestBases} from "test/helpers/AMMTestBase.t.sol";
import {Test} from "forge-std/Test.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "lib/openzeppelin-contracts/contracts/utils/math/Math.sol";

contract AddLiquidity is AMMTestBases {
    function testAddLiquidityAndFirstMintLpTokensCorrectly() public {
        vm.startPrank(owner);
        uint256 wethAmount_ = 1;
        uint256 usdcAmount_ = 3;

        (uint256 reserveWETHBefore_, uint256 reserveUSDCBefore_) = amm
            .getReserves();

        _addInitialLiquidity(wethAmount_, usdcAmount_);
        uint256 lpTokenLiquidityAdded_ = lpToken.totalSupply();

        uint256 userLpTokensAfter_ = amm.lpToken().balanceOf(owner);
        (uint256 reserveWETHAfter_, uint256 reserveUSDCAfter_) = amm
            .getReserves();

        assert(reserveUSDCAfter_ - reserveUSDCBefore_ == usdcAmount_);
        assert(reserveWETHAfter_ - reserveWETHBefore_ == wethAmount_);
        assert(lpTokenLiquidityAdded_ == Math.sqrt(wethAmount_ * usdcAmount_));
        assert(userLpTokensAfter_ == lpTokenLiquidityAdded_);
        vm.stopPrank();
    }

    function testAddLiquidityAndMintLpTokensCorrectly() public {
        uint256 wethAmount = 1;
        uint256 usdcAmount = 3;

        _addInitialLiquidity(wethAmount, usdcAmount);
        uint256 lpTokenLiquidityBefore_ = lpToken.totalSupply();

        uint256 userLpTokensBefore_ = amm.lpToken().balanceOf(user);

        (uint256 reserveWETHBefore_, uint256 reserveUSDCBefore_) = amm
            .getReserves();

        uint256 lpTokensShouldBeMinted = Math.min(
            (wethAmount * lpTokenLiquidityBefore_) / reserveWETHBefore_,
            (usdcAmount * lpTokenLiquidityBefore_) / reserveUSDCBefore_
        );

        _addLiquidity(user, wethAmount, usdcAmount);
        uint256 lpTokenLiquidityAfter_ = lpToken.totalSupply();
        uint256 userLpTokensAfter_ = amm.lpToken().balanceOf(user);

        (uint256 reserveWETHAfter_, uint256 reserveUSDCAfter_) = amm
            .getReserves();
        uint256 reservesWETHByIERC20After = weth.balanceOf(address(amm));
        uint256 reservesUSDCByIERC20After = usdc.balanceOf(address(amm));

        assertEq(reserveWETHAfter_, reservesWETHByIERC20After);
        assertEq(reserveUSDCAfter_, reservesUSDCByIERC20After);

        assertEq(reserveUSDCAfter_ - reserveUSDCBefore_, usdcAmount);
        assertEq(reserveWETHAfter_ - reserveWETHBefore_, wethAmount);
        assert(
            lpTokensShouldBeMinted ==
                lpTokenLiquidityAfter_ - lpTokenLiquidityBefore_
        );
        assert(
            userLpTokensAfter_ - userLpTokensBefore_ == lpTokensShouldBeMinted
        );

        vm.stopPrank();
    }
}
