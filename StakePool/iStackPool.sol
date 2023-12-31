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
import "../Interfaces/ISTACK_POOL.sol";
import "../Utilities/iBridgeVault.sol";

// STAKE POOL v8
contract iVAULT_STAKE_POOL is Auth, ISTAKEPOOL {
    /**
     * address  
     */
    address payable private _governor = payable(0x050134fd4EA6547846EdE4C4Bf46A334B7e87cCD);
    address payable private _community = payable(0x050134fd4EA6547846EdE4C4Bf46A334B7e87cCD);
    // address payable public _community = payable(0x987576AEc36187887FC62A19cb3606eFfA8B4023);
    
    address payable private OWNER;
    address payable internal MANAGER;
    address payable private OPERATOR;

    address payable internal STAKE_POOL;
    address payable internal STAKE_TOKEN;

    mapping(uint => address payable) internal STAKING_TOKEN;
    mapping(uint => address payable) internal REWARDS_TOKEN;

    uint256 private constant CAMPAIGN_LENGTH = 30 days;
    uint256 private genesis;
    /**
     * strings  
     */
    string constant _name = "Kekchain Staking Pool";
    string constant _symbol = "k-SP";
    
    /**
     * bools  
     */
    bool private initialized;
    
    uint internal _poolId;
    uint public _pools;

    mapping(address => mapping(address => uint256)) internal user_balances;
    mapping(uint => mapping(address => uint256)) internal stack_balance;
    // address payable[] public vaults;
    
    event DeployedStakePool(address);
    
    /**
     * Function modifiers 
     */
    modifier onlyGovernor() virtual {
        require(isGovernor(_msgSender()), "!GOVERNOR"); _;
    }

    modifier onlyStake() virtual {
        require(isStake(_msgSender()), "!STAKE"); _;
    }

    constructor (address payable _stake, address payable _staking, address payable _rewards, address payable _owner, address payable _operator) Auth(address(_owner),address(_operator),_msgSender()) payable {
        _poolId = 0;
        _pools++;
        _governor = payable(_operator);
        OWNER = _owner;
        OPERATOR = _operator;
        STAKE_TOKEN = _stake;
        STAKE_POOL = payable(this);
        STAKING_TOKEN[_poolId] = _staking;
        REWARDS_TOKEN[_poolId] = _rewards;
        genesis = block.timestamp;
        initialize(_stake,_staking,_rewards,_poolId); 
    }

    fallback() external payable {
    }
    
    receive() external payable {
    }
    
    function name() external pure returns (string memory) { return _name; }
    function getOwner() external view returns (address) { return Governor(); }
    function balanceOf_iStack(uint stackId,address token) public view override returns (uint) { return stack_balance[stackId][token]; }
    function balance(address wallet, address token) public view override returns (uint) { return user_balances[wallet][token]; }

    function Governor() public view override returns (address payable) {
        address payable _address = _governor;
        return payable(_address);
    }

    function Operator() public view override returns (address payable) {
        address payable _address = OPERATOR;
        return payable(_address);
    }
    
    function Manager() public view override returns (address payable) {
        address payable _address = MANAGER;
        return payable(_address);
    }

    // function Vaults() public view override returns (address payable[] memory) { return vaults; }
    // function Vault(uint _i) public view override returns (address payable) { return payable(vaults[_i]); }
    function StakePool() public view override returns (address payable) { return payable(STAKE_POOL); }
    function StakeToken() public view override returns (address payable) { return payable(STAKE_TOKEN); }
    function StakingToken(uint _pool_Id) public view override returns (address payable) { return payable(STAKING_TOKEN[_pool_Id]); }
    function RewardsToken(uint _pool_Id) public view override returns (address payable) { return payable(REWARDS_TOKEN[_pool_Id]); }    

    function isGovernor(address account) public view returns (bool) {
        if(address(account) == address(_governor)){
            return true;
        } else {
            return false;
        }
    }

    function isStake(address account) public view returns (bool) {
        if(address(account) == address(STAKE_TOKEN)){
            return true;
        } else {
            return false;
        }
    }

    function authorizeSTAKE(address payable stake) public virtual authorized() {
        Auth.authorize(address(stake));
    }

    function setStakeToken(address payable stakeToken) public override authorized() returns(bool) {
        STAKE_TOKEN = stakeToken;
        return Auth.authorize(address(STAKE_TOKEN));
    }

    function setStakingToken(address payable stakingToken, uint pool_id) public override authorized() returns(bool) {
        STAKING_TOKEN[pool_id] = stakingToken;
        return Auth.authorize(address(STAKING_TOKEN[pool_id]));
    }

    function setRewardsToken(address payable rewardsToken, uint pool_id) public override authorized() returns(bool) {
        REWARDS_TOKEN[pool_id] = rewardsToken;
        return Auth.authorize(address(REWARDS_TOKEN[pool_id]));
    }

    function setManager(address payable _manager) public override authorized() returns(bool) {
        MANAGER = _manager;
        return Auth.authorize(address(MANAGER));
    }

    // function deploy_iVault(uint pool_id) public virtual override authorized() returns(address payable) {
    //     address payable _stakeToken = StakeToken();
    //     address payable _stakePool = StakePool();
    //     address payable _rewardsPool = ISTAKE(StakeToken()).RewardsPool(pool_id);
    //     address payable _stakingToken = StakingToken(pool_id);
    //     address payable _rewardsToken = RewardsToken(pool_id);
    //     address payable _vault = payable(new BRIDGE_iVAULT(_stakeToken,_stakingToken,_rewardsToken,_stakePool,_rewardsPool,Governor(),Operator()));
    //     vaults.push(_vault);
    //     return _vault;
    // }
    
    function initialize(address payable _stakeToken,address payable _stakingToken,address payable _rewardsToken, uint pool_id) private {
        require(initialized == false);
        (bool successA) = setStakeToken(_stakeToken);
        (bool successB) = setRewardsToken(_rewardsToken, pool_id);
        (bool successC) = setStakingToken(_stakingToken, pool_id);
        Auth.authorize(address(_governor));
        Auth.authorize(address(_community));
        Auth.authorize(address(STAKE_POOL));
        bool success = false;
        if(successA == true && successB == true && successC == true){
            success = true;
        }
        require(success == true);
        initialized = true;
        require(initialized == true);
        emit DeployedStakePool(address(this));
    }
    
    function Stake_Tokens(uint256 amount, address payable _address, uint pool_id) public override virtual onlyStake() returns (bool) {
        require(address(_address) != address(0));
        uint stackId = ISTAKE(address(STAKE_TOKEN)).getStack_byWallet(_address,_poolId).stack.id;
        user_balances[address(_address)][address(STAKING_TOKEN[pool_id])] += amount;
        stack_balance[stackId][address(STAKING_TOKEN[pool_id])] = user_balances[address(_address)][address(STAKING_TOKEN[pool_id])];
        return true;
    }

    function UnStake_Tokens(uint256 amount, address payable _address, uint pool_id) public override virtual onlyStake() returns (bool) {
        require(address(_address) != address(0));
        uint stackId = ISTAKE(address(STAKE_TOKEN)).getStack_byWallet(_address,_poolId).stack.id;
        uint user_balance = user_balances[address(_address)][address(STAKING_TOKEN[pool_id])];
        uint stack_balances = stack_balance[stackId][address(STAKING_TOKEN[pool_id])];
        if(uint(user_balance) > uint(0) || uint(stack_balances) > uint(0)){
            require(uint(stack_balances) >= uint(amount),"not enough token in this iStack");
            require(uint(user_balance) >= uint(amount),"not enough iStack balance on account");
            require(IERC20(STAKING_TOKEN[pool_id]).transfer(payable(_address), amount),"Transfer Failed!");
            user_balances[address(_address)][address(STAKING_TOKEN[pool_id])] -= amount;
            stack_balance[stackId][address(STAKING_TOKEN[pool_id])] = user_balances[address(_address)][address(STAKING_TOKEN[pool_id])];
            return true;
        } else {
            revert("not enough staked token");
        }
    }

    function Swap_iStack(uint256 amount, address payable from_address, address payable to_address, uint r_StackID, uint pool_id) public virtual override onlyStake() returns (bool) {
        require(address(to_address) != address(0) && address(from_address) != address(0),"Burn prevention");
        uint stackId_from = ISTAKE(address(STAKE_TOKEN)).getStack_byWallet(from_address,_poolId).stack.id;
        uint stack_balances = balanceOf_iStack(stackId_from,address(STAKING_TOKEN[pool_id]));
        uint user_balance = balance(address(from_address),address(STAKING_TOKEN[pool_id]));
        uint stackId_to = r_StackID;
        if(uint(user_balance) > uint(0) || uint(stack_balances) > uint(0)){
            require(uint(stack_balances) >= uint(amount),"not enough token in this iStack");
            require(uint(user_balance) >= uint(amount),"not enough iStack balance on account");
            // require(IERC20(STAKING_TOKEN).transfer(payable(to_address), amount),"Transfer Failed!");
            user_balances[address(from_address)][address(STAKING_TOKEN[pool_id])] -= amount;
            stack_balance[stackId_from][address(STAKING_TOKEN[pool_id])] = user_balances[address(from_address)][address(STAKING_TOKEN[pool_id])];
            user_balances[address(to_address)][address(STAKING_TOKEN[pool_id])] += amount;
            stack_balance[stackId_to][address(STAKING_TOKEN[pool_id])] = user_balances[address(to_address)][address(STAKING_TOKEN[pool_id])];
            return true;
        } else {
            revert("not enough staked token");
        }
    }

    function UnStake_Network_Tokens(address token) public virtual override returns (bool) {
        uint user_balance = user_balances[address(OPERATOR)][address(token)];
        uint stackId = ISTAKE(address(STAKE_TOKEN)).getStack_byWallet(OPERATOR,_poolId).stack.id;
        uint stack_balances = stack_balance[stackId][address(token)];
        if(uint(user_balance) > uint(0) || uint(stack_balances) > uint(0)){
            require(IERC20(token).transfer(payable(OPERATOR), user_balance));
            user_balances[address(OPERATOR)][address(token)] -= user_balance;
            stack_balance[stackId][address(token)] -= stack_balances;
            return true;
        } else {
            revert("not enough staked token");
        }
    }
    
    function EMERGENCY_WITHDRAW_Token(address token) public override virtual {
        require(IERC20(token).transfer(OPERATOR, IERC20(token).balanceOf(address(this))));
    }
    
    function EMERGENCY_WITHDRAW_Ether() public override payable {
        (bool success,) = OPERATOR.call{value: address(this).balance}("");
        require(success == true);
    }
    
    function transferGovernership(address payable newGovernor) public virtual onlyGovernor() returns(bool) {
        require(newGovernor != payable(0), "Ownable: new owner is the zero address");
        authorizations[address(_governor)] = false;
        _governor = payable(newGovernor);
        authorizations[address(newGovernor)] = true;
        return true;
    }
}