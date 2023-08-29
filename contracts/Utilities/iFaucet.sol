// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../Interfaces/IERC20.sol";
import "../Interfaces/iFAUCET.sol";

contract iFaucet is iFAUCET {

    IERC20 token;

    uint public genesis;
    uint public unlockTime; 
    uint public initial_tokens;

    uint public TOKEN_UNLOCK_PERIOD;
    
    address payable public deployer;
    address payable public owner;
    address payable lock_token;

    bool dual;
    bool initialized;

    struct iLocker {
        uint Balance;
        uint Claimed;
        uint nextUnlock;
        uint lastClaimed;
    }

    struct iLock {
        iLocker token;
    }

    mapping(address => iLock) public _iLock;

    event Claim_Faucet(address indexed wallet, uint amount, uint when);

    constructor(address payable _owner, IERC20 _lockToken, uint _unlockTime) payable {
        deployer = payable(msg.sender);
        owner = payable(_owner);
        lock_token = payable(address(_lockToken));
        token = _lockToken;
        unlockTime = _unlockTime * 1 minutes;
        genesis = block.timestamp;
        initialize();
    }

    function initialize() private {
        require(!initialized,"Already initialized");
        require(address(msg.sender) == address(owner) || address(msg.sender) == address(deployer) || address(msg.sender) == address(this),"You're not the owner");
        iLock storage iVault = _iLock[address(this)];
        uint nextUnlock = uint(unlockTime) + uint(block.timestamp);
        initial_tokens = Get_Token_BalanceOf(address(lock_token));
        iVault.token.Balance = initial_tokens;
        iVault.token.nextUnlock = nextUnlock;
        TOKEN_UNLOCK_PERIOD = unlockTime;
        initialized = true;
    }

    function Write_Storage(uint tokenClaimed, uint lastClaimed) private returns(bool) {
        iLock storage iVault = _iLock[address(this)];
        uint next_claim;
        iVault.token.Balance=Get_Token_BalanceOf(address(lock_token));
        iVault.token.Claimed+=tokenClaimed;
        iVault.token.lastClaimed = lastClaimed;
        next_claim = uint(iVault.token.lastClaimed) + uint(TOKEN_UNLOCK_PERIOD);
        iVault.token.nextUnlock = next_claim;
        return true;
    }

    function claimFaucet() public {
        (bool claimable) = canClaim_Token();
        require(claimable,"Token claimed during this period");
        uint timeNow = block.timestamp;
        (uint tokenBalance) = Get_Token_BalanceOf(address(lock_token));
        uint tokenAmount = (tokenBalance * 200) / 1000000000;
        require(token.transfer(payable(msg.sender),tokenAmount),"Transfer failed!");
        Write_Storage(tokenAmount, timeNow);
        emit Claim_Faucet(address(msg.sender), tokenAmount, block.timestamp);
    }

    function claim_Faucet_Of_For(address payable _Token, address payable _claimant) public override {
        (bool claimable) = canClaim_Token();
        require(claimable,"Token claimed during this period");
        (uint tokenBalance) = Get_Token_BalanceOf(address(_Token));
        uint tokenAmount = (tokenBalance * 200) / 1000000000;
        require(token.transfer(_claimant,tokenAmount),"Transfer failed!");
        emit Claim_Faucet(address(msg.sender), tokenAmount, block.timestamp);
    }

    function claim_Faucet_For(address payable _claimant) public returns(bool) {
        (bool claimable) = canClaim_Token();
        require(claimable,"Token claimed during this period");
        uint timeNow = block.timestamp;
        (uint tokenBalance) = Get_Token_BalanceOf(address(lock_token));
        uint tokenAmount = (tokenBalance * 200) / 1000000000;
        require(token.transfer(_claimant,tokenAmount),"Transfer failed!");
        Write_Storage(tokenAmount, timeNow);
        emit Claim_Faucet(address(msg.sender), tokenAmount, block.timestamp);
        return true;
    }

    function canClaim_Token() public view returns(bool) {
        iLock storage iVault = _iLock[address(this)];
        bool claimable = uint(block.timestamp) >= (uint(iVault.token.lastClaimed) + uint(TOKEN_UNLOCK_PERIOD));
        require(uint(block.timestamp) >= (uint(iVault.token.lastClaimed) + uint(TOKEN_UNLOCK_PERIOD)),"Wait a few moments, and try again.");
        if(claimable){
            require(claimable == true);
            return true;
        } else {
            return false;
        }
    }

    function Get_Ether_BalanceOf() public view returns(uint) {
        return address(this).balance;
    }

    function Get_Token_BalanceOf(address _token) public view returns(uint) {
        return IERC20(_token).balanceOf(address(this));
    }
    
    function EMERGENCY_WITHDRAW_Ether(address payable receiver) external payable returns(bool) {
        require(address(msg.sender) == address(owner) || address(msg.sender) == address(deployer) || address(msg.sender) == address(this),"You're not the owner");
        receiver.transfer(address(this).balance);
        return true;
    }

    function EMERGENCY_WITHDRAW_ERC20(address _token, address payable receiver) external returns(bool) {
        require(address(msg.sender) == address(owner) || address(msg.sender) == address(deployer) || address(msg.sender) == address(this),"You're not the owner");
        return IERC20(_token).transfer(receiver,IERC20(token).balanceOf(address(this)));
    }

}