//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IREWARDSPOOL {
    function Governor() external view returns(address payable);
    function Operator() external view returns(address payable);
    function Manager() external view returns (address payable);
    function StakePool() external view returns(address payable);
    // function EJECT(address payable token_) external payable;
    function StakeToken() external view returns (address payable);
    function StakingToken() external view returns (address payable);
    // function RewardsToken() external view returns(address payable);
    // function RewardsPool() external view returns (address payable);
    function set_Token(address payable _wallet, uint token) external returns(bool);
    function Token_Debt() external view returns (uint);
    function Accounts() external view returns (address payable[] memory);
    function Process_Reward_Bulk(uint256[] memory amount, address payable[] memory _address) external;
    function setStakeToken(address payable stakeToken) external returns(bool);
    function setStakingToken(address payable stakingToken) external returns(bool);
    // function setRewardsToken(address payable rewardsToken) external returns(bool);
    // function setRewardsPool(address payable _rewardsPool) external returns(bool);
    function setManager(address payable _manager) external returns(bool);
    function setProcessing(bool _processing) external returns(bool);
    function Process_Rewards() external returns(bool);
    function Process_Reward(uint256 amount, address payable _address) external returns (bool);
    function Account(uint _i) external view returns (address payable);
    // function Deliver_Reward_Coins(uint256 amount, address payable _address) external returns (bool);
    function Deliver_Reward_Tokens(uint256 amount, address payable _address) external returns (bool);
    function EMERGENCY_WITHDRAW_Ether() external payable;
    function EMERGENCY_WITHDRAW_Token(address token) external;
}