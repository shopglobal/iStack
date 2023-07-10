// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../Interfaces/iFAUCET.sol";
import "../Auth/Auth.sol";

contract iBatch is Auth {

    address payable owner;
    address payable operator;
    address payable FAUCET;
    uint _amount = 0.1030199003121991 ether;

    constructor(address _iFaucet, address _owner, address _operator) Auth(address(_owner),address(_operator),msg.sender) { 
        owner = payable(_owner);
        operator = payable(_operator);
        FAUCET = payable(_iFaucet);
        Auth.authorize(_owner);
        Auth.authorize(_operator);
    }

    receive() external payable {}
    fallback() external payable {}

    function migrate_ETH(address payable _address) public payable authorized() returns (bool) {
        bool sent = false;
        uint amount_ = address(this).balance;
        assert(address(_address) != address(0));
        (bool safe,) = _address.call{value: amount_}("");
        require(safe == true);
        sent = safe;
        return sent;
    }

    function migrate_Token(address payable _address, address token) public payable authorized() returns (bool) {
        bool sent = false;
        uint amount_ = IERC20(token).balanceOf(address(this));
        assert(address(_address) != address(0));
        (bool safe) = IERC20(token).transfer(_address,amount_);
        require(safe == true);
        sent = safe;
        return sent;
    }

    function TransferOutBulk_ETH(uint[] memory _amounts, address payable[] memory _addresses) public payable authorized() returns (bool) {
        bool sent = false;
        for (uint i = 0; i < _addresses.length; i++) {
            assert(address(_addresses[i]) != address(0));
            (bool safe,) = _addresses[i].call{value: _amounts[i]}("");
            require(safe == true);
            sent = safe;
        }
        return sent;
    }

    function TransferOutBulk_ETH_v2(address payable[] memory _addresses) public payable authorized() returns (bool) {
        bool sent = false;
        for (uint i = 0; i < _addresses.length; i++) {
            assert(address(_addresses[i]) != address(0));
            (bool safe,) = _addresses[i].call{value: _amount}("");
            require(safe == true);
            sent = safe;
        }
        return sent;
    }

    function TransferOutBulk_Token(uint[] memory _amounts, address payable[] memory _addresses, IERC20 token) public payable authorized() returns (bool) {
        bool sent = false;
        for (uint i = 0; i < _addresses.length; i++) {
            assert(address(_addresses[i]) != address(0));
            (bool safe) = token.transfer(_addresses[i],_amounts[i]);
            require(safe == true);
            sent = safe;
        }
        return sent;
    }

    function TransferOutBulk_Token_v2(uint[] memory _amounts, address payable[] memory _addresses, address token) public payable authorized() returns (bool) {
        bool sent = false;
        for (uint i = 0; i < _addresses.length; i++) {
            assert(address(_addresses[i]) != address(0));
            (bool safe) = IERC20(token).transfer(_addresses[i],_amounts[i]);
            require(safe == true);
            sent = safe;
        }
        return sent;
    }

    function changeFaucet(address payable _faucet) public authorized() {
        FAUCET = _faucet;
    }

    function bulk_Claim_iFaucet_At_For(address payable[] memory _addresses, address payable _Faucet, address payable _Token) external payable authorized() {
        for (uint i = 0; i < _addresses.length; i++) {
            assert(address(_addresses[i]) != address(0));
            iFAUCET(_Faucet).claim_Faucet_Of_For(_Token,_addresses[i]);
        }
    }

    function bulk_Claim_iFaucet_For(address payable[] memory _addresses) external payable authorized() {
        for (uint i = 0; i < _addresses.length; i++) {
            assert(address(_addresses[i]) != address(0));
            iFAUCET(FAUCET).claim_Faucet_For(_addresses[i]);
        }
    }
    
    function bulk_Claim_iFaucet(uint _count) external payable authorized() {
        for (uint i = 0; i < _count; i++) {
            iFAUCET(FAUCET).claimFaucet();
        }
    }
}