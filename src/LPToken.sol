//  SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract LPToken is ERC20 {
    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {}

    // Mint Tokens
    function mint(address to, uint256 LPTokensAmount) public {
        _mint(to, LPTokensAmount);
    }

    // Burn Tokens
    function burn(address from, uint256 LPTokensAmount) public {
        _burn(from, LPTokensAmount);
    }
}
