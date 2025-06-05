// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract SquirrelyTailsToken is ERC20, Ownable, Pausable {

    mapping(address => bool) private _isExcludedFromFee;

    // Anti-bot features
    mapping(address => bool) public isBot;
    uint256 public maxTxAmount;
    uint256 public maxWalletAmount;

    constructor() ERC20("SquirrelyTails", "SQLY") {
        uint256 totalInitialSupply = 50_000_000 * 10**decimals();
        uint256 ownerTokens = 5_000_000 * 10**decimals();
        uint256 contractTokens = totalInitialSupply - ownerTokens;

        // Mint initial tokens
        _mint(msg.sender, ownerTokens);
        _mint(address(this), contractTokens);

        // Exclude owner and contract from fees
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;

        // Set default anti-bot limits (modifiable by owner)
        maxTxAmount = 1_000_000 * 10**decimals();     // e.g., 1M tokens per tx
        maxWalletAmount = 5_000_000 * 10**decimals(); // e.g., 5M tokens per wallet

    }

    // Minting by owner
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    // Owner controls
    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    // Anti-bot management
    function setBot(address account, bool flagged) external onlyOwner {
        isBot[account] = flagged;
    }
    function setMaxTxAmount(uint256 amount) external onlyOwner {
        maxTxAmount = amount;
    }
    function setMaxWalletAmount(uint256 amount) external onlyOwner {
        maxWalletAmount = amount;
    }

    // Pause transfers when needed
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    // Core transfer override: anti-bot and anti-whale controls
    function _transfer(address from, address to, uint256 amount) internal override {
        require(!isBot[from] && !isBot[to], "Bot address detected");

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            super._transfer(from, to, amount);
        } else {
            // Enforce max transaction amount
            if (maxTxAmount > 0) {
                require(amount <= maxTxAmount, "Exceeds maxTxAmount");
            }

            super._transfer(from, to, amount);

            // Enforce max wallet size
            if (maxWalletAmount > 0 && !_isExcludedFromFee[to] && to != owner()) {
                require(balanceOf(to) <= maxWalletAmount, "Exceeds maxWalletAmount");
            }

        }
    }
}
