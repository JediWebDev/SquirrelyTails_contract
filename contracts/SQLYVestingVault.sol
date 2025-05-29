// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SQLYVestingVault is Ownable {
    IERC20 public immutable token;

    struct Vesting {
        uint256 total;
        uint256 released;
        uint256 start;
        uint256 cliff;
        uint256 duration;
    }

    mapping(address => Vesting) public vestingSchedules;
    address[] public beneficiaries;

    event TokensReleased(address beneficiary, uint256 amount);
    event VestingCreated(address beneficiary, uint256 total, uint256 start);

    constructor(IERC20 _token) {
        token = _token;
    }

    function createVesting(
        address beneficiary,
        uint256 totalAmount,
        uint256 startTime,
        uint256 cliffDuration,
        uint256 vestingDuration
    ) external onlyOwner {
        require(vestingSchedules[beneficiary].total == 0, "Vesting already exists");
        vestingSchedules[beneficiary] = Vesting({
            total: totalAmount,
            released: 0,
            start: startTime,
            cliff: startTime + cliffDuration,
            duration: vestingDuration
        });
        beneficiaries.push(beneficiary);

        emit VestingCreated(beneficiary, totalAmount, startTime);
    }

    function release() external {
        Vesting storage vest = vestingSchedules[msg.sender];
        require(block.timestamp >= vest.cliff, "Cliff not reached");

        uint256 vested = _vestedAmount(vest);
        uint256 unreleased = vested - vest.released;
        require(unreleased > 0, "No tokens to release");

        vest.released += unreleased;
        token.transfer(msg.sender, unreleased);

        emit TokensReleased(msg.sender, unreleased);
    }

    function _vestedAmount(Vesting memory vest) internal view returns (uint256) {
        if (block.timestamp < vest.cliff) {
            return 0;
        } else if (block.timestamp >= vest.start + vest.duration) {
            return vest.total;
        } else {
            return (vest.total * (block.timestamp - vest.start)) / vest.duration;
        }
    }

    function getReleasableAmount(address user) external view returns (uint256) {
        Vesting memory vest = vestingSchedules[user];
        uint256 vested = _vestedAmount(vest);
        return vested - vest.released;
    }

    function getAllVestingSchedules() external view returns (address[] memory, Vesting[] memory) {
        uint256 count = beneficiaries.length;
        Vesting[] memory allVestings = new Vesting[](count);
        for (uint256 i = 0; i < count; i++) {
            allVestings[i] = vestingSchedules[beneficiaries[i]];
        }
        return (beneficiaries, allVestings);
    }
}
