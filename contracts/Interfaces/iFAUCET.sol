// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface iFAUCET {
    function claim_Faucet_Of_For(address payable, address payable) external;
    function claimFaucet() external;
    function claim_Faucet_For(address payable _claimant) external returns(bool) ;
}

