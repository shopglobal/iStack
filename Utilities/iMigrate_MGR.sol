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

import "./iStack_MGR_v2.sol";

contract iMigrate_MGR {

    address payable private OWNER;
    address payable private MANAGER;
    address payable private OPERATOR;
    address payable private STAKE_TOKEN;
    address payable private STAKING_TOKEN;
    address payable private STAKE_POOL;
    address payable private REWARDS_TOKEN;
    address payable private REWARDS_POOL;

    constructor(bool isV2, bool isTestnet, address payable _stackToken) {
        STAKE_TOKEN = _stackToken;
        OWNER = ISTAKE(STAKE_TOKEN).Governor();
        OPERATOR = ISTAKE(STAKE_TOKEN).Operator();
        STAKING_TOKEN = ISTAKE(STAKE_TOKEN).StakingToken();
        REWARDS_TOKEN = ISTAKE(STAKE_TOKEN).RewardsToken();
        STAKE_POOL = ISTAKE(STAKE_TOKEN).StakePool();
        REWARDS_POOL = ISTAKE(STAKE_TOKEN).RewardsPool();       
        MANAGER = payable(
            new StakeToken_DeFi_MGR_V2(
                isV2,
                isTestnet,
                STAKE_TOKEN,
                STAKING_TOKEN,
                REWARDS_TOKEN,
                REWARDS_POOL,
                STAKE_POOL,
                OWNER,
                OPERATOR
            )
        );
        // remember to manually set newManager at MANAGER_V1...
        // since address(this) would not be Authorized()...
        // ISTAKE_MGR(MANAGER).newManager(MANAGER);
    }

    // get existing Manager
    function ManagerV1() public view returns(address payable) {
        return ISTAKE(STAKE_TOKEN).Manager();
    }

    // get new Manager
    function Manager() public view returns(address payable) {
        return MANAGER;
    }
}