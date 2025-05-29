// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IUniswapV2Router02 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}

contract SquirrelyTailsToken is ERC20, Ownable, Pausable {
    using SafeERC20 for IERC20;

    // Fee settings
    uint256 public feePercent = 5;
    bool public swapAndLiquifyEnabled = true;
    bool private inSwapAndLiquify;
    IUniswapV2Router02 public router = IUniswapV2Router02(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff);
    address public USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;

    mapping(address => bool) private _isExcludedFromFee;

    // Anti-bot features
    mapping(address => bool) public isBot;
    uint256 public maxTxAmount;
    uint256 public maxWalletAmount;

    event SwapAndLiquify(uint256 tokensSwapped, uint256 usdcReceived, uint256 tokensIntoLiquidity);

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

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

        // Approvals for router
        _approve(address(this), address(router), type(uint256).max);
        IERC20(USDC).safeApprove(address(router), type(uint256).max);
    }

    // Minting by owner
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    // Owner controls
    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
    function setFeePercent(uint256 newFee) external onlyOwner {
        require(newFee <= 20, "Fee too high");
        feePercent = newFee;
    }
    function setSwapAndLiquifyEnabled(bool enabled) external onlyOwner {
        swapAndLiquifyEnabled = enabled;
    }
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

    // Core transfer override: fee, anti-bot, anti-whale, swap & liquify
    function _transfer(address from, address to, uint256 amount) internal override {
        require(!isBot[from] && !isBot[to], "Bot address detected");

        if (inSwapAndLiquify || _isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            super._transfer(from, to, amount);
        } else {
            // Enforce max transaction amount
            if (maxTxAmount > 0) {
                require(amount <= maxTxAmount, "Exceeds maxTxAmount");
            }

            // Calculate fee and send amount
            uint256 feeAmount = amount * feePercent / 100;
            uint256 sendAmount = amount - feeAmount;

            super._transfer(from, address(this), feeAmount);
            super._transfer(from, to, sendAmount);

            // Enforce max wallet size
            if (maxWalletAmount > 0 && !_isExcludedFromFee[to] && to != owner()) {
                require(balanceOf(to) <= maxWalletAmount, "Exceeds maxWalletAmount");
            }

            // Swap & add liquidity
            if (swapAndLiquifyEnabled) {
                _swapAndLiquify(feeAmount);
            }
        }
    }

    function _swapAndLiquify(uint256 tokenAmount) private lockTheSwap {
        uint256 half = tokenAmount / 2;
        uint256 otherHalf = tokenAmount - half;
        uint256 initialUSDC = IERC20(USDC).balanceOf(address(this));

        _swapTokensForUSDC(half);

        uint256 newUSDC = IERC20(USDC).balanceOf(address(this)) - initialUSDC;

        router.addLiquidity(
            address(this),
            USDC,
            otherHalf,
            newUSDC,
            0,
            0,
            owner(),
            block.timestamp
        );

        emit SwapAndLiquify(half, newUSDC, otherHalf);
    }

    function _swapTokensForUSDC(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDC;

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}
