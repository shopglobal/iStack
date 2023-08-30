//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ISTAKE {
    struct iStack {
        uint256 stacks;
        uint256 totalEtherFees;
        uint256 totalTokenFees;
        uint256 totalTokenBurn;
        uint256 totalTokenStaked;
        uint256 totalTokenRewards;
        uint256 totalCoinRewards;
        address payable ____iVault;
    }

    struct Stack {
        address payable owner;
        uint256 lastStakeTime;
        uint256 totalStaked;
        uint256 totalClaimed;
        uint256 lastClaimed;
        uint256 crosschain;
        bool expired;
        uint256 id;
    }

    struct User {
        Stack stack;
    }

    function Governor() external view returns (address payable);

    function Operator() external view returns (address payable);

    // function Manager() external view returns (address payable);

    function StakePool() external view returns (address payable);

    function StakeToken() external view returns (address payable);

    function StakingToken(uint256 _poolId)
        external
        view
        returns (address payable);

    function RewardsToken(uint256 _poolId)
        external
        view
        returns (address payable);

    function RewardsPool(uint256 _poolId)
        external
        view
        returns (address payable);

    function Supply_Cap(uint256 _poolId)
        external
        view
        returns (uint256);

    function TotalETHFees(uint256 _poolId) external view returns (uint256);

    function TotalTokenFees(uint256 _poolId) external view returns (uint256);

    function TotalTokenBurn(uint256 _poolId) external view returns (uint256);

    function TotalTokenStaked(uint256 _poolId) external view returns (uint256);

    function TotalTokenRewards(uint256 _poolId) external view returns (uint256);

    function Pool_TTC(uint256 _poolId) external view returns (uint256);

    function Rebate_Rate(uint256 _poolId) external view returns (uint256);

    // function Members_Harvest_Rewards(uint256 _poolId) external;

    function getStack_byId(uint256 stackID, uint256 _poolId)
        external
        view
        returns (ISTAKE.Stack memory);

    function getStack_byWallet(address usersWallet, uint256 _poolId)
        external
        view
        returns (ISTAKE.User memory);

    function setRewardsPool(address payable _rewardsPool, uint256 _poolId)
        external
        returns (bool);
    
    // function CrossChain_Swap(address payable _token, uint256 _amount, address payable _receiver, bool _eth_gas)
    //     external
    //     payable
    //     returns (bool);

    function Rewards(uint256 _poolId) external view returns (uint256);
    // function Pools() external view returns (uint256);
    function Get_iStack(uint256 _poolId) external view returns (iStack memory);
    
    function transfer_FromPool(
        address payable sender,
        address payable recipient,
        uint256 _poolId,
        uint256 amount
    )
        external
        returns (
            bool
        );

    function claimRewardsToken(uint256 _poolId)
        external
        payable
        returns (bool);

    function unStakeToken(uint256 amountToken, uint256 _poolId)
        external
        payable
        returns (bool);

    function stakeToken(uint256 tokenAmount, uint256 _poolId)
        external
        payable
        returns (bool);

    function checkUserStakes(address usersWallet, uint256 _poolId)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            bool
        );

    function setStakingToken(address payable token, uint256 _poolId)
        external
        returns (bool);

    function setRewardsToken(address payable token, uint256 _poolId)
        external
        returns (bool);

    // function setManager(address payable _manager, uint256 _poolId)
    //     external
    //     returns (bool);

    function setRewardAmount(uint256 rewardAmount, uint256 _poolId) external;

    function EMERGENCY_WITHDRAW_Ether() external payable;

    function EMERGENCY_WITHDRAW_Token(address token) external;
}
