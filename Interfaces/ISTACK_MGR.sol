//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ISTAKE_MGR {
    function Governor() external view returns(address payable);
    function Operator() external view returns(address payable);
    function StakePool() external view returns(address payable);
    function StakeToken() external view returns (address payable);
    function StakingToken(uint _pid) external view returns (address payable);
    // function syncCrossChain(uint _poolId) external;
    // function Crosschain_Shift_Stake(address wallet, uint crosschain, bool up, uint _poolId) external;
    function Process_Rewards(uint _poolId) external;
    // function Sync_CrossChain_byWallet(address payable _wallet,uint _poolId) external returns(bool);
    // function getStack_Stacked_CrossChain_BalanceOf_byId(uint stackID, uint _poolId) external view returns(uint crosschain);
    // function getStack_CrossChain_BalanceOf_byWallet(address usersWallet, uint _poolId) external view returns(uint crosschain);
    // function getStack_BalanceOf_byWallet(address usersWallet, uint _poolId) external view returns(uint crosschain);
    // function getStack_Stacked_BalanceOf_byId(uint stackID, uint _poolId) external view returns(uint stacked);
    function RewardsToken(uint _pid) external view returns(address payable);
    function RewardsPool(uint _pid) external view returns (address payable);
    // function CrossChain_BulkShift(address payable[] memory stacks, uint[] memory distributions, bool up, uint _poolId) external;
    // function Crosschain_Shift(address wallet, uint crosschain, bool up, uint _poolId) external;
    function Testnet() external view  returns (bool);
    // function CrossChain() external view  returns (bool);
    function estimates(uint amount,uint duration, uint _poolId) external view returns(uint);
    // function canUserClaim(address usersWallet, uint _poolId) external returns(bool);
    // function fundRewardsPool(uint256 tokenAmount, address payable token, address source, uint _poolId) external;
    function newManager(address payable _manager, uint _poolId) external;
    function stakePoolETHBalance() external view returns(uint);
    function stakePoolBalance(uint _poolId) external view returns(uint);    
    function setStakingToken(address payable token, uint _poolId) external returns(bool,bool,bool,bool);
    function setRewardsToken(address payable token, uint _poolId) external returns(bool,bool,bool,bool);
    // function stakePoolNetworkBalance(uint _poolId) external view returns(uint);
    function estimateUserStakes(uint amount, uint _poolId) external view returns(uint,uint,uint,uint,uint,uint);
    function rewardsPoolETHBalance(uint _poolId) external view returns(uint);
    function rewardsPoolBalance(uint _poolId) external view returns(uint);
    function FaucetToken() external view returns (address payable);
    function Faucet() external view returns (address payable);
}
