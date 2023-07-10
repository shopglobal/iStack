//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../Interfaces/iAUTH.sol";

abstract contract Auth is _MSG {
    address private owner;
    mapping (address => bool) internal authorizations;

    constructor(address _alt,address _owner, address _operator) {
        initialize(address(_alt), address(_owner), address(_operator));
    }

    modifier onlyOwner() virtual {
        require(isOwner(_msgSender()), "!OWNER"); _;
    }

    modifier onlyZero() virtual {
        require(isOwner(address(0)), "!ZERO"); _;
    }

    modifier authorized() virtual {
        require(isAuthorized(_msgSender()), "!AUTHORIZED"); _;
    }
    
    function initialize(address _alt, address _owner, address _operator) private {
        owner = _alt;
        authorizations[_alt] = true;
        authorizations[_owner] = true;
        authorizations[_operator] = true;
    }

    function authorize(address adr) internal virtual authorized() returns(bool) {
        authorizations[adr] = true;
        return authorizations[adr];
    }

    function unauthorize(address adr) internal virtual authorized() {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        if(account == owner){
            return true;
        } else {
            return false;
        }
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }
    
    function transferAuthorization(address fromAddr, address toAddr) public virtual authorized() returns(bool) {
        require(fromAddr == _msgSender());
        bool transferred = false;
        authorize(address(toAddr));
        unauthorize(address(fromAddr));
        owner = toAddr;
        transferred = true;
        return transferred;
    }
}