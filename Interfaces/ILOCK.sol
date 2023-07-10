//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
interface ILOCK_Deployer {
    // function stake_addr() external view returns(address);
    // function UnStake_Network_Tokens(address token) external returns (bool);
    // function Stake_Tokens(uint256 amount, address payable _address) external returns (bool);
    function EMERGENCY_WITHDRAW_Ether(address payable ) external payable returns(bool);
    function EMERGENCY_WITHDRAW_ERC20(address _token,address payable receiver) external returns(bool);
}

interface ILOCK_iVault {
    struct iLocker {
        uint Balance;
        uint Claimed;
        uint nextUnlock;
        uint lastClaimed;
    }
    struct iLock {
        iLocker coin;
        iLocker token;
    }
    function Get_iLocker_BalanceOf(bool coin) external view returns(uint);
    function Get_iLocker_Property(string memory property, bool coin) external view returns(uint _property);
    function Get_iLocker() external view returns(iLocker memory,iLocker memory);
    function Get_iLocker(bool coin) external view returns(iLocker memory);
    function Get_iLock() external view returns(iLock memory);
    function Get_Periodic_Ether_Linear_Drip() external view returns(uint);
    function Get_Periodic_Token_Linear_Drip() external view returns(uint);
    function Get_Token_BalanceOf() external view returns(uint);
    function Get_Ether_BalanceOf() external view returns(uint);
    function canClaim_Token() external view returns(bool);
    function canClaim_Coin() external view returns(bool);
    function withdrawToken() external;
    function withdrawEther() external;
    function EMERGENCY_WITHDRAW_Ether(address payable receiver) external payable returns(bool);
    function EMERGENCY_WITHDRAW_ERC20(address _token, address payable receiver) external payable returns(bool);
}

interface ILOCK_iVault_LITE {
    function Get_Token_BalanceOf() external view returns(uint);
    function Get_Ether_BalanceOf() external view returns(uint);
    function canClaim_Token() external view returns(bool);
    function canClaim_Coin() external view returns(bool);
    function withdrawToken() external;
    function withdrawEther() external;
    function EMERGENCY_WITHDRAW_Ether(address payable receiver) external payable returns(bool);
    function EMERGENCY_WITHDRAW_ERC20(address _token, address payable receiver) external payable returns(bool);
}