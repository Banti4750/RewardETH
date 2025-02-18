// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "openzeppelin/contracts/token/ERC20/ERC20.sol";
import "openzeppelin/contracts/access/Ownable.sol";

contract TrumpCoin is ERC20, Ownable {
    address public stakingContract;

    event StakingContractUpdated(address newStakingContract);

    constructor() ERC20("TrumpCoin", "TRUMP") {
        stakingContract = msg.sender;
    }

    modifier onlyStakingContract() {
        require(msg.sender == stakingContract, "Not staking contract");
        _;
    }

    function mint(address account, uint256 value) public onlyStakingContract {
        _mint(account, value);
    }

    function updateStakingContract(address _stakingContract) public onlyOwner {
        require(_stakingContract != address(0), "Zero address");
        stakingContract = _stakingContract;
        emit StakingContractUpdated(_stakingContract);
    }
}
