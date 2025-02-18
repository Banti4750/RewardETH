// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "openzeppelin/contracts/token/ERC20/IERC20.sol";
import "openzeppelin/contracts/security/ReentrancyGuard.sol";
import "openzeppelin/contracts/utils/math/SafeMath.sol";

interface ITrumpCoin is IERC20 {
    function mint(address account, uint256 value) external;
}

contract StakeContract is ReentrancyGuard {
    using SafeMath for uint256;

    // State variables
    mapping(address => uint256) public balances;
    mapping(address => uint256) public unclaimedRewards;
    mapping(address => uint256) public lastUpdateTime;

    ITrumpCoin public trumpCoin;
    address public owner;
    uint256 public constant REWARD_RATE = 1e15; // 0.001 tokens per second per ETH staked
    bool public paused;

    // Events
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 amount);

    constructor(address _trumpCoin) {
        trumpCoin = ITrumpCoin(_trumpCoin);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier notPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    function stake() public payable nonReentrant notPaused {
        require(msg.value > 0, "Cannot stake 0");

        _updateRewards(msg.sender);
        balances[msg.sender] = balances[msg.sender].add(msg.value);

        emit Staked(msg.sender, msg.value);
    }

    function unstake(uint256 amount) public nonReentrant notPaused {
        require(amount > 0, "Cannot unstake 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        _updateRewards(msg.sender);
        balances[msg.sender] = balances[msg.sender].sub(amount);

        // Transfer after state updates (CEI pattern)
        payable(msg.sender).transfer(amount);

        emit Unstaked(msg.sender, amount);
    }

    function _updateRewards(address _user) internal {
        if (balances[_user] > 0) {
            uint256 timeElapsed = block.timestamp.sub(lastUpdateTime[_user]);
            uint256 newReward = timeElapsed
                .mul(REWARD_RATE)
                .mul(balances[_user])
                .div(1e18);
            unclaimedRewards[_user] = unclaimedRewards[_user].add(newReward);
        }
        lastUpdateTime[_user] = block.timestamp;
    }

    function getRewards(address _address) public view returns (uint256) {
        if (balances[_address] == 0) return unclaimedRewards[_address];

        uint256 timeElapsed = block.timestamp.sub(lastUpdateTime[_address]);
        uint256 newReward = timeElapsed
            .mul(REWARD_RATE)
            .mul(balances[_address])
            .div(1e18);
        return unclaimedRewards[_address].add(newReward);
    }

    function claimRewards() public nonReentrant notPaused {
        _updateRewards(msg.sender);

        uint256 reward = unclaimedRewards[msg.sender];
        require(reward > 0, "No rewards to claim");

        unclaimedRewards[msg.sender] = 0;

        // Call TrumpCoin contract to mint rewards
        trumpCoin.mint(msg.sender, reward);

        emit RewardsClaimed(msg.sender, reward);
    }

    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
    }

    function emergencyWithdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function balanceOf(address _address) public view returns (uint256) {
        return balances[_address];
    }
}
