// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title SQLY Token Sale
/// @notice Accepts USDC in exchange for SQLY tokens and forwards the USDC to a
/// designated wallet.
contract SQLYTokenSale is Ownable {
    using SafeERC20 for IERC20Metadata;

    IERC20Metadata public immutable sqlyToken;
    IERC20Metadata public immutable usdcToken;
    address public immutable wallet;

    // Number of smallest SQLY units a buyer gets for 1 USDC (10^USDC decimals)
    uint256 public tokensPerUsdc;

    event TokensPurchased(address indexed purchaser, uint256 usdcAmount, uint256 sqlyAmount);

    constructor(
        IERC20Metadata _sqlyToken,
        IERC20Metadata _usdcToken,
        address _wallet,
        uint256 _tokensPerUsdc
    ) {
        require(address(_sqlyToken) != address(0), "Invalid SQLY token");
        require(address(_usdcToken) != address(0), "Invalid USDC token");
        require(_wallet != address(0), "Invalid wallet");

        sqlyToken = _sqlyToken;
        usdcToken = _usdcToken;
        wallet = _wallet;
        tokensPerUsdc = _tokensPerUsdc;
    }

    /// @notice Update the exchange rate
    /// @param newRate Number of SQLY smallest units per 1 USDC
    function setRate(uint256 newRate) external onlyOwner {
        tokensPerUsdc = newRate;
    }

    /// @notice Buy SQLY tokens using USDC
    /// @param usdcAmount Amount of USDC (in smallest units) to spend
    function buy(uint256 usdcAmount) external {
        require(usdcAmount > 0, "Amount must be > 0");

        uint256 sqlyAmount = (usdcAmount * tokensPerUsdc) / (10 ** usdcToken.decimals());

        usdcToken.safeTransferFrom(msg.sender, wallet, usdcAmount);
        sqlyToken.safeTransfer(msg.sender, sqlyAmount);

        emit TokensPurchased(msg.sender, usdcAmount, sqlyAmount);
    }
}
