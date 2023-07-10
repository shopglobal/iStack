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

import "../Interfaces/ISTACK.sol";
import "../Tests/iRewardsPool.sol";

contract iMigrate_Rewards {

    address payable private OWNER;
    address payable private MANAGER;
    address payable private OPERATOR;
    address payable private STAKE_TOKEN;
    address payable private STAKING_TOKEN;
    address payable private STAKE_POOL;
    address payable private REWARDS_TOKEN;
    address payable private REWARDS_POOL;

    constructor(address payable _stackToken) {
        STAKE_TOKEN = _stackToken;
        OWNER = ISTAKE(STAKE_TOKEN).Governor();
        OPERATOR = ISTAKE(STAKE_TOKEN).Operator();
        STAKING_TOKEN = ISTAKE(STAKE_TOKEN).StakingToken();
        REWARDS_TOKEN = ISTAKE(STAKE_TOKEN).RewardsToken();
        STAKE_POOL = ISTAKE(STAKE_TOKEN).StakePool();
        REWARDS_POOL = payable(
            new iVAULT_REWARDS_POOL_V2(
                STAKE_TOKEN,
                STAKING_TOKEN,
                REWARDS_TOKEN,
                STAKE_POOL,
                OWNER,
                OPERATOR
            )
        );
        // remember to manually set newRewards at MANAGER_V1...
        // since address(this) would not be Authorized()...
    }

    // get existing RewardsPool
    function RewardsPool_V1() public view returns(address payable) {
        return ISTAKE(STAKE_TOKEN).RewardsPool();
    }

    // get new RewardsPool
    function RewardsPool() public view returns(address payable) {
        return REWARDS_POOL;
    }

    function Migrate(address token) public {
        require(address(msg.sender) == address(OWNER) || address(msg.sender) == address(OPERATOR),"!AUTH");
        require(IREWARDSPOOL(REWARDS_POOL).changePools(token),"Failed to change pools");
    }
}