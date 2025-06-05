// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract SafeApproveCaller {
    using SafeERC20 for IERC20;

    constructor(IERC20 token, address spender) {
        token.safeApprove(spender, type(uint256).max);
    }
}
