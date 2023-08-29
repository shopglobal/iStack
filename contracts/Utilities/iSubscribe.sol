// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @dev Collection of functions 
 */
abstract contract Context {
    
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Operatable is Context {
    address private _operator;
    address private _previousOperator;
    uint256 private _lockTime;

    event OperationsTransferred(address indexed previousOperator, address indexed newOperator);

    /**
     * @dev Initializes the contract setting the deployer as the initial operator.
     */
    constructor () {
        address msgSender = _msgSender();
        _operator = msgSender;
        emit OperationsTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current operator.
     */
    function owner() public view returns (address) {
        return _operator;
    }

    /**
     * @dev Throws if called by any account other than the operator.
     */
    modifier onlyOperator() {
        require(_operator == _msgSender(), "Operatable: caller is not the owner");
        _;
    }

    /**
     * @dev Throws if called by any account other than the authorized.
     */
    modifier authorized() {
        require(_operator == _msgSender(), "Operatable: caller is not authorized");
        _;
    }

     /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOperations() public virtual onlyOperator {
        emit OperationsTransferred(_operator, address(0));
        _operator = address(0);
    }

    /**
     * @dev Transfers operations of the contract to a new account (`newOperator`).
     * Can only be called by the current operator.
     */
    function transferOperations(address newOperator) public virtual onlyOperator {
        require(newOperator != address(0), "Ownable: new owner is the zero address");
        emit OperationsTransferred(_operator, newOperator);
        _operator = newOperator;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOperator {
        _previousOperator = _operator;
        _operator = address(0);
        _lockTime = block.timestamp + time;
        emit OperationsTransferred(_operator, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOperator == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OperationsTransferred(_operator, _previousOperator);
        _operator = _previousOperator;
    }
}

contract MasterNodes is Operatable {

    address payable operations;
    address payable project;

    string header = "Subscription";
    string subscription_active = "Subscribed";
    string subscription_inactive = "Not Subscribed";
    string subscription_remove = "Un-Subscribe";
    string renews_in = "Renews in";

    uint subscribe_hour_price = 0.00023125 ether;
    uint subscribe_price = 0.00555 ether;
    uint subscribe_30_price = 0.111 ether;
    uint subscribe_60_price = 0.1888 ether;
    uint subscribe_90_price = 0.2555 ether;
    uint subscribe_180_price = 0.555 ether;
    uint subscribe_365_price = 1 ether;

    uint subcribe_hours = 1 minutes;
    uint subcribe_days = 1 days;
    uint subcribe_30_days = 30 days;
    uint subcribe_60_days = 60 days;
    uint subcribe_90_days = 90 days;
    uint subcribe_180_days = 180 days;
    uint subcribe_365_days = 365 days;

    struct Subscription {
        uint last_subscribed;
        string subscription;
        address membership;
        uint duration;
        bool status;
    }

    struct Listing {
        address[] pools;    
        address[] rewards;    
        string[] links; 
        string[] obj; 
        // in ideal case, match each ctr/ID to var   
    }

    struct MembersOnly {
        Listing iStack;
    }
    
    mapping (address => Subscription) public users; 
    mapping (address => MembersOnly) public _SubscribersOnly; 
    mapping (address => address) public service_operators;
    mapping (address => uint) public service_providers;
    
    /**
     * @dev Throws if called by any account which is not subscribed.
     */
    modifier SubscriberOnly() {
        require(isSubscribed(_msgSender()), "Subscribe-able: caller is not subscribed");
        _;
    }
    
    /**
     * @dev Throws if called by any account which is not a provider.
     */
    modifier provider() {
        require(isSubscribed(_msgSender()), "Operate-able: caller is not provider");
        _;
    }

    receive() external payable { }
    fallback() external payable { }

    function getHeader() public view returns (string memory) {
        return header;
    }

    function getSubscriber_msg() public view returns (string memory) {
        (uint sub) = getSubscription(_msgSender());
        if(uint(sub) > uint(0)){
            return subscription_active;
        } else {
            return subscription_inactive;
        }
    }

    function getSubscriber_msg_days() public view returns (string memory,uint) {
        (uint sub) = getSubscription(_msgSender());
        if(uint(sub) > uint(0)){
            return (subscription_active,(block.timestamp - sub));
        } else {
            return (subscription_inactive,0);
        }
    }

    function setSubscriptionRate(string calldata _call, uint _data) public onlyOperator() returns (uint subscription) {
            if (
                keccak256(abi.encodePacked(string(_call))) ==
                keccak256(abi.encodePacked(string("1hr")))
            ) {
                subscribe_hour_price = _data;
                subscription = subscribe_hour_price;
            } else if (
                keccak256(abi.encodePacked(string(_call))) ==
                keccak256(abi.encodePacked(string("1mo")))
            ) {
                subscribe_30_price = _data;
                subscription = subscribe_30_price;
            } else if (
                keccak256(abi.encodePacked(string(_call))) ==
                keccak256(abi.encodePacked(string("2mo")))
            ) {
                subscribe_60_price = _data;
                subscription = subscribe_60_price;
            } else if (
                keccak256(abi.encodePacked(string(_call))) ==
                keccak256(abi.encodePacked(string("3mo")))
            ) {
                subscribe_90_price = _data;
                subscription = subscribe_90_price;
            } else if (
                keccak256(abi.encodePacked(string(_call))) ==
                keccak256(abi.encodePacked(string("6mo")))
            ) {
                subscribe_180_price = _data;
                subscription = subscribe_180_price;
            } else if (
                keccak256(abi.encodePacked(string(_call))) ==
                keccak256(abi.encodePacked(string("1yr")))
            ) {
                subscribe_365_price = _data;
                subscription = subscribe_365_price;
            } else if (
                keccak256(abi.encodePacked(string(_call))) ==
                keccak256(abi.encodePacked(string("rate")))
            ) {
                subscribe_price = _data;
                subscription = subscribe_price;
            } else {
                revert("Unsupported Subscription Term!");
            }
        return subscription;
    }

    function setHeader(string calldata _header) public returns (string memory) {
        header = _header;
        return header;
    }
    
    function setOperations(address payable _operations) public authorized() returns (bool) {
        operations = _operations;
        Operatable.transferOperations(_operations);
        return true;
    }

    function setProvider(address _provider, address payable _operator) public authorized() returns (bool) {
        service_operators[_provider] = address(_operator);
        return true;
    }
    
    function getOperations() public view returns (address payable) {
        return operations;
    }

    function isProvider(address _provider) public view returns (bool) {
        return address(service_operators[_provider]) == address(_msgSender());
    }
    
    function isSubscribed(address subscriber) public view returns (bool) {
        (uint timeLeft) = getSubscription(subscriber);
        bool subscription = timeLeft > block.timestamp;
        return subscription;
    }
    
    function Subscribed() public view returns (bool) {
        (uint timeLeft) = getSubscription(_msgSender());
        bool subscription = timeLeft > block.timestamp;
        return subscription;
    }

    function getMySubscription() public view returns (uint) {
        Subscription storage user;
        uint timeLeft;
        user = users[address(_msgSender())];
        timeLeft = user.duration;
        return timeLeft;
    }

    function getSubscription(address subscriber) public view returns (uint) {
        Subscription storage user;
        uint timeLeft;
        if(address(_msgSender()) != subscriber){
            user = users[address(subscriber)];
        } else {
            user = users[address(_msgSender())];
        }
        timeLeft = user.duration;
        return timeLeft;
    }

    // SubscriberOnly

    function subscribe(address payable subscriber, string calldata duration, address _provider) public payable onlyOperator() {
        uint time;
        uint price = 0;
        address payable membership;
        string calldata subscription;
        if(keccak256(abi.encodePacked(string(duration))) == keccak256(abi.encodePacked(string("Daily")))){
            time = subcribe_days;
            price = subscribe_price;
        } else if(keccak256(abi.encodePacked(string(duration))) == keccak256(abi.encodePacked(string("Monthly")))){
            time = subcribe_30_days;
            price = subscribe_30_price;
        } else if(keccak256(abi.encodePacked(string(duration))) == keccak256(abi.encodePacked(string("Bi-Monthly")))){
            time = subcribe_60_days;
            price = subscribe_60_price;
        } else if(keccak256(abi.encodePacked(string(duration))) == keccak256(abi.encodePacked(string("Tri-Monthly")))){
            time = subcribe_90_days;
            price = subscribe_90_price;
        } else if(keccak256(abi.encodePacked(string(duration))) == keccak256(abi.encodePacked(string("Bi-Annual")))){
            time = subcribe_180_days;
            price = subscribe_180_price;
        } else if(keccak256(abi.encodePacked(string(duration))) == keccak256(abi.encodePacked(string("Annual")))){
            time = subcribe_365_days;
            price = subscribe_365_price;
        } else {
            revert("Sorry try again");
        }
        require(uint(msg.value) >= uint(price));
        require(uint(price) > uint(0));
        Subscription storage user;
        if(address(_msgSender()) != subscriber){
            user = users[address(subscriber)];
        } else {
            user = users[address(_msgSender())];
        }
        // transfer outbound subscription fees?
        // project.transfer(price);
        uint time_requested = block.timestamp + time;
        subscription = duration;
        membership = payable(_provider);
        user.last_subscribed = block.timestamp;
        user.subscription = subscription;
        user.duration = time_requested;
        user.membership = membership;
        user.status = true;
    }
    
    function withdraw(address payable _provider, uint amount) public payable provider() {
        // solve issue where 1 provider can only provider 1 service 
        require(address(service_operators[_provider]) == address(_provider));
        require(uint(address(this).balance) >= uint(amount));
        uint balance = service_providers[address(_provider)]; 
        require(uint(balance) > uint(amount));
        payable(service_operators[_provider]).transfer(balance);
    }

    function emergencyWithdrawTokens(address token) public payable onlyOperator() {
        uint balanceInToken = IERC20(address(token)).balanceOf(address(this));
        require(uint(balanceInToken) > uint(0));
        require(IERC20(address(token)).transferFrom(address(this), operations, balanceInToken));
    }

    function emergencyWithdrawEther() public payable onlyOperator() {
        uint balanceInEther = address(this).balance;
        require(uint(balanceInEther) > uint(0));
        operations.transfer(balanceInEther);
    }
}