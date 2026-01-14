//  SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {LPToken} from "./LPToken.sol";

import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "lib/openzeppelin-contracts/contracts/utils/math/Math.sol";

contract AMM is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public usdc; //= 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    IERC20 public weth; //= 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

    uint256 public reserveWETH;
    uint256 public reserveUSDC;
    // fee transction minded to be 997/1000; (0.003 or 0.3%)
    LPToken public lpToken;

    // Events
    event AddLiquidity(
        address from,
        uint256 wethAmount,
        uint256 usdcAmount,
        uint256 lpTokensMinted,
        uint256 timestamp
    );

    event RemoveLiquidity(
        address from,
        uint256 lpTokensBurned,
        uint256 wethAmount,
        uint256 usdcAmount,
        uint256 timestamp
    );

    event SwapWETHforUSDC(
        address from,
        uint256 wethAmount,
        uint256 usdcAmount,
        uint256 timestamp
    );

    event SwapUSDCforWETH(
        address from,
        uint256 wethAmount,
        uint256 usdcAmount,
        uint256 timestamp
    );

    constructor(address owner_, address weth_, address usdc_) Ownable(owner_) {
        lpToken = new LPToken("lpToken", "LPT");
        weth = IERC20(weth_);
        usdc = IERC20(usdc_);
    }

    function addLiquidity(
        address to_,
        uint256 wethAmount_,
        uint256 usdcAmount_
    ) public {
        IERC20(weth).safeTransferFrom(to_, address(this), wethAmount_);
        IERC20(usdc).safeTransferFrom(to_, address(this), usdcAmount_);

        uint256 reserveWETH_ = reserveWETH;
        uint256 reserveUSDC_ = reserveUSDC;
        uint256 lpTokenTotalSupply_ = lpToken.totalSupply();

        uint256 lpMinted_;

        if (lpTokenTotalSupply_ != 0) {
            lpMinted_ = Math.min(
                (wethAmount_ * lpTokenTotalSupply_) / reserveWETH_,
                (usdcAmount_ * lpTokenTotalSupply_) / reserveUSDC_
            );
        } else {
            lpMinted_ = Math.sqrt(wethAmount_ * usdcAmount_);
        }

        reserveWETH += wethAmount_;
        reserveUSDC += usdcAmount_;

        lpToken.mint(to_, lpMinted_);

        emit AddLiquidity(
            to_,
            wethAmount_,
            usdcAmount_,
            lpMinted_,
            block.timestamp
        );
    }

    function removeLiquidity(address to_, uint256 lpTokensAmount_) public {
        require(
            lpToken.balanceOf(to_) >= lpTokensAmount_,
            "INSUFFICIENT_LPTOKEN_BALANCE"
        );

        uint256 totalLiquidity_ = lpToken.totalSupply();
        uint256 amountWETH_ = (lpTokensAmount_ * reserveWETH) / totalLiquidity_;
        uint256 amountUSDC_ = (lpTokensAmount_ * reserveUSDC) / totalLiquidity_;

        weth.transfer(to_, amountWETH_);
        usdc.transfer(to_, amountUSDC_);

        reserveWETH -= amountWETH_;
        reserveUSDC -= amountUSDC_;

        lpToken.burn(to_, lpTokensAmount_);
        emit RemoveLiquidity(
            to_,
            lpTokensAmount_,
            amountWETH_,
            amountUSDC_,
            block.timestamp
        );
    }

    function swapWETHforUSDC(
        address to_,
        uint256 amountIn_,
        uint256 minOut_
    ) external {
        require(amountIn_ > 0, "AMOUNTIN_CANNOT_BE_ZERO");

        uint256 amountOut_ = getAmountOut(amountIn_, reserveWETH, reserveUSDC);

        require(amountOut_ >= minOut_, "SLIPPAGE_EXCEEDED");

        IERC20(weth).safeTransferFrom(to_, address(this), amountIn_);
        // efectos
        reserveWETH += amountIn_;
        reserveUSDC -= amountOut_;

        // interacciones
        usdc.transfer(to_, amountOut_);
        emit SwapWETHforUSDC(to_, amountIn_, amountOut_, block.timestamp);
    }

    function swapUSDCforWETH(
        address to_,
        uint256 amountIn_,
        uint256 minOut_
    ) external {
        require(amountIn_ > 0, "AMOUNTIN_CANNOT_BE_ZERO");

        uint256 amountOut_ = getAmountOut(amountIn_, reserveUSDC, reserveWETH);

        require(amountOut_ >= minOut_, "SLIPPAGE_EXCEEDED");
        IERC20(usdc).safeTransferFrom(to_, address(this), amountIn_);

        reserveUSDC += amountIn_;
        reserveWETH -= amountOut_;

        weth.transfer(to_, amountOut_);
        emit SwapWETHforUSDC(to_, amountOut_, amountIn_, block.timestamp);
    }

    function getReserves() public view returns (uint256, uint256) {
        return (reserveWETH, reserveUSDC);
    }

    function getAmountOut(
        uint256 amountIn_,
        uint256 reserveIn_,
        uint256 reserveOut_
    ) internal pure returns (uint256 amountOut) {
        require(reserveIn_ > 0 && reserveOut_ > 0, "NO_LIQUIDITY");

        uint256 amountInWithFee = (amountIn_ * 997) / 1000;

        // x * y = k
        // reserveIn * reserveOut = k
        // (x + dx)(y - dy) = k

        // (reserveIn + amountIn) * (reserveOut - amountOut) = k
        // Juntando nuestras dosformulas anteriores:
        // (x + dx)(y - dy) = x * y
        // xy - x*dy + dx*y - dx*dy = xy
        // - x*dy + dx*y -dx*dy = 0
        // dx*y = x*dy + dx*dy
        // dx*y = dy(x +dx)
        // dy = (dx*y) / (x +dx)
        // amountOut = (mountInWithFee * reserveOut) / (reserveIn + amountInWithFee)
        // x = (0.997 * 300 000)/ (100 + 0.997)
        // x =  299 100 / 100.997
        uint256 numerator = amountInWithFee * reserveOut_;
        uint256 denominator = reserveIn_ + amountInWithFee;

        amountOut = numerator / denominator;
    }
}
