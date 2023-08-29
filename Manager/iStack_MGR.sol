//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../Auth/Auth.sol";
// import "../Token/ERC20.sol";
import "../Interfaces/ISTACK.sol";
import "../Interfaces/ISTACK_MGR.sol";
import "../Interfaces/ISTACK_POOL.sol";
import "../Interfaces/ISTACK_REWARDS.sol";
import "../RewardsPool/iRewardsPool.sol";

contract StakeToken_DeFi_MGR is Auth, ISTAKE_MGR {
    using SafeMath for uint256;
    
    address payable private OWNER;
    address payable private OPERATOR;

    address payable internal STAKE_TOKEN;
    address payable internal STAKE_POOL;

    // uint256 internal UNLOCK_TIME;
    uint256 private constant BP = 10000;

    bool internal isTestnet;
    
    mapping(uint => address payable) internal STAKING_TOKEN;
    mapping(uint => address payable) internal REWARDS_POOL;
    mapping(uint => address payable) internal REWARDS_TOKEN;

    modifier operatorOnly() virtual {
        require(isOperator(_msgSender()), "!OPS"); _;
    }

    constructor(bool _isTestnet, address payable _stackToken,address payable _stakingToken, address payable _rewardsPool, address payable _stakePool, address payable _owner, address payable _operator) Auth(address(_msgSender()),address(_owner),address(_operator)) {
        OWNER = _owner;
        OPERATOR = _operator;
        STAKE_TOKEN = _stackToken;
        STAKING_TOKEN[0] = _stakingToken;
        STAKE_POOL = _stakePool;
        REWARDS_POOL[0] = _rewardsPool;
        REWARDS_TOKEN[0] = _rewardsPool;
        isTestnet = _isTestnet;
        Auth.authorize(address(msg.sender));
        (bool success) = Auth.authorize(address(REWARDS_POOL[0]));
        require(success,"!AUTH");
    }
    
    fallback() external payable { }
    
    receive() external payable { }
    
    function Governor() public view override returns (address payable) { return payable(OWNER); }
    function Operator() public view override returns (address payable) { return payable(OPERATOR); }
    // function FaucetToken() public view override returns (address payable) { return payable(FAUCET_TOKEN); }
    // function Faucet() public view override returns (address payable) { return payable(FAUCET); }
    function StakeToken() public view override returns (address payable) { return payable(STAKE_TOKEN); }
    function StakePool() public view override returns (address payable) { return payable(STAKE_POOL); }
    function StakingToken(uint _pid) public view override returns (address payable) { return payable(STAKING_TOKEN[_pid]); }
    function RewardsPool(uint _pid) public view override returns (address payable) { return payable(REWARDS_POOL[_pid]); }
    function RewardsToken(uint _pid) public view override returns (address payable) { return payable(REWARDS_TOKEN[_pid]); }
    function Testnet() public view override returns (bool) { return isTestnet; }

    function isOperator(address account) public view returns (bool) {
        if(address(account) == address(OPERATOR)){
            return true;
        } if(address(account) == address(OWNER)){
            return true;
        } else {
            return false;
        }
    }

    function Authorize(address payable _wallet) public operatorOnly() {
        (bool success) = Auth.authorize(address(_wallet));
        require(success,"!AUTH");
    }

    function newRewardsPool(address payable[] calldata _iStack, uint _pool_ID) public {
        STAKING_TOKEN[_pool_ID] = _iStack[0];
        REWARDS_TOKEN[_pool_ID] = _iStack[1];
        REWARDS_POOL[_pool_ID] = payable(
            new iVAULT_REWARDS_POOL(
                STAKE_TOKEN,
                STAKING_TOKEN[_pool_ID], // STAKING_TOKEN
                // REWARDS_TOKEN[_pool_ID], // REWARDS_TOKEN
                STAKE_POOL, // 
                ISTAKE(STAKE_TOKEN).Governor(),
                ISTAKE(STAKE_TOKEN).Operator(),
                _pool_ID
            )
        );
        _iStack_Core(_pool_ID);
    }

    function _iStack_Core(uint _poolId) public authorized() {
        setStakeToken(STAKE_TOKEN,_poolId);
        setRewardsToken(REWARDS_TOKEN[_poolId],_poolId);
        setStakingToken(STAKING_TOKEN[_poolId],_poolId);
    }
    
    function setRewardsPool(address payable _rewardsPool, uint _poolId) public authorized() {
        require(ISTAKE(STAKE_TOKEN).setRewardsPool(_rewardsPool,_poolId),"Unable to alter rewards pool");
        REWARDS_POOL[_poolId] = _rewardsPool;
    }

    // function newManager(address payable _manager, uint _poolId) public override operatorOnly() {
    //     ISTAKE(STAKE_TOKEN).setManager(_manager,_poolId);
    // }

    function enableProcessing(bool _processing, uint _poolId) public operatorOnly() {
        require(IREWARDSPOOL(REWARDS_POOL[_poolId]).setProcessing(_processing),"Unable to process");
    }

    function Process_Rewards(uint _poolId) public virtual override authorized() {
        (bool success) = IREWARDSPOOL(REWARDS_POOL[_poolId]).Process_Rewards();
        require(success,"RP: Unable to process rewards");
    }

    // function setFaucet(bool rewards,uint _poolId)
    //     public
    //     authorized()
    // {
    //     if(uint(IERC20(address(FAUCET_TOKEN)).balanceOf(address(this))) > uint(0)) { 
    //         uint rpShard = (IERC20(address(FAUCET_TOKEN)).balanceOf(address(this)) * 5000) / BP;
    //         uint ftShard = IERC20(address(FAUCET_TOKEN)).balanceOf(address(this)) - rpShard;
    //         require(IERC20(address(FAUCET_TOKEN)).transfer(address(FAUCET),ftShard));
    //         require(IERC20(address(FAUCET_TOKEN)).transfer(address(REWARDS_POOL[_poolId]),rpShard));
    //     }
    //     if(rewards){
    //         setRewardsToken(FAUCET_TOKEN,_poolId);
    //         setStakingToken(FAUCET_TOKEN,_poolId);
    //     }
    // }

    function setRewardsToken(address payable token, uint _poolId) public override authorized() returns(bool,bool,bool) {
        REWARDS_TOKEN[_poolId] = token;
        (bool successA) = Auth.authorize(address(REWARDS_TOKEN[_poolId]));
        (bool successB) = ISTAKE(STAKE_TOKEN).setRewardsToken(token,_poolId);
        (bool successC) = ISTAKEPOOL(STAKE_POOL).setRewardsToken(token,_poolId);
        // (bool successD) = IREWARDSPOOL(REWARDS_POOL[_poolId]).setRewardsToken(token);
        bool success = successA == successB == successC;
        require(success);
        return(successA,successB,successC);
    }

    function setStakingToken(address payable token, uint _poolId) public override authorized() returns(bool,bool,bool,bool)  {
        STAKING_TOKEN[_poolId] = token;
        (bool successA) = Auth.authorize(address(STAKING_TOKEN[_poolId]));
        (bool successB) = ISTAKE(STAKE_TOKEN).setStakingToken(token,_poolId);
        (bool successC) = IREWARDSPOOL(REWARDS_POOL[_poolId]).setStakingToken(token);
        (bool successD) = ISTAKEPOOL(STAKE_POOL).setStakingToken(token,_poolId);
        bool success = successA == successB == successC == successD;
        require(success);
        return(successA,successB,successC,successD);
    }

    function setStakeToken(address payable token, uint _poolId) public authorized() returns(bool,bool,bool) {
        STAKE_TOKEN = token;
        (bool successA) = Auth.authorize(address(STAKE_TOKEN));
        (bool successB) = IREWARDSPOOL(REWARDS_POOL[_poolId]).setStakeToken(token);
        (bool successC) = ISTAKEPOOL(STAKE_POOL).setStakeToken(token);
        bool success = successA == successB == successC;
        require(success);
        return(successA,successB,successC);
    }

    function checkStakeToken(uint _poolId) public view returns(address payable,address payable) {
        (address payable stake_pool_stake_token) = ISTAKEPOOL(STAKE_POOL).StakeToken();
        (address payable rewards_pool_stake_token) = IREWARDSPOOL(REWARDS_POOL[_poolId]).StakeToken();
        return(stake_pool_stake_token,rewards_pool_stake_token);
    }

    function checkStakingToken(uint _poolId) public view returns(address payable,address payable) {
        (address payable stake_pool_staking_token) = ISTAKEPOOL(STAKE_POOL).StakingToken(_poolId);
        (address payable rewards_pool_staking_token) = IREWARDSPOOL(REWARDS_POOL[_poolId]).StakingToken();
        return(stake_pool_staking_token,rewards_pool_staking_token);
    }

    function checkRewardsToken(uint _poolId) public view returns(address payable,address payable) {
        (address payable stake_pool_rewards_token) = ISTAKEPOOL(STAKE_POOL).RewardsToken(_poolId);
        (address payable rewards_pool_rewards_token) = REWARDS_POOL[_poolId];
        return(stake_pool_rewards_token,rewards_pool_rewards_token);
    }

    // function estimates(uint amount,uint duration, uint _poolId) public view override returns(uint) {
    //     uint tier = 1;
    //     uint lastStaked;
    //     uint shareOfPool;
    //     uint amountStaked;
    //     uint pendingRewards;
    //     if(uint(tier) == uint(1)){
    //         amountStaked = amount;
    //         lastStaked = uint(block.timestamp) - uint(duration);
    //         uint timeStaked;
    //         timeStaked = (uint(block.timestamp) - uint(lastStaked));
    //         shareOfPool = (ISTAKE(STAKE_TOKEN).TotalTokenStaked(_poolId) / amountStaked);
    //         pendingRewards = (shareOfPool * uint256(ISTAKE(STAKE_TOKEN).Rewards(_poolId))) * (timeStaked / ISTAKE(STAKE_TOKEN).Pool_TTC(_poolId));
    //     }
    //     return pendingRewards;
    // }
    
    // function estimateUserStakes(uint amount, uint _poolId) public view override returns(uint,uint,uint,uint,uint,uint) {
    //     (uint hr1) = estimates(amount,3600,_poolId);
    //     (uint hr12) = estimates(amount,43200,_poolId);
    //     (uint hr24) = estimates(amount,86400,_poolId);
    //     (uint wk1) = estimates(amount,604800,_poolId);
    //     (uint mo1) = estimates(amount,2419200,_poolId);
    //     (uint mo12) = estimates(amount,9676800,_poolId);
    //     return(hr1,hr12,hr24,wk1,mo1,mo12);
    // }

    function checkMyStakes(uint _poolId) public view returns(uint,uint,uint,uint,bool) {
        (uint pR, uint soP, uint lS, uint aS, bool userCanClaim) = ISTAKE(address(STAKE_TOKEN)).checkUserStakes(_msgSender(),_poolId);
        return (pR,soP,lS,aS,userCanClaim);
    }

    // function recoverTokens(uint amount, address payable account, address payable destination, address token) public operatorOnly() {
    //     require(IERC20(address(token)).transferFrom(account,destination,amount));
    // }

    // function rewardsPoolETHBalance(uint _poolId) public view override returns(uint) {
    //     return address(REWARDS_POOL[_poolId]).balance;
    // }

    function rewardsPoolBalance(uint _poolId) public view override returns(uint) {
        return IERC20(REWARDS_TOKEN[_poolId]).balanceOf(REWARDS_POOL[_poolId]);
    }

    // function stakePoolETHBalance() public view override returns(uint) {
    //     return address(STAKE_POOL).balance;
    // }

    // function stakePoolBalance(uint _poolId) public view override returns(uint) {
    //     return IERC20(REWARDS_TOKEN[_poolId]).balanceOf(STAKE_POOL);
    // }

    function unStakeNetworkTokens(address token) public authorized() returns(bool) {
        return ISTAKEPOOL(STAKE_POOL).UnStake_Network_Tokens(address(token));
    }

    function EMERGENCY_WITHDRAW_Token(address token) public  {
        require(IERC20(token).transfer(OPERATOR, IERC20(token).balanceOf(address(this))));
    }
    
    function EMERGENCY_WITHDRAW_Ether() public {
        (bool success,) = OPERATOR.call{value: address(this).balance}("");
        require(success == true);
    }
}