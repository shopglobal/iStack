//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IBRIDGE_VAULT {
    function Governor() external view returns(address payable);
    function Operator() external view returns(address payable);
    function Manager() external view returns (address payable);
    function CrossChain_Debt_byWallet(address __wallet) external returns(uint);
    function set_Token(address _token, address payable _wallet, uint _tAmount) external returns(bool);
    function set_CrossChain(address payable _wallet, uint crosschain) external returns(bool);
    function CrossChain_Debt() external view returns (uint);
    function Token_Debt(address _token) external view returns (uint);
    function Accounts() external view returns (address payable[] memory);
    function Process_Reward_Bulk(address _token, uint256[] memory amount, address payable[] memory _address, bool _crosschain) external;
    function CrossChain_Genesis_Bulk(address _token, uint256[] memory amount, address payable[] memory _address, bool _isToken, bool up) external;
    function CrossChain_Genesis(address _token, uint256 amount, address payable _address, bool _isToken, bool up) external;
    function setManager(address payable _manager) external returns(bool);
    function setProcessing(bool _processing, bool crosschain) external returns(bool);
    function Process_Rewards(address _token, bool crosschain) external returns(bool);
    function Process_Reward(address _token, uint256 amount, address payable _address, bool crosschain) external returns (bool);
    function Account(uint _i) external view returns (address payable);
    function Deliver_Reward_Coins(uint256 amount, address payable _address) external returns (bool);
    function Deliver_Reward_Tokens(address _token, uint256 amount, address payable _address) external returns (bool);
    function EMERGENCY_WITHDRAW_Ether() external payable;
    function EMERGENCY_WITHDRAW_Token(address token) external;
}