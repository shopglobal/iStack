//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ISTAKEPOOL {
    function Governor() external view returns(address payable);
    function Operator() external view returns(address payable);
    function Manager() external view returns (address payable);
    function StakePool() external view returns(address payable);
    function StakeToken() external view returns (address payable);
    function StakingToken(uint pool_id) external view returns (address payable);
    function RewardsToken(uint pool_id) external view returns(address payable);
    function Swap_iStack(uint256 amount, address payable from_address, address payable to_address, uint pool_id) external returns (bool);
    function setStakeToken(address payable token) external returns(bool); 
    function setStakingToken(address payable stakingToken, uint pool_id) external returns(bool);
    function setRewardsToken(address payable rewardsToken, uint pool_id) external returns(bool);
    function balance(address wallet, address token) external view returns (uint);
    function balanceOf_iStack(uint stackId, address token) external view returns (uint256);
    function UnStake_Tokens(uint256 amount, address payable _address, uint pool_id) external returns (bool);
    function UnStake_Network_Tokens(address token) external returns (bool);
    function setManager(address payable _manager) external returns(bool);
    function Stake_Tokens(uint256 amount, address payable _address, uint pool_id) external returns (bool);
    function EMERGENCY_WITHDRAW_Ether() external payable;
    function EMERGENCY_WITHDRAW_Token(address token) external;
}
