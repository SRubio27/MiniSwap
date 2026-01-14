//  SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {LPToken} from "src/LPToken.sol";
import {AMM} from "src/AMM.sol";
import {WETHMock} from "test/mocks/WETHMock.sol";
import {USDCMock} from "test/mocks/USDCMock.sol";
import {Test} from "forge-std/Test.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "lib/openzeppelin-contracts/contracts/utils/math/Math.sol";

contract AMMTestBases is Test {
    AMM internal amm;
    LPToken internal lpToken;
    WETHMock internal weth;
    USDCMock internal usdc;

    // Users Addresses
    address internal owner = vm.addr(1);
    address internal user = vm.addr(2);

    function setUp() public {
        weth = new WETHMock();
        usdc = new USDCMock();

        owner = vm.addr(1);
        user = vm.addr(2);

        vm.startPrank(owner);
        amm = new AMM(owner, address(weth), address(usdc));
        lpToken = amm.lpToken();

        weth.mint(owner, 200 ether); // ether == 18decimals
        usdc.mint(owner, 300 * 1e6);

        weth.mint(user, 100 ether); // ether == 18decimals
        usdc.mint(user, 300 * 1e6);

        IERC20(weth).approve(address(amm), type(uint256).max);
        IERC20(usdc).approve(address(amm), type(uint256).max);
        vm.stopPrank();

        vm.startPrank(user);
        IERC20(weth).approve(address(amm), type(uint256).max);
        IERC20(usdc).approve(address(amm), type(uint256).max);
        vm.stopPrank();
    }

    function _addInitialLiquidity(
        uint256 wethAmount_,
        uint256 usdcAmount_
    ) internal {
        vm.startPrank(owner);
        amm.addLiquidity(owner, wethAmount_, usdcAmount_);
        vm.stopPrank();
    }

    function _addLiquidity(
        address minter,
        uint256 wethAmount_,
        uint256 usdcAmount_
    ) internal {
        vm.startPrank(minter);
        amm.addLiquidity(minter, wethAmount_, usdcAmount_);
        vm.stopPrank();
    }
}
