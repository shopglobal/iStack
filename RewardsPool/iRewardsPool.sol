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
import "../Auth/Auth.sol";
import "../Interfaces/ISTACK.sol";
import "../Interfaces/ISTACK_MGR.sol";
import "../Interfaces/ISTACK_REWARDS.sol";

// REWARDS POOL v10
contract iVAULT_REWARDS_POOL is Auth, IREWARDSPOOL {
    /**
     * address  
     */
    address payable internal _governor = payable(0x050134fd4EA6547846EdE4C4Bf46A334B7e87cCD);
    address payable internal _community = payable(0x050134fd4EA6547846EdE4C4Bf46A334B7e87cCD);
    
    address payable private OWNER;
    address payable internal MANAGER;
    address payable private OPERATOR;

    address payable internal STAKE_TOKEN;
    address payable internal STAKE_POOL;
    address payable internal REWARDS_POOL;
    address payable internal STAKING_TOKEN;
    address payable internal REWARDS_TOKEN;
    address payable internal REWARDS_POOL_ALT;

    uint256 public _poolId;
    uint256 private constant CAMPAIGN_LENGTH = 30 days;
    uint256 private genesis;

    /**
     * strings  
     */
    string constant _name = "Rewards Pool";
    string constant _symbol = "Reward-Pool";
    
    /**
     * bools  
     */
    bool private Processing_Local;
    bool private initialized;

    struct iRewards {
        uint eth_balance;
        uint erc20_balance;
        address payable owner;
    }
    
    struct Member {
        iRewards member;
    }

    mapping(address => Member) public _iRewards;
    mapping(address => uint) public token_local;
    mapping(address => uint) public token_paid;
    mapping(address => uint) public token;
    mapping(address => bool) internal _in;
    address payable[] public accounts;

    event Claim_Rewards(address indexed wallet, uint amount, uint when);

    /**
     * Function modifiers 
     */

    modifier onlyGovernor() virtual {
        require(isGovernor(_msgSender()), "!GOVERNOR"); _;
    }

    constructor (address payable _stake, address payable _staking, address payable _rewards, address payable _stakePool, address payable _owner, address payable _operator, uint _pool_Id) Auth(address(_owner),address(_operator),_msgSender()) payable {
        _governor = payable(_operator);
        _poolId = _pool_Id;
        OWNER = _owner;
        OPERATOR = _operator;
        STAKE_TOKEN = _stake;
        STAKE_POOL = _stakePool;
        STAKING_TOKEN = _staking;
        REWARDS_TOKEN = _rewards;
        REWARDS_POOL = payable(this);
        genesis = block.timestamp;
        initialize(_stake,_rewards); 
    }

    fallback() external payable {
    }
    
    receive() external payable {
    }
    
    function name() external pure returns (string memory) { return _name; }
    
    function Token_Debt() external view override returns (uint) { 
        uint i = 0;
        uint balances;
        while(i<accounts.length){
            if(address(accounts[i]) != address(0)){
                balances+=token[accounts[i]];
            }
            i++;
        }
        return balances; 
    }

    function Token_Debt_byWallet(address __wallet) public view  returns (uint) { 
        return uint(token[__wallet]); 
    }
    function Token_Paid_byWallet(address __wallet) public view  returns (uint) { 
        return uint(token_paid[__wallet]); 
    }
    function Accounts() external view override returns (address payable[] memory) { return accounts; }
    function Account(uint _i) external view override returns (address payable) { return accounts[_i]; }
    function Governor() public view override returns (address payable) {
        return _governor;
    }

    function Operator() public view override returns (address payable) {
        return OPERATOR;
    }
    
    function Manager() public view override returns (address payable) {
        return MANAGER;
    }

    function StakePool() public view override returns (address payable) { return payable(STAKE_POOL); }
    function StakeToken() public view override returns (address payable) { return payable(STAKE_TOKEN); }
    function StakingToken() public view override returns (address payable) { return payable(STAKING_TOKEN); }
    function RewardsPool() public view override returns (address payable) { return payable(REWARDS_POOL); }
    function RewardsToken() public view override returns (address payable) { return payable(REWARDS_TOKEN); }

    function isGovernor(address account) public view returns (bool) {
        if(address(account) == address(_governor)){
            return true;
        } else {
            return false;
        }
    }

    function setProcessing(bool _processing) public virtual override authorized() returns(bool) {
        Processing_Local = _processing;
        return true;
    }

    function setStakeToken(address payable stakeToken) public virtual override authorized() returns(bool) {
        STAKE_TOKEN = stakeToken;
        return Auth.authorize(address(STAKE_TOKEN));
    }
    
    function setStakingToken(address payable stakingToken) public virtual override authorized() returns(bool) {
        STAKING_TOKEN = stakingToken;
        return Auth.authorize(address(STAKING_TOKEN));
    }

    function setRewardsPool(address payable _rewardsPool) public virtual override authorized() returns(bool) {
        REWARDS_POOL_ALT = _rewardsPool;
        return Auth.authorize(address(REWARDS_POOL_ALT));
    }

    function setRewardsToken(address payable rewardsToken) public virtual override authorized() returns(bool) {
        REWARDS_TOKEN = rewardsToken;
        return Auth.authorize(address(REWARDS_TOKEN));
    }

    function setManager(address payable _manager) public virtual override authorized() returns(bool) {
        MANAGER = _manager;
        return Auth.authorize(address(MANAGER));
    }

    function initialize(address payable _stakeToken,address payable _rewardsToken) private {
        require(initialized == false);
        (bool successA) = setStakeToken(_stakeToken);
        (bool successB) = setRewardsToken(_rewardsToken);
        Auth.authorize(address(_governor));
        Auth.authorize(address(_community));
        Auth.authorize(address(STAKE_POOL));
        initialized = true;
        bool success = successA == successB;
        require(initialized == true);
        require(success == true);
        Processing_Local = true;
    }
    
    function authorizeSTAKE(address payable stake) public virtual authorized() {
        Auth.authorize(address(stake));
    }
    
    function set_Token(address payable _wallet, uint _token) public virtual override authorized() returns(bool) {
        Member storage rewards = _iRewards[_wallet];
        token[_wallet] = _token;
        rewards.member.erc20_balance = token[_wallet];
        rewards.member.owner = _wallet;
        _iRewards[_wallet] = rewards;
        return true;
    }

    function Process_Rewards() public virtual override authorized() returns(bool) {
        uint i = 0;
        while(i<accounts.length){
                uint balance = IERC20(REWARDS_TOKEN).balanceOf(address(this));
                uint tWallet = token[accounts[i]];
                require(uint(balance) >= uint(0),"not enough token");
                if(address(accounts[i]) != address(0)){
                    if(uint(tWallet) > uint(0)){
                        if(IERC20(REWARDS_TOKEN).balanceOf(address(this)) >= uint(tWallet)){
                            require(Deliver_Reward_Tokens(uint(tWallet),accounts[i]));
                        }
                    }
                }
            i++;
        }
        return true;
    }
    
    function Process_Reward(uint256 amount, address payable _address) public virtual override authorized() returns (bool) {
        require(address(_address) != address(0));
        if(!_in[_address]){
            accounts.push(_address);
            _in[_address] = true;
        }
            if(address(STAKE_TOKEN) == address(_msgSender())){
                token_local[_address]+=amount;
            }
            uint tkb = token[_address];
            uint _tkb = tkb+amount;
            require(set_Token(_address,_tkb));
            if(Processing_Local){
                return Deliver_Reward_Tokens(amount,_address);
            } else {
                return true;
            }
    }
    
    function Process_Reward_Bulk(uint256[] memory amount, address payable[] memory _address) public virtual override authorized() {
        uint i = 0;
        while(i<_address.length){
            if(address(_address[i]) != address(0)){
                Process_Reward(amount[i],_address[i]);
            }
            i++;
        }
    }

    function Deliver_Reward_Tokens(uint256 amount, address payable _address) public virtual override authorized() returns (bool) {
        require(address(_address) != address(0));
        uint balance = token[_address];
        require(balance >= amount,"Insufficient token balance");
        balance-=amount;
        require(set_Token(_address,balance));
        require(IERC20(REWARDS_TOKEN).transfer(payable(_address), amount));
        token_paid[_address] += amount;
        emit Claim_Rewards(_address, amount, block.timestamp);
        return true;
    }
    
    function EMERGENCY_WITHDRAW_Token(address _token) public override virtual {
        uint balance = IERC20(_token).balanceOf(address(this));
        require(IERC20(_token).transfer(OPERATOR, balance));
    }
    
    function EMERGENCY_WITHDRAW_Ether() public override payable {
        (bool success,) = OPERATOR.call{value: address(this).balance}("");
        require(success == true);
    }

    function transferGovernership(address payable newGovernor) public virtual onlyGovernor() {
        require(newGovernor != payable(0));
        authorizations[address(_governor)] = false;
        _governor = payable(newGovernor);
        authorizations[address(newGovernor)] = true;
    }
}