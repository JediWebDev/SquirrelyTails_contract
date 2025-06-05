// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20Approve {
    function approve(address spender, uint256 amount) external returns (bool);
}

contract ApproveCaller {
    constructor(IERC20Approve token, address spender) {
        token.approve(spender, type(uint256).max);
    }
}
