//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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