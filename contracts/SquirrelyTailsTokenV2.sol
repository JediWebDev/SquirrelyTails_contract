// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @notice A plain ERC-20 token (100 000 000 supply), no pausable, no minting, no restrictions.
contract SquirrelyTailsTokenV2 is ERC20 {
    constructor() ERC20("SquirrelyTails", "SQLY") {
        // Mint exactly 100 000 000 tokens to the deployer’s address.
        _mint(msg.sender, 100_000_000 * 10**decimals());
    }
}
