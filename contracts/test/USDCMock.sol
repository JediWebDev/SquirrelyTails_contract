// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @notice Simple ERC20 token with 6 decimals to mock USDC in tests
contract USDCMock is ERC20 {
    constructor() ERC20("USD Coin", "USDC") {
        _mint(msg.sender, 1_000_000_000 * 10**decimals());
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }
}
