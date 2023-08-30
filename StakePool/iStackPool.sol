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

// import "../Utilities/iBridgeVault.sol";

// STAKE POOL v8
contract iVAULT_STAKE_POOL is Auth, ISTAKEPOOL {
    /**
     * address
     */
    address payable private _governor =
        payable(0x050134fd4EA6547846EdE4C4Bf46A334B7e87cCD);
    address payable private _community =
        payable(0x050134fd4EA6547846EdE4C4Bf46A334B7e87cCD);

    address payable private OWNER;
    address payable internal MANAGER;
    address payable private OPERATOR;

    address payable internal STAKE_POOL;
    address payable internal STAKE_TOKEN;

    mapping(uint256 => address payable) internal STAKING_TOKEN;
    mapping(uint256 => address payable) internal REWARDS_TOKEN;

    uint256 private genesis;
    /**
     * strings
     */
    string constant _name = "Stack Pool";
    string constant _symbol = "Stack-Pool";

    /**
     * bools
     */
    bool private initialized;

    uint256 internal _poolId;
    uint256 public _pools;

    mapping(address => mapping(address => uint256)) internal user_balances;
    mapping(uint256 => mapping(address => uint256)) internal stack_balance;
    // address payable[] public vaults;

    event DeployedStakePool(address);

    /**
     * Function modifiers
     */
    modifier onlyGovernor() virtual {
        require(isGovernor(_msgSender()), "!GOVERNOR");
        _;
    }

    modifier onlyStake() virtual {
        require(isStake(_msgSender()), "!STAKE");
        _;
    }

    constructor(
        address payable _stake,
        address payable _staking,
        address payable _rewards,
        address payable _owner,
        address payable _operator
    ) payable Auth(address(_owner), address(_operator), _msgSender()) {
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
        initialize(_stake, _staking, _rewards, _poolId);
    }

    fallback() external payable {}

    receive() external payable {}

    function name() external pure returns (string memory) {
        return _name;
    }

    function getOwner() external view returns (address) {
        return Governor();
    }

    function balanceOf_iStack(uint256 stackId, address token)
        public
        view
        override
        returns (uint256)
    {
        return stack_balance[stackId][token];
    }

    function balance(address wallet, address token)
        public
        view
        override
        returns (uint256)
    {
        return user_balances[wallet][token];
    }

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

    function StakePool() public view override returns (address payable) {
        return payable(STAKE_POOL);
    }

    function StakeToken() public view override returns (address payable) {
        return payable(STAKE_TOKEN);
    }

    function StakingToken(uint256 _pool_Id)
        public
        view
        override
        returns (address payable)
    {
        return payable(STAKING_TOKEN[_pool_Id]);
    }

    function RewardsToken(uint256 _pool_Id)
        public
        view
        override
        returns (address payable)
    {
        return payable(REWARDS_TOKEN[_pool_Id]);
    }

    function isGovernor(address account) public view returns (bool) {
        if (
            address(account) == address(_governor) ||
            address(account) == address(MANAGER)
        ) {
            return true;
        } else {
            return false;
        }
    }

    function isStake(address account) public view returns (bool) {
        if (address(account) == address(STAKE_TOKEN)) {
            return true;
        } else {
            return false;
        }
    }

    function authorizeSTAKE(address payable stake) public virtual authorized {
        Auth.authorize(address(stake));
    }

    function setStakeToken(address payable stakeToken)
        public
        override
        authorized
        returns (bool)
    {
        STAKE_TOKEN = stakeToken;
        return Auth.authorize(address(STAKE_TOKEN));
    }

    function setStakingToken(address payable stakingToken, uint256 pool_id)
        public
        override
        authorized
        returns (bool)
    {
        STAKING_TOKEN[pool_id] = stakingToken;
        return Auth.authorize(address(STAKING_TOKEN[pool_id]));
    }

    function setRewardsToken(address payable rewardsToken, uint256 pool_id)
        public
        override
        authorized
        returns (bool)
    {
        REWARDS_TOKEN[pool_id] = rewardsToken;
        return Auth.authorize(address(REWARDS_TOKEN[pool_id]));
    }

    function setManager(address payable _manager)
        public
        override
        authorized
        returns (bool)
    {
        MANAGER = _manager;
        return Auth.authorize(address(MANAGER));
    }

    function initialize(
        address payable _stakeToken,
        address payable _stakingToken,
        address payable _rewardsToken,
        uint256 pool_id
    ) private {
        require(initialized == false);
        bool successA = setStakeToken(_stakeToken);
        bool successB = setRewardsToken(_rewardsToken, pool_id);
        bool successC = setStakingToken(_stakingToken, pool_id);
        Auth.authorize(address(_governor));
        Auth.authorize(address(_community));
        Auth.authorize(address(STAKE_POOL));
        bool success = false;
        if (successA == true && successB == true && successC == true) {
            success = true;
        }
        require(success == true);
        initialized = true;
        require(initialized == true);
        emit DeployedStakePool(address(this));
    }

    function Stake_Tokens(
        uint256 amount,
        address payable _address,
        uint256 pool_id
    ) public virtual override onlyStake returns (bool) {
        require(address(_address) != address(0));
        // uint256 stackId = ISTAKE(address(STAKE_TOKEN))
        //     .getStack_byWallet(_address, _poolId)
        //     .stack
        //     .id;
        user_balances[address(_address)][
            address(STAKING_TOKEN[pool_id])
        ] += amount;
        // stack_balance[stackId][address(STAKING_TOKEN[pool_id])] = user_balances[
        //     address(_address)
        // ][address(STAKING_TOKEN[pool_id])];
        return true;
    }

    function UnStake_Tokens(
        uint256 amount,
        address payable _address,
        uint256 pool_id
    ) public virtual override onlyStake returns (bool) {
        require(address(_address) != address(0));
        // uint256 stackId = ISTAKE(address(STAKE_TOKEN))
        //     .getStack_byWallet(_address, _poolId)
        //     .stack
        //     .id;
        uint256 user_balance = user_balances[address(_address)][
            address(STAKING_TOKEN[pool_id])
        ];
        // uint256 stack_balances = stack_balance[stackId][
        //     address(STAKING_TOKEN[pool_id])
        // ];
        if (
            uint256(user_balance) > uint256(0)
            //  ||
            // uint256(stack_balances) > uint256(0)
        ) {
            // require(
            //     uint256(stack_balances) >= uint256(amount),
            //     "not enough token in this iStack"
            // );
            require(
                uint256(user_balance) >= uint256(amount),
                "not enough iStack balance on account"
            );
            require(
                IERC20(STAKING_TOKEN[pool_id]).transfer(
                    payable(_address),
                    amount
                ),
                "Transfer Failed!"
            );
            user_balances[address(_address)][
                address(STAKING_TOKEN[pool_id])
            ] -= amount;
            // stack_balance[stackId][
            //     address(STAKING_TOKEN[pool_id])
            // ] = user_balances[address(_address)][
            //     address(STAKING_TOKEN[pool_id])
            // ];
            return true;
        } else {
            revert("not enough staked token");
        }
    }

    function Swap_iStack(
        uint256 amount,
        address payable from_address,
        address payable to_address,
        // uint256 r_StackID,
        uint256 pool_id
    ) public virtual override onlyStake returns (bool) {
        require(
            address(to_address) != address(0) &&
                address(from_address) != address(0),
            "Burn prevention"
        );
        // uint256 stackId_from = ISTAKE(address(STAKE_TOKEN))
        //     .getStack_byWallet(from_address, _poolId)
        //     .stack
        //     .id;
        // uint256 stack_balances = balanceOf_iStack(
        //     stackId_from,
        //     address(STAKING_TOKEN[pool_id])
        // );
        uint256 user_balance = balance(
            address(from_address),
            address(STAKING_TOKEN[pool_id])
        );
        // uint256 stackId_to = r_StackID;
        if (
            uint256(user_balance) > uint256(0)
            //  ||
            // uint256(stack_balances) > uint256(0)
        ) {
            // require(
            //     uint256(stack_balances) >= uint256(amount),
            //     "not enough token in this iStack"
            // );
            require(
                uint256(user_balance) >= uint256(amount),
                "not enough iStack balance on account"
            );
            user_balances[address(from_address)][
                address(STAKING_TOKEN[pool_id])
            ] -= amount;
            // stack_balance[stackId_from][
            //     address(STAKING_TOKEN[pool_id])
            // ] = user_balances[address(from_address)][
            //     address(STAKING_TOKEN[pool_id])
            // ];
            user_balances[address(to_address)][
                address(STAKING_TOKEN[pool_id])
            ] += amount;
            // stack_balance[stackId_to][
            //     address(STAKING_TOKEN[pool_id])
            // ] = user_balances[address(to_address)][
            //     address(STAKING_TOKEN[pool_id])
            // ];
            return true;
        } else {
            revert("not enough staked token");
        }
    }

    function UnStake_Network_Tokens(address token)
        public
        virtual
        override
        returns (bool)
    {
        uint256 user_balance = user_balances[address(OPERATOR)][address(token)];
        uint256 stackId = ISTAKE(address(STAKE_TOKEN))
            .getStack_byWallet(OPERATOR, _poolId)
            .stack
            .id;
        uint256 stack_balances = stack_balance[stackId][address(token)];
        if (
            uint256(user_balance) > uint256(0) ||
            uint256(stack_balances) > uint256(0)
        ) {
            require(IERC20(token).transfer(payable(OPERATOR), user_balance));
            user_balances[address(OPERATOR)][address(token)] -= user_balance;
            stack_balance[stackId][address(token)] -= stack_balances;
            return true;
        } else {
            revert("not enough staked token");
        }
    }

    function EMERGENCY_WITHDRAW_Token(address token)
        external
        virtual
        override
        onlyGovernor
    {
        require(
            IERC20(token).transfer(
                OPERATOR,
                IERC20(token).balanceOf(address(this))
            )
        );
    }

    function EMERGENCY_WITHDRAW_Ether()
        external
        payable
        virtual
        override
        onlyGovernor
    {
        (bool success, ) = OPERATOR.call{value: address(this).balance}("");
        require(success == true);
    }

    function transferGovernership(address payable newGovernor)
        public
        virtual
        onlyGovernor
        returns (bool)
    {
        require(
            newGovernor != payable(0),
            "Ownable: new owner is the zero address"
        );
        authorizations[address(_governor)] = false;
        _governor = payable(newGovernor);
        authorizations[address(newGovernor)] = true;
        return true;
    }
}
