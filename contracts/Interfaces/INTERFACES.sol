//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
interface ISTAKEPOOL {
    function stake_addr() external view returns(address);
    function StakeToken() external view returns (address payable);
    function StakingToken() external view returns (address payable);
    function RewardsToken() external view returns(address payable);
    function setStakeToken(address payable token) external returns(bool); 
    function setStakingToken(address payable stakingToken) external returns(bool);
    function setRewardsToken(address payable rewardsToken) external returns(bool);
    function balance(address wallet, address token) external view returns (uint);
    function UnStake_Tokens(uint256 amount, address payable _address) external returns (bool);
    function UnStake_Network_Tokens(address token) external returns (bool);
    function setManager(address payable _manager) external returns(bool);
    function Stake_Tokens(uint256 amount, address payable _address) external returns (bool);
    function EMERGENCY_WITHDRAW_Ether(uint _amount, address payable _address) external payable returns(bool);
    function EMERGENCY_WITHDRAW_Token(uint256 amount, address payable receiver, address token) external returns(bool);
}

interface IREWARDSPOOL {
    function stake_addr() external view returns(address);
    function StakeToken() external view returns (address payable);
    function StakingToken() external view returns (address payable);
    function RewardsToken() external view returns(address payable);
    function setStakeToken(address payable stakeToken) external returns(bool);
    function setStakingToken(address payable stakingToken) external returns(bool);
    function setRewardsToken(address payable rewardsToken) external returns(bool);
    function setManager(address payable _manager) external returns(bool);
    function Deliver_Reward_Tokens(uint256 amount, address payable _address) external returns (bool);
    function EMERGENCY_WITHDRAW_Ether(uint _amount, address payable _address) external payable returns(bool);
    function EMERGENCY_WITHDRAW_Token(uint256 amount, address payable receiver, address token) external returns(bool);
}

interface ISTAKE {
    
    struct iStack {
        address payable owner;
        uint256 genesis;    
        uint256 stacks; 
        uint256 BP;
        uint256 totalEtherFees; 
        uint256 totalTokenFees; 
        uint256 totalTokenBurn; 
        uint256 totalTokenStaked; 
        uint256 totalTokenRewards;
        uint256 totalCoinRewards; 
        uint256 totalTier1TokenStaked; 
    }

    struct Stack {
        address payable owner;
        uint256 lastStakeTime;    
        uint256 totalStaked; 
        uint256 totalClaimed;
        uint256 lastClaimed; 
        bool expired;
        uint id;
    }
    
    struct User {
        Stack stack;
    }
    function Governor() external view returns(address payable);
    function Operator() external view returns(address payable);
    function StakePool() external view returns(address payable);
    function StakeToken() external view returns (address payable);
    function StakingToken() external view returns (address payable);
    function RewardsToken() external view returns(address payable);
    function RewardsPool() external view returns (address payable);
    function TotalETHFees() external view returns (uint);
    function TotalTokenFees() external view returns (uint);
    function TotalTokenBurn() external view returns (uint);
    function TotalTokenStaked() external view returns (uint);
    function TotalTokenRewards() external view returns (uint);
    function TotalTier1TokenStaked() external view returns (uint);
    function Tier1_TTC() external view returns (uint);
    function getStack_byId(uint stackID) external view returns(ISTAKE.Stack memory);
    function getStack_byWallet(address usersWallet) external view returns(ISTAKE.User memory);
    // function checkUserStack_byId(uint stackId) public view returns(uint,uint,uint,uint,bool);
    // function stakePoolETHBalance() external view returns(uint);
    // function stakePoolBalance() external view returns(uint);    
    function Rewards() external view returns (uint);
    // function stakePoolNetworkBalance() external view returns(uint);
    // function checkStakeToken() external view returns(address payable,address payable);
    // function checkStakingToken() external view returns(address payable,address payable);
    // function checkRewardsToken() external view returns(address payable,address payable);
    // function estimateUserStakes(uint amount) external view returns(uint,uint,uint,uint,uint,uint);
    function claimRewardsToken(uint tier) external payable returns(bool);
    function unStakeToken(uint256 amountToken,uint256 tier) external payable returns(bool);
    function stakeToken(uint256 tokenAmount) external payable returns(bool);
    function checkUserStakes(address usersWallet,uint tier) external view returns(uint,uint,uint,uint,bool);
    function checkMyStakes() external view returns(uint,uint,uint,uint,bool);
    function checkUserStack_byId(uint stackId) external view returns(uint,uint,uint,uint,bool);
    function calculateRewards(address usersWallet, uint tier) external view returns(uint);
    // function rewardsPoolETHBalance() external view returns(uint);
    // function rewardsPoolBalance() external view returns(uint);
    // function rerouteTokenToRewardsPool(uint256 tokenAmount, address payable token) external;
    function fundRewardsPool(uint256 tokenAmount, address payable token) external;
    function setStakingToken(address payable token) external returns(bool);
    function setRewardsToken(address payable token) external returns(bool);
    function setStakeToken(address payable token) external returns(bool);
    function setRewardAmount(uint256 rewardAmount, uint256 class) external;
    // function getContractETHBalance() external view returns (uint256);
    // function getContractTokenBalance() external view returns (uint256);
    // function getUserTokenBalance(address _token, address _addr) external view returns (uint256);
    function EMERGENCY_WITHDRAW_Ether(uint _amount, address payable _address) external payable returns(bool);
    function EMERGENCY_WITHDRAW_Token(uint256 amount, address payable _address, address token) external returns (bool);
}

interface ISTAKE_MGR {

    function Governor() external view returns(address payable);
    function Operator() external view returns(address payable);
    function StakePool() external view returns(address payable);
    function StakeToken() external view returns (address payable);
    function StakingToken() external view returns (address payable);
    function RewardsToken() external view returns(address payable);
    function RewardsPool() external view returns (address payable);
    function estimates(uint amount,uint duration) external view returns(uint);
    function canUserClaim(address usersWallet, uint tier) external returns(bool);
    // function TotalETHFees() external view returns (uint);
    // function TotalTokenFees() external view returns (uint);
    // function TotalTokenBurn() external view returns (uint);
    // function TotalTokenStaked() external view returns (uint);
    // function TotalTokenRewards() external view returns (uint);
    // function TotalTier1TokenStaked() external view returns (uint);
    function stakePoolETHBalance() external view returns(uint);
    function stakePoolBalance() external view returns(uint);    
    // function Rewards() external view returns (uint);
    function stakePoolNetworkBalance() external view returns(uint);
    function estimateUserStakes(uint amount) external view returns(uint,uint,uint,uint,uint,uint);
    // function setStakingToken(address payable token) external returns(bool,bool,bool);
    // function checkStakeToken() external view returns(address payable,address payable);
    // function checkStakingToken() external view returns(address payable,address payable);
    // function checkRewardsToken() external view returns(address payable,address payable);
    // function estimateUserStakes(uint amount) external view returns(uint,uint,uint,uint,uint,uint);
    // function claimRewardsToken(uint tier) external payable returns(bool);
    // function unStakeToken(uint256 amountToken,uint256 tier) external payable returns(bool);
    // function stakeToken(uint256 tokenAmount) external payable returns(bool);
    // function checkUserStakes(address usersWallet,uint tier) external view returns(uint,uint,uint,uint,bool);
    // function checkMyStakes() external view returns(uint,uint,uint,uint,bool);
    // function calculateRewards(address usersWallet, uint tier) external view returns(uint);
    // function canUserClaim(address usersWallet, uint tier) external returns(bool);
    function rewardsPoolETHBalance() external view returns(uint);
    function rewardsPoolBalance() external view returns(uint);
    // // function rerouteTokenToRewardsPool(uint256 tokenAmount, address payable token) external;
    // function fundRewardsPool(uint256 tokenAmount, address payable token) external;
    // function setRewardsToken(address payable token) external returns(bool,bool,bool);
    // function setStakeToken(address payable token) external returns(bool,bool,bool);
    // function setRewardAmount(uint256 rewardAmount, uint256 class) external;
    // function getContractETHBalance() external view returns (uint256);
    // function getContractTokenBalance() external view returns (uint256);
    // function getUserTokenBalance(address _token, address _addr) external view returns (uint256);
    // function EMERGENCY_WITHDRAW_Ether(uint _amount, address payable _address) external payable returns(bool);
    // function EMERGENCY_WITHDRAW_Token(uint256 amount, address payable _address, address token) external returns (bool);
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external payable returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
}

abstract contract _MSG {

    address payable public DEPLOYER;

    constructor(){
        DEPLOYER = payable(_msgSender());
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }

    function Deployer() public view returns(address payable) { return DEPLOYER; }
}