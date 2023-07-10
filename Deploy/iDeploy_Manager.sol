//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * ██╗███╗   ██╗████████╗███████╗██████╗  ██████╗██╗  ██╗ █████╗ ██╗███╗   ██╗███████╗██████╗ 
 * ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗██╔════╝██║  ██║██╔══██╗██║████╗  ██║██╔════╝██╔══██╗
 * ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝██║     ███████║███████║██║██╔██╗ ██║█████╗  ██║  ██║
 * ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗██║     ██╔══██║██╔══██║██║██║╚██╗██║██╔══╝  ██║  ██║
 * ██║██║ ╚████║   ██║   ███████╗██║  ██║╚██████╗██║  ██║██║  ██║██║██║ ╚████║███████╗██████╔╝
 * ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝╚═════╝ 
 */

import "../Manager/iStack_MGR.sol";
import "../Interfaces/IDEPLOY.sol";

contract iDeploy_MGR is iDEPLOY {

    address payable private OWNER;
    address payable private MANAGER;
    address payable private OPERATOR;
    address payable private STAKE_TOKEN;
    address payable private STAKING_TOKEN;
    address payable private STAKE_POOL;
    address payable private REWARDS_TOKEN;
    address payable private REWARDS_POOL;

    bool private initialized;
    bool private isTestnet;
    bool private isCrossChain;

    struct iDeployed {
        address payable owner;
        address payable operator;
        address payable manager;
        address payable rewardsToken;
        address payable stakeToken;
        address payable stakingToken;
        address payable rewardsPool;
        address payable stakePool;
        bool isTestnet;
        bool isCrossChain;
    }

    uint internal _poolID = 0;
    iDeployed[] public _iDeployed;

    constructor(bool _isTestnet,address payable _stackToken,address payable _stakingToken, address payable _rewardsToken, address payable _rewardsPool, address payable _stakePool, address payable _owner, address payable _operator) {
        isTestnet = _isTestnet;
        isCrossChain = false;
        OWNER = _owner;
        OPERATOR = _operator;
        STAKE_TOKEN = _stackToken;
        STAKING_TOKEN = _stakingToken;
        REWARDS_TOKEN = _rewardsToken;
        STAKE_POOL = _stakePool;
        REWARDS_POOL = _rewardsPool;
        MANAGER = payable(
            new StakeToken_DeFi_MGR(
                _isTestnet,
                STAKE_TOKEN,
                STAKING_TOKEN,
                REWARDS_TOKEN,
                REWARDS_POOL,
                STAKE_POOL,
                OWNER,
                OPERATOR
            )
        );
    }

    function Get_iStack() public virtual view returns (iDeployed[] memory) {
        iDeployed[] memory deployed = _iDeployed;
        return deployed;
    }

    function _iStack() public virtual {
        require(address(msg.sender) == address(OPERATOR) || address(msg.sender) == address(OWNER),"Operator Only");
        require(initialized == false,"Already initialized");
        
        address payable iStack_StakeToken = ISTAKE(STAKE_TOKEN).StakeToken();
        address payable iStack_StakingToken = ISTAKE(STAKE_TOKEN).StakingToken(_poolID);
        address payable iStack_RewardsToken = ISTAKE(STAKE_TOKEN).RewardsToken(_poolID);
        address payable iStack_RewardsPool = ISTAKE(STAKE_TOKEN).RewardsPool(_poolID);
        address payable iStack_StakePool = ISTAKE(STAKE_TOKEN).StakePool();
            
        STAKE_POOL = iStack_StakePool;
        REWARDS_POOL = iStack_RewardsPool;
        address payable iStack_Manager = ISTAKE(STAKE_TOKEN).Manager();
        MANAGER = iStack_Manager;
        iDeployed memory deployed = iDeployed({
            owner: OWNER,
            operator: OPERATOR,
            manager: iStack_Manager,
            stakeToken: iStack_StakeToken,
            stakingToken: iStack_StakingToken,
            rewardsToken: iStack_RewardsToken,
            rewardsPool: iStack_RewardsPool,
            stakePool: iStack_StakePool,
            isTestnet: isTestnet,
            isCrossChain: isCrossChain
        });
        _iDeployed.push(deployed);
        initialized = true;
    }

    function Testnet() public view override returns (bool) { return isTestnet; }
    function CrossChain() public view override returns (bool) { return isCrossChain; }
    
    function Manager_iStack() public view returns (address payable) {
        return ISTAKE(STAKE_TOKEN).Manager();
    }

    function Manager() public view returns (address payable) {
        return MANAGER;
    }

    function set_iStack() public virtual  {
        require(address(msg.sender) == address(OPERATOR) || address(msg.sender) == address(OWNER),"Operator Only");
        require(initialized == false,"Already initialized");
        ISTAKE_MGR(MANAGER).setRewardsToken(REWARDS_TOKEN,_poolID);
        ISTAKE_MGR(MANAGER).setStakingToken(STAKING_TOKEN,_poolID);
        _iStack();
    }
    
    function setManager() public virtual override {
        require(address(msg.sender) == address(OPERATOR) || address(msg.sender) == address(OWNER),"Operator Only");
        require(initialized == false,"Already initialized");
        ISTAKE(STAKE_TOKEN).setManager(MANAGER, _poolID);
    }
}