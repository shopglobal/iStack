//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IREWARDSPOOL {
    function Governor() external view returns(address payable);
    function Operator() external view returns(address payable);
    function Manager() external view returns (address payable);
    function StakePool() external view returns(address payable);
    // function EJECT(address payable token_) external payable;
    // function Sync_CrossChain() external;
    // function Sync_CrossChain_byWallet(address payable _wallet) external returns(bool);
    function StakeToken() external view returns (address payable);
    function StakingToken() external view returns (address payable);
    function RewardsToken() external view returns(address payable);
    function RewardsPool() external view returns (address payable);
    function CrossChain_Debt_byWallet(address __wallet) external returns(uint);
    function set_Token(address payable _wallet, uint token) external returns(bool);
    function set_CrossChain(address payable _wallet, uint crosschain) external returns(bool);
    function CrossChain_Debt() external view returns (uint);
    function Token_Debt() external view returns (uint);
    function Accounts() external view returns (address payable[] memory);
    function Process_Reward_Bulk(uint256[] memory amount, address payable[] memory _address, bool _crosschain) external;
    function CrossChain_Genesis_Bulk(uint256[] memory amount, address payable[] memory _address, bool _isToken, bool up) external;
    function CrossChain_Genesis(uint256 amount, address payable _address, bool _isToken, bool up) external;
    function setStakeToken(address payable stakeToken) external returns(bool);
    function setStakingToken(address payable stakingToken) external returns(bool);
    function setRewardsToken(address payable rewardsToken) external returns(bool);
    function setRewardsPool(address payable _rewardsPool) external returns(bool);
    function setManager(address payable _manager) external returns(bool);
    function setProcessing(bool _processing, bool crosschain) external returns(bool);
    function Process_Rewards(bool crosschain) external returns(bool);
    function Process_Reward(uint256 amount, address payable _address, bool crosschain) external returns (bool);
    function Account(uint _i) external view returns (address payable);
    function Deliver_Reward_Coins(uint256 amount, address payable _address) external returns (bool);
    function Deliver_Reward_Tokens(uint256 amount, address payable _address) external returns (bool);
    function EMERGENCY_WITHDRAW_Ether() external payable;
    function EMERGENCY_WITHDRAW_Token(address token) external;
}