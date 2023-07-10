//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Interfaces/ISTACK.sol";
import "./StakePool/iStackPool.sol";
import "./RewardsPool/iRewardsPool_CrossChain.sol";
import "./Deploy/iDeploy_Manager_CrossChain.sol";
import "./Token/ERC20.sol";

contract iStack_CrossChain_Token is _MSG, ERC20 {
    constructor()
        ERC20(unicode"Stacked-KEK", unicode"sKEK", 18)
    {}
}

contract StakeToken_CrossChain_DeFi is _MSG, iStack_CrossChain_Token, Auth, ISTAKE {
    using SafeMath for uint256;

    address payable internal OWNER;
    address payable internal MANAGER;
    address payable internal OPERATOR;

    address payable internal STAKE_TOKEN;
    address payable internal STAKE_POOL;

    uint256 private BP;
    uint256 private genesis;
    uint256 private cc_id = 0;
    uint256 private pools = 0;
    uint256 private POOL_FEE = 250;
    uint256 private _network_Rewards = 0;

    mapping(uint256 => iStack) internal iStack_Core;
    mapping(address => uint256) internal TOKEN_POOL;
    mapping(uint256 => address payable) internal REWARDS_POOL;
    mapping(uint256 => address payable) internal STAKING_TOKEN;
    mapping(uint256 => address payable) internal REWARDS_TOKEN;

    mapping(uint256 => uint256) internal REBATE;
    mapping(uint256 => uint256) internal REBATE_CROSSCHAIN;
    mapping(uint256 => uint256) internal REBATE_TIME_TO_UNSTAKE;
    mapping(uint256 => uint256) internal REBATE_TIME_TO_CLAIM;

    mapping(address => mapping(address => mapping(uint256 => bool)))
        private iMigrated;
    mapping(address => mapping(uint256 => bool)) private isMigrateable;
    mapping(address => mapping(uint256 => User)) private users;
    mapping(uint256 => mapping(uint256 => Stack)) private _user;
    mapping(address => uint256) private _networkRewards;
    mapping(uint256 => address) private _stackOwner;
    mapping(uint256 => bool) private SupplyCap;
    mapping(uint256 => uint256) private _eth_toll;
    mapping(uint256 => uint256) private _toll;

    event Stake(
        address indexed dst,
        uint256 tokenAmount,
        uint256 when,
        uint256 pool_id
    );
    event UnStake(
        address indexed dst,
        uint256 tokenAmount,
        uint256 when,
        uint256 pool_id
    );
    event Mint(address indexed dst, uint256 minted);
    event Burn(address indexed zeroAddress, uint256 burned);
    event ClaimToken(
        address indexed src,
        uint256 tokenAmount,
        uint256 when,
        uint256 pool_id
    );
    event Swap(
        address indexed src,
        uint256 amount,
        address indexed dest,
        uint256 when
    );
    event CrossChain(
        address indexed wallet,
        uint256 crossChain,
        uint256 when,
        uint256 crosschain_id,
        uint256 pool_id
    );
    event Member_Gain(address indexed _member, uint256 _amount);
    event Network_Gain(address indexed _iVault, uint256 _amount);
    event Member_Harvest_Yield(address indexed _member, uint256 _amount);
    event Network_Harvest_Yield(address indexed _iVault, uint256 _amount);

    constructor(
        address payable _stakingToken,
        address payable _rewardsToken,
        address payable _owner,
        address payable _operator,
        bool isTestnet
    ) Auth(address(_msgSender()), address(_owner), address(_operator)) {
        uint256 _pool_ID = 0;
        pools++;
        BP = 10000;
        _toll[_pool_ID] = 150; // 1.5%
        _eth_toll[_pool_ID] = 0.005369441030900312 ether;

        OWNER = _owner;
        OPERATOR = payable(_msgSender());

        REBATE_CROSSCHAIN[_pool_ID] = uint256(150); // 1.5%
        REBATE[_pool_ID] = uint256(9.512937595129373666 ether); // 9.512937595129373666 KEK
        REBATE_TIME_TO_CLAIM[_pool_ID] = 1 minutes;
        REBATE_TIME_TO_UNSTAKE[_pool_ID] = 1 minutes;

        genesis = block.timestamp + 1 minutes;

        STAKE_TOKEN = payable(this);
        STAKING_TOKEN[_pool_ID] = _stakingToken;
        REWARDS_TOKEN[_pool_ID] = _rewardsToken;

        STAKE_POOL = payable(
            new iVAULT_STAKE_POOL(
                STAKE_TOKEN,
                STAKING_TOKEN[_pool_ID],
                REWARDS_TOKEN[_pool_ID],
                OWNER,
                OPERATOR
            )
        );
        REWARDS_POOL[_pool_ID] = payable(
            new iVAULT_CrossChain_REWARDS_POOL(
                STAKE_TOKEN,
                STAKING_TOKEN[_pool_ID],
                REWARDS_TOKEN[_pool_ID],
                STAKE_POOL,
                OWNER,
                OPERATOR,
                _pool_ID
            )
        );

        MANAGER = payable(
            address(
                new iDeploy_MGR_CrossChain(
                    true,
                    isTestnet,
                    STAKE_TOKEN,
                    STAKING_TOKEN[_pool_ID],
                    REWARDS_TOKEN[_pool_ID],
                    REWARDS_POOL[_pool_ID],
                    STAKE_POOL,
                    OWNER,
                    OPERATOR
                )
            )
        );
        require(setManager(MANAGER, _pool_ID));
    }

    fallback() external payable {}

    receive() external payable {}

    function Governor() public view override returns (address payable) {
        return OWNER;
    }

    function Operator() public view override returns (address payable) {
        return OPERATOR;
    }

    function Manager() public view override returns (address payable) {
        return MANAGER;
    }

    function StakePool() public view override returns (address payable) {
        return STAKE_POOL;
    }

    function CrossChain_Rate(uint256 _poolId)
        public
        view
        override
        returns (uint256)
    {
        return REBATE_CROSSCHAIN[_poolId];
    }

    function StakeToken() public view override returns (address payable) {
        return STAKE_TOKEN;
    }

    function StakingToken(uint256 _poolId)
        public
        view
        override
        returns (address payable)
    {
        return STAKING_TOKEN[_poolId];
    }

    function RewardsPool(uint256 _poolId)
        public
        view
        override
        returns (address payable)
    {
        return REWARDS_POOL[_poolId];
    }

    function RewardsToken(uint256 _poolId)
        public
        view
        override
        returns (address payable)
    {
        return REWARDS_TOKEN[_poolId];
    }

    function TotalETHFees(uint256 _poolId)
        public
        view
        override
        returns (uint256)
    {
        return Get_iStack(_poolId).totalEtherFees;
    }

    function Rewards(uint256 _poolId) public view override returns (uint256) {
        return REBATE[_poolId];
    }

    function Get_iStack(uint256 _poolId)
        public
        view
        override
        returns (iStack memory)
    {
        iStack memory iStack = iStack_Core[_poolId];
        return iStack;
    }

    function TotalTokenFees(uint256 _poolId)
        public
        view
        override
        returns (uint256)
    {
        return Get_iStack(_poolId).totalTokenFees;
    }

    function TotalTokenBurn(uint256 _poolId)
        public
        view
        override
        returns (uint256)
    {
        return Get_iStack(_poolId).totalTokenBurn;
    }

    function TotalTokenStaked(uint256 _poolId)
        public
        view
        override
        returns (uint256)
    {
        return Get_iStack(_poolId).totalTokenStaked;
    }

    function TotalTokenRewards(uint256 _poolId)
        public
        view
        override
        returns (uint256)
    {
        return Get_iStack(_poolId).totalTokenRewards;
    }

    function Pool_TTC(uint256 _poolId) public view override returns (uint256) {
        return REBATE_TIME_TO_CLAIM[_poolId];
    }
    
    function Token_Pool(address payable _token) public view returns (uint) {
        return TOKEN_POOL[_token];
    }

    function setManager(address payable _manager, uint256 _poolId)
        public
        override
        authorized
        returns (bool)
    {
        MANAGER = _manager;
        ISTAKEPOOL(STAKE_POOL).setManager(MANAGER);
        IREWARDSPOOL(REWARDS_POOL[_poolId]).setManager(MANAGER);
        return Auth.authorize(address(MANAGER));
    }

    function Pools() public view returns (uint256) {
        return pools;
    }

    function setIsMigrateable(
        address _address,
        uint256 _poolId,
        bool _isMigrateable
    ) public virtual authorized {
        isMigrateable[_address][_poolId] = _isMigrateable;
    }

    function iMigrate(address _iStack, uint256 _poolId) public virtual {
        require(isMigrateable[_iStack][_poolId]);
        User memory member = ISTAKE(_iStack).getStack_byWallet(
            _msgSender(),
            _poolId
        );
        require(
            uint256(member.stack.id) != uint256(0),
            "Only iStack holders can migrate"
        );
        require(
            iMigrated[_msgSender()][_iStack][_poolId] == false,
            "This iStack has already been migrated"
        );
        iMigrated[_msgSender()][_iStack][_poolId] = true;
        address payable _ST = ISTAKE(_iStack).StakingToken(_poolId);
        uint256 x = 0;
        uint256 _p = 0;
        address payable _s;
        while (x < pools) {
            address payable _st = StakingToken(x);
            if (address(_st) == address(_ST)) {
                _s = _st;
                _p = x;
                break;
            } else {
                x++;
            }
        }
        require(
            ISTAKE(payable(_iStack)).transfer_FromPool(
                payable(_msgSender()),
                payable(this),
                false,
                _poolId,
                member.stack.totalStaked
            )
        );
        require(
            ISTAKE(payable(_iStack)).unStakeToken(
                member.stack.totalStaked,
                _poolId
            )
        );
        require(stakeToken(member.stack.totalStaked, _p));
    }

    function reboot_CrossChain(uint256 _poolId) public authorized {
        setSupply(_poolId, false);
        uint256 x = 0;
        address payable[] memory accounts = IREWARDSPOOL(REWARDS_POOL[_poolId])
            .Accounts();
        while (x < accounts.length) {
            reboot_CrossChain_byWallet(accounts[x], _poolId, true);
            if (x == accounts.length - 1) {
                break;
            } else {
                x++;
            }
        }
    }

    function reboot_CrossChain_byWallet(
        address _wallet,
        uint256 _poolId,
        bool _bulk
    ) public authorized {
        if (!_bulk) {
            setSupply(_poolId, false);
        }
        User storage account = users[_wallet][_poolId];
        account.stack.expired = false;
        users[_wallet][_poolId] = account;
        _user[account.stack.id][_poolId] = account.stack;
    }

    function setSupply(uint256 _poolId, bool _supply) public authorized {
        SupplyCap[_poolId] = _supply;
    }

    function set_Tolls(
        uint256 _poolId,
        uint256 _tollPercent,
        uint256 _ethToll
    ) public virtual authorized {
        POOL_FEE = _tollPercent; // in BP, so 100 == 1%
        _toll[_poolId] = POOL_FEE;
        _eth_toll[_poolId] = _ethToll; // in wei
    }

    function setRewardAmount(
        uint256 rewardAmount,
        uint256 crosschain,
        uint256 _poolId
    ) public override authorized {
        REBATE[_poolId] = uint256(rewardAmount);
        REBATE_CROSSCHAIN[_poolId] = crosschain;
    }

    function setRewardsPool(address payable _rewardsPool, uint256 _poolId)
        public
        virtual
        override
        authorized
        returns (bool set)
    {
        IREWARDSPOOL(REWARDS_POOL[_poolId]).setRewardsPool(_rewardsPool);
        REWARDS_POOL[_poolId] = _rewardsPool;
        set = Auth.authorize(address(REWARDS_POOL[_poolId]));
        // default tolls
        _toll[_poolId] = uint256(150); // 1.5%
        _eth_toll[_poolId] = uint256(0.005756312910301990 ether);
        require(set);
        return set;
    }

    function setRewardsToken(address payable token, uint256 _poolId)
        public
        override
        authorized
        returns (bool)
    {
        REWARDS_TOKEN[_poolId] = token;
        TOKEN_POOL[token] = _poolId;
        return true;
    }

    function setStakingToken(address payable token, uint256 _poolId)
        public
        override
        authorized
        returns (bool)
    {
        STAKING_TOKEN[_poolId] = token;
        bool success = Auth.authorize(address(STAKING_TOKEN[_poolId]));
        require(success);
        return (success);
    }

    function getStack_byWallet(address usersWallet, uint256 _poolId)
        public
        view
        override
        returns (ISTAKE.User memory)
    {
        User memory user = users[usersWallet][_poolId];
        return user;
    }

    function getStack_byId(uint256 stackID, uint256 _poolId)
        public
        view
        override
        returns (ISTAKE.Stack memory)
    {
        Stack memory stack = _user[stackID][_poolId];
        return stack;
    }

    function hasAllowance(address sender, uint amount) public view returns(bool) {
        bool has_Allowance;
        uint256 allowance_ = IERC20(STAKE_TOKEN).allowance(
            sender,
            _msgSender()
        );
        if (address(_msgSender()) == address(sender)) {
            has_Allowance = true;
        } else {
            if (uint256(allowance_) >= uint256(amount)) {
                has_Allowance = true;
            } else {
                has_Allowance = false;
            }
        }
        return has_Allowance;
    }

    function iStack_Transfer_From(
        address payable sender,
        address payable _receiver,
        bool crosschain,
        uint256 amount,
        uint256 _poolId
    ) private returns (bool) {
        User storage _sender = users[sender][_poolId];
        User storage receiver = users[_receiver][_poolId];
        require(address(receiver.stack.owner) != address(_sender.stack.owner));
        require(hasAllowance(sender,amount));
        require(
            uint256(_sender.stack.id) != uint256(0) &&
                uint256(_sender.stack.id) > uint256(0)
        );
        if (uint256(receiver.stack.id) == uint256(0)) {
            iStack_Core[_poolId].stacks += 1;
            receiver.stack.id = iStack_Core[_poolId].stacks;
            receiver.stack.owner = payable(_receiver);
            _stackOwner[receiver.stack.id] = address(_receiver);
        }
        if (uint256(allowance(_receiver, address(this))) < type(uint256).max) {
            _approve(_receiver, address(this), type(uint256).max);
        }
        require(
            ISTAKEPOOL(STAKE_POOL).Swap_iStack(
                amount,
                payable(sender),
                payable(_receiver),
                receiver.stack.id,
                _poolId
            )
        );
        require(uint256(_sender.stack.totalStaked) >= uint256(amount));
        if(!crosschain){
            _sender.stack.totalStaked = _sender.stack.totalStaked.sub(amount);
            receiver.stack.totalStaked = receiver.stack.totalStaked.add(amount);
        
        } else {
            _sender.stack.totalStaked = _sender.stack.totalStaked.sub(amount);
            _sender.stack.crosschain = _sender.stack.crosschain.sub(amount);
            receiver.stack.crosschain = receiver.stack.crosschain.add(amount);
        }
        if (
            uint256(_sender.stack.lastClaimed) <
            uint256(receiver.stack.lastClaimed) ||
            uint256(receiver.stack.lastClaimed) == uint256(0)
        ) {
            receiver.stack.lastClaimed = _sender.stack.lastClaimed;
        }
        if (
            uint256(_sender.stack.lastStakeTime) <
            uint256(receiver.stack.lastStakeTime) ||
            uint256(receiver.stack.lastStakeTime) == uint256(0)
        ) {
            receiver.stack.lastStakeTime = _sender.stack.lastStakeTime;
        }
        _user[_sender.stack.id][_poolId] = _sender.stack;
        _user[receiver.stack.id][_poolId] = receiver.stack;
        require(_transfer(sender, _receiver, amount));
        _approve(
            sender,
            _msgSender(),
            IERC20(STAKE_TOKEN).allowance(sender, _msgSender()).sub(amount)
        );
        emit UnStake(
            address(_sender.stack.owner),
            amount,
            block.timestamp,
            _poolId
        );
        emit Swap(
            address(_sender.stack.owner),
            amount,
            address(receiver.stack.owner),
            block.timestamp
        );
        emit Stake(
            address(receiver.stack.owner),
            amount,
            block.timestamp,
            _poolId
        );
        return true;
    }

    function iStack_Transfer(
        address payable _receiver,
        bool crosschain,
        uint256 amount,
        uint256 _poolId
    ) private returns (bool) {
        User storage sender = users[_msgSender()][_poolId];
        User storage receiver = users[_receiver][_poolId];
        require(address(receiver.stack.owner) != address(sender.stack.owner));
        require(address(msg.sender) == address(sender.stack.owner));
        bool userOwnsStack = checkUserId(sender.stack.id);
        require(userOwnsStack);
        require(
            uint256(sender.stack.id) != uint256(0) &&
                uint256(sender.stack.id) > uint256(0)
        );
        if (uint256(receiver.stack.id) == uint256(0)) {
            iStack memory iStack = iStack_Core[_poolId];
            iStack.stacks += 1;
            receiver.stack.id = iStack.stacks;
            receiver.stack.owner = payable(_receiver);
            _stackOwner[receiver.stack.id] = address(_receiver);
        }
        if (uint256(allowance(_receiver, address(this))) < type(uint256).max) {
            _approve(_receiver, address(this), type(uint256).max);
        }
        require(
            ISTAKEPOOL(STAKE_POOL).Swap_iStack(
                amount,
                payable(_msgSender()),
                payable(_receiver),
                receiver.stack.id,
                _poolId
            )
        );
        require(uint256(sender.stack.totalStaked) >= uint256(amount));
        if(!crosschain){
            sender.stack.totalStaked = sender.stack.totalStaked.sub(amount);
            receiver.stack.totalStaked = receiver.stack.totalStaked.add(amount);
        } else {
            sender.stack.totalStaked = sender.stack.totalStaked.sub(amount);
            sender.stack.crosschain = sender.stack.crosschain.sub(amount);
            receiver.stack.crosschain = receiver.stack.crosschain.add(amount);
        }
        if (
            uint256(sender.stack.lastClaimed) <
            uint256(receiver.stack.lastClaimed) ||
            uint256(receiver.stack.lastClaimed) == uint256(0)
        ) {
            receiver.stack.lastClaimed = sender.stack.lastClaimed;
        }
        if (
            uint256(sender.stack.lastStakeTime) <
            uint256(receiver.stack.lastStakeTime) ||
            uint256(receiver.stack.lastStakeTime) == uint256(0)
        ) {
            receiver.stack.lastStakeTime = sender.stack.lastStakeTime;
        }
        _user[sender.stack.id][_poolId] = sender.stack;
        _user[receiver.stack.id][_poolId] = receiver.stack;
        require(_transfer(_msgSender(), _receiver, amount));
        emit UnStake(
            address(sender.stack.owner),
            amount,
            block.timestamp,
            _poolId
        );
        emit Swap(
            address(sender.stack.owner),
            amount,
            address(receiver.stack.owner),
            block.timestamp
        );
        emit Stake(
            address(receiver.stack.owner),
            amount,
            block.timestamp,
            _poolId
        );
        return true;
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        require(uint256(amount) > uint256(0));
        require(address(recipient) != address(_msgSender()));
        return iStack_Transfer(payable(recipient), false, amount, uint256(0));
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        require(uint256(amount) > uint256(0));
        require(address(recipient) != address(sender));
        require(address(recipient) != address(_msgSender()));
        return
            iStack_Transfer_From(
                payable(sender),
                payable(recipient),
                false,
                amount,
                uint256(0)
            );
    }

    function transfer_FromPool(
        address payable sender,
        address payable recipient,
        bool crosschain,
        uint256 _poolId,
        uint256 amount
    ) public virtual override returns (bool) {
        require(uint256(amount) > uint256(0));
        require(uint256(_poolId) <= uint256(Pools()));
        require(address(recipient) != address(sender));
        require(address(recipient) != address(_msgSender()));
        if (address(sender) == address(_msgSender())) {
            return iStack_Transfer(recipient, crosschain, amount, _poolId);
        } else {
            return iStack_Transfer_From(sender, recipient, crosschain, amount, _poolId);
        }
    }

    function checkUserStakes(address usersWallet, uint256 _poolId)
        public
        view
        override
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        User memory user = getStack_byWallet(usersWallet, _poolId);
        bool userCanClaim = true;
        uint256 timeStaked;
        uint256 shareOfPool;
        uint256 pendingRewards;
        if (uint256(user.stack.totalStaked) > uint256(0)) {
            if (
                uint256(user.stack.lastClaimed) >
                uint256(user.stack.lastStakeTime)
            ) {
                timeStaked = (uint256(block.timestamp) -
                    uint256(user.stack.lastClaimed));
            } else {
                timeStaked = (uint256(block.timestamp) -
                    uint256(user.stack.lastStakeTime));
            }
            shareOfPool = ((uint256(TotalTokenStaked(_poolId)) /
                uint256(user.stack.totalStaked)) * BP);
            pendingRewards =
                ((uint256(REBATE[_poolId]) *
                    uint256(timeStaked / REBATE_TIME_TO_CLAIM[_poolId])) /
                    shareOfPool) *
                BP;
            uint256 rB = ISTAKE_MGR(address(MANAGER)).rewardsPoolBalance(
                _poolId
            );
            if (uint256(pendingRewards) > uint256(rB)) {
                if (user.stack.expired == false) {
                    pendingRewards = ((uint256(rB) / shareOfPool) * BP);
                } else if (
                    user.stack.expired == true && SupplyCap[_poolId] == true
                ) {
                    pendingRewards = 0;
                }
            }
            if (timeStaked < uint256(REBATE_TIME_TO_CLAIM[_poolId])) {
                userCanClaim = false;
            }
            return (
                pendingRewards,
                shareOfPool,
                user.stack.lastStakeTime,
                user.stack.totalStaked,
                userCanClaim
            );
        } else {
            return (0, 0, 0, 0, false);
        }
    }

    function RewardsSupply(uint256 _poolId, address _wallet)
        public
        view
        returns (uint256)
    {
        return IERC20(REWARDS_TOKEN[_poolId]).balanceOf(_wallet);
    }

    function checkUserId(uint256 _id) public view returns (bool) {
        bool userOwnsStack = address(msg.sender) == _stackOwner[_id];
        require(userOwnsStack);
        return userOwnsStack;
    }

    function Check_Rewards_Pool(uint256 _poolId) private returns (bool) {
        uint256 rewards_balance = IERC20(REWARDS_TOKEN[_poolId]).balanceOf(
            address(RewardsPool(_poolId))
        );
        if (uint256(rewards_balance) > uint256(0)) {
            SupplyCap[_poolId] = false;
            return false;
        } else {
            SupplyCap[_poolId] = true;
            return true;
        }
    }

    function Check_Rewards_Pool(bool _return, uint256 _poolId) public {
        uint256 rewards_balance = IERC20(REWARDS_TOKEN[_poolId]).balanceOf(
            address(RewardsPool(_poolId))
        );
        if (_return) {
            Check_Rewards_Pool(_poolId);
        } else {
            if (uint256(rewards_balance) > uint256(0)) {
                SupplyCap[_poolId] = false;
            } else {
                SupplyCap[_poolId] = true;
            }
        }
    }

    function stakeToken(uint256 tokenAmount, uint256 _poolId)
        public
        payable
        override
        returns (bool)
    {
        require(uint256(tokenAmount) > uint256(0));
        require(
            SupplyCap[_poolId] == false && Check_Rewards_Pool(_poolId) == false
        );
        User storage user = users[_msgSender()][_poolId];
        if (
            uint256(user.stack.id) > uint256(0) ||
            uint256(user.stack.id) != uint256(0)
        ) {
            require(checkUserId(user.stack.id));
        } else {
            require(uint256(user.stack.id) == uint256(0));
            iStack_Core[_poolId].stacks += 1;
            user.stack.id = iStack_Core[_poolId].stacks;
            user.stack.owner = payable(msg.sender);
            _stackOwner[user.stack.id] = address(msg.sender);
        }
        uint256 pool_fee = tokenAmount.mul(POOL_FEE).div(BP);
        require(
            uint256(IERC20(STAKING_TOKEN[_poolId]).balanceOf(_msgSender())) >=
                uint256(tokenAmount)
        );
        if (
            uint256(allowance(_msgSender(), address(this))) < type(uint256).max
        ) {
            _approve(_msgSender(), address(this), type(uint256).max);
        }
        tokenAmount -= pool_fee;
        bool successA = IERC20(STAKING_TOKEN[_poolId]).transferFrom(
            _msgSender(),
            STAKE_POOL,
            pool_fee
        );
        bool successB = IERC20(STAKING_TOKEN[_poolId]).transferFrom(
            _msgSender(),
            STAKE_POOL,
            tokenAmount
        );
        require(successA == true && successB == true);
        require(
            ISTAKEPOOL(STAKE_POOL).Stake_Tokens(pool_fee, OPERATOR, _poolId)
        );
        require(
            ISTAKEPOOL(STAKE_POOL).Stake_Tokens(
                tokenAmount,
                payable(_msgSender()),
                _poolId
            )
        );
        require(_mint(_msgSender(), tokenAmount));
        (uint256 pR, , , , bool userCanClaim) = checkUserStakes(
            _msgSender(),
            _poolId
        );
        if (
            userCanClaim == true &&
            uint256(pR) > uint256(0) &&
            uint256(user.stack.totalStaked) > uint256(0)
        ) {
            user.stack.totalClaimed = user.stack.totalClaimed.add(pR);
            user.stack.lastClaimed = block.timestamp;
            require(
                IREWARDSPOOL(REWARDS_POOL[_poolId]).Process_Reward(
                    pR,
                    payable(_msgSender()),
                    false
                )
            );
            iStack_Core[_poolId].totalTokenRewards = iStack_Core[_poolId]
                .totalTokenRewards
                .add(pR);
        }
        user.stack.totalStaked = user.stack.totalStaked.add(tokenAmount);
        user.stack.lastStakeTime = block.timestamp;
        if (uint256(msg.value) >= uint256(0)) {
            OPERATOR.transfer(msg.value);
            iStack_Core[_poolId].totalEtherFees = iStack_Core[_poolId]
                .totalEtherFees
                .add(msg.value);
        }
        uint256 tts = TotalTokenStaked(_poolId);
        iStack_Core[_poolId].totalTokenStaked = tts.add(tokenAmount);
        uint256 ttf = iStack_Core[_poolId].totalTokenFees;
        iStack_Core[_poolId].totalTokenFees = ttf.add(pool_fee);
        _user[user.stack.id][_poolId] = user.stack;
        require(
            uint256(iStack_Core[_poolId].totalTokenStaked) ==
                (uint256(tts) + uint256(tokenAmount))
        );
        emit Stake(
            address(_msgSender()),
            tokenAmount,
            block.timestamp,
            _poolId
        );
        return true;
    }

    function unStakeToken(uint256 amountToken, uint256 _poolId)
        public
        payable
        override
        returns (bool)
    {
        Check_Rewards_Pool(false, _poolId);
        User storage user = users[_msgSender()][_poolId];
        require(uint256(amountToken) > uint256(0));
        require(checkUserId(user.stack.id));
        require(
            uint256(user.stack.id) > uint256(0) &&
                uint256(user.stack.id) != uint256(0)
        );
        (uint256 pR, , , , bool userCanClaim) = checkUserStakes(
            _msgSender(),
            _poolId
        );
        if (
            userCanClaim == true &&
            uint256(pR) > uint256(0) &&
            uint256(user.stack.totalStaked) > uint256(0)
        ) {
            user.stack.totalClaimed = user.stack.totalClaimed.add(pR);
            user.stack.lastClaimed = block.timestamp;
            require(
                IREWARDSPOOL(REWARDS_POOL[_poolId]).Process_Reward(
                    pR,
                    payable(_msgSender()),
                    false
                )
            );
            iStack_Core[_poolId].totalTokenRewards = iStack_Core[_poolId]
                .totalTokenRewards
                .add(pR);
        }
        require(
            block.timestamp >
                user.stack.lastStakeTime.add(REBATE_TIME_TO_UNSTAKE[_poolId]),
            "Wait"
        );
        require(uint256(amountToken) <= uint256(balanceOf(_msgSender())));
        require(_burn(_msgSender(), amountToken));
        user.stack.totalStaked = amountToken.sub(amountToken);
        if (uint256(msg.value) >= uint256(0)) {
            OPERATOR.transfer(msg.value);
            iStack_Core[_poolId].totalEtherFees = iStack_Core[_poolId]
                .totalEtherFees
                .add(msg.value);
        }
        require(
            ISTAKEPOOL(STAKE_POOL).UnStake_Tokens(
                amountToken,
                payable(_msgSender()),
                _poolId
            )
        );
        iStack_Core[_poolId].totalTokenBurn = iStack_Core[_poolId]
            .totalTokenBurn
            .add(amountToken);
        uint256 tts = TotalTokenStaked(_poolId);
        iStack_Core[_poolId].totalTokenStaked = tts.sub(amountToken);
        _user[user.stack.id][_poolId] = user.stack;
        require(
            uint256(iStack_Core[_poolId].totalTokenStaked) ==
                (uint256(tts) - uint256(amountToken))
        );
        emit UnStake(
            address(_msgSender()),
            amountToken,
            block.timestamp,
            _poolId
        );
        return true;
    }

    function Network_Rewards() public view returns (uint256) {
        return _network_Rewards;
    }

    function Member_Rewards(address _member) public view returns (uint256) {
        return _networkRewards[_member];
    }

    function Members_Harvest_Rewards(uint256 _poolId) public virtual {
        uint256 members_rewards = Member_Rewards(_msgSender());
        if (uint256(members_rewards) > uint256(0)) {
            _networkRewards[_msgSender()] = 0;
            _network_Rewards -= uint256(members_rewards);
            require(
                IERC20(REWARDS_TOKEN[_poolId]).transfer(
                    _msgSender(),
                    uint256(Member_Rewards(_msgSender()))
                )
            );
            emit Member_Harvest_Yield(_msgSender(), members_rewards);
        } else {
            revert("No Pending Rewards");
        }
    }

    function Network_Share_Rewards(bool crossChain, uint256 _poolId)
        public
        virtual
    {
        uint256 i = 0;
        uint256 totalShard = 0;
        uint256 network_balance_before_claim = IERC20(REWARDS_TOKEN[_poolId])
            .balanceOf(address(this));
        address payable[] memory accounts = IREWARDSPOOL(REWARDS_POOL[_poolId])
            .Accounts();
        (uint256 pending_rewards, , , , ) = checkUserStakes(
            address(StakeToken()),
            _poolId
        );
        uint256 network_pool = network_balance_before_claim;
        if (uint256(pending_rewards) > uint256(0)) {
            require(Network_Claim_Rewards(crossChain, _poolId));
            uint256 network_balance_after_claim = IERC20(REWARDS_TOKEN[_poolId])
                .balanceOf(address(this));
            if (
                uint256(network_balance_after_claim) >
                uint256(network_balance_before_claim)
            ) {
                network_pool =
                    uint256(network_balance_after_claim) -
                    uint256(network_balance_before_claim);
            }
            uint256 network_shards = ((network_pool * 1024) / BP);
            _networkRewards[
                payable(this)
            ] += network_shards;
            uint256 shard_pool = (network_pool - network_shards);
            while (uint256(i) < uint256(accounts.length)) {
                uint256 remaining_shards = uint256(shard_pool) -
                    uint256(totalShard);
                uint256 remaining_accounts = uint256(accounts.length) -
                    uint256(i);
                uint256 shards = (remaining_shards / remaining_accounts);
                totalShard += shards;
                _network_Rewards += shards;
                _networkRewards[accounts[i]] += shards;
                emit Member_Gain(accounts[i], shards);
                if (i == accounts.length - 1) {
                    break;
                } else {
                    i++;
                }
            }
            emit Network_Gain(address(this), totalShard);
        } else {
            revert("No Pending Rewards");
        }
    }

    function Calc_CrossChain(uint256 tokenAmount, uint256 _poolId)
        public
        view
        returns (uint256)
    {
        return
            ((uint256(tokenAmount) * uint256(REBATE_CROSSCHAIN[_poolId])) /
                uint256(BP)) + uint256(tokenAmount);
    }

    function CrossChain_Swap(address payable _token, uint256 _amount, address payable _receiver, bool _eth_gas)
        public
        payable
        virtual
        override
        returns (bool)
    {
        uint256 _poolId = TOKEN_POOL[_token]; 
        User storage user = users[_msgSender()][_poolId];
        require(checkUserId(user.stack.id));
        uint256 gas = msg.value;
        bool transferred = false;
        if(_eth_gas == true){
            require(uint(gas)>=uint(_eth_toll[_poolId]));
            OPERATOR.transfer(msg.value);
            iStack_Core[_poolId].totalEtherFees = iStack_Core[_poolId]
                .totalEtherFees
                .add(msg.value);
            require(uint256(user.stack.totalStaked) >= uint256(_amount));
            require(
                ISTAKE(payable(STAKE_TOKEN)).transfer_FromPool(
                    payable(_msgSender()),
                    payable(_receiver),
                    true,
                    _poolId,
                    _amount
                )
            );
            transferred = true;
        } else {
            uint toll = (_amount * _toll[_poolId]) / BP;
            _amount-=toll;
            require(uint256(user.stack.totalStaked) >= uint256(_amount));
            iStack_Core[_poolId].totalTokenFees = iStack_Core[_poolId]
                .totalTokenFees
                .add(toll);
            require(
                ISTAKE(payable(STAKE_TOKEN)).transfer_FromPool(
                    payable(_msgSender()),
                    payable(this),
                    false,
                    _poolId,
                    toll
                )
            );
            require(
                ISTAKE(payable(STAKE_TOKEN)).transfer_FromPool(
                    payable(_msgSender()),
                    payable(_receiver),
                    true,
                    _poolId,
                    _amount
                )
            );
            transferred = true;
        }
        return transferred;
    }

    function claimRewardsToken(bool crosschain, uint256 _poolId)
        public
        payable
        override
        returns (bool)
    {
        User storage user = users[_msgSender()][_poolId];
        require(checkUserId(user.stack.id));
        (uint256 pendingRewards, , , , bool userCanClaim) = checkUserStakes(
            _msgSender(),
            _poolId
        );
        require(userCanClaim == true);
        require(uint256(pendingRewards) > uint256(0));
        require(
            block.timestamp >
                user.stack.lastStakeTime.add(REBATE_TIME_TO_CLAIM[_poolId])
        );
        require(uint256(user.stack.totalStaked) > uint256(0));
        if (
            uint256(pendingRewards) >
            uint256(
                IERC20(REWARDS_TOKEN[_poolId]).balanceOf(REWARDS_POOL[_poolId])
            ) ||
            Check_Rewards_Pool(_poolId) == true ||
            SupplyCap[_poolId] == true
        ) {
            require(user.stack.expired == false);
            user.stack.expired = true;
        }
        if (uint256(msg.value) >= uint256(0)) {
            OPERATOR.transfer(msg.value);
            iStack_Core[_poolId].totalEtherFees = iStack_Core[_poolId]
                .totalEtherFees
                .add(msg.value);
        }
        user.stack.totalClaimed = user.stack.totalClaimed.add(pendingRewards);
        user.stack.lastClaimed = block.timestamp;
        if (!crosschain) {
            require(
                IREWARDSPOOL(REWARDS_POOL[_poolId]).Process_Reward(
                    pendingRewards,
                    payable(_msgSender()),
                    false
                )
            );
            iStack_Core[_poolId].totalTokenRewards = iStack_Core[_poolId]
                .totalTokenRewards
                .add(pendingRewards);
            _user[user.stack.id][_poolId] = user.stack;
            emit ClaimToken(
                _msgSender(),
                pendingRewards,
                block.timestamp,
                _poolId
            );
        } else {
            user.stack.crosschain = user.stack.crosschain.add(
                Calc_CrossChain(pendingRewards, _poolId)
            );
            iStack_Core[_poolId].totalCoinRewards = iStack_Core[_poolId]
                .totalCoinRewards
                .add(Calc_CrossChain(pendingRewards, _poolId));
            require(
                IREWARDSPOOL(REWARDS_POOL[_poolId]).Process_Reward(
                    Calc_CrossChain(pendingRewards, _poolId),
                    payable(_msgSender()),
                    true
                )
            );
            _user[user.stack.id][_poolId] = user.stack;
            cc_id = cc_id + 1;
            emit CrossChain(
                user.stack.owner,
                Calc_CrossChain(pendingRewards, _poolId),
                block.timestamp,
                cc_id,
                _poolId
            );
        }
        return true;
    }

    function Network_Claim_Rewards(bool crosschain, uint256 _poolId)
        internal
        returns (bool)
    {
        User storage user = users[address(this)][_poolId];
        require(checkUserId(user.stack.id));
        (uint256 pendingRewards, , , , bool userCanClaim) = checkUserStakes(
            address(this),
            _poolId
        );
        require(userCanClaim == true);
        require(uint256(pendingRewards) > uint256(0));
        require(
            block.timestamp >
                user.stack.lastStakeTime.add(REBATE_TIME_TO_CLAIM[_poolId])
        );
        require(uint256(user.stack.totalStaked) > uint256(0));
        if (
            uint256(pendingRewards) >
            uint256(
                IERC20(REWARDS_TOKEN[_poolId]).balanceOf(REWARDS_POOL[_poolId])
            ) ||
            Check_Rewards_Pool(_poolId) == true ||
            SupplyCap[_poolId] == true
        ) {
            require(user.stack.expired == false);
            user.stack.expired = true;
        }
        user.stack.totalClaimed = user.stack.totalClaimed.add(pendingRewards);
        user.stack.lastClaimed = block.timestamp;
        if (!crosschain) {
            require(
                IREWARDSPOOL(REWARDS_POOL[_poolId]).Process_Reward(
                    pendingRewards,
                    payable(address(this)),
                    false
                )
            );
            iStack_Core[_poolId].totalTokenRewards = iStack_Core[_poolId]
                .totalTokenRewards
                .add(pendingRewards);
            _user[user.stack.id][_poolId] = user.stack;
            emit ClaimToken(
                address(this),
                pendingRewards,
                block.timestamp,
                _poolId
            );
            emit Network_Harvest_Yield(address(this), pendingRewards);
        } else {
            uint256 crosschain_swap = Calc_CrossChain(pendingRewards, _poolId);
            user.stack.crosschain = user.stack.crosschain.add(crosschain_swap);
            iStack_Core[_poolId].totalCoinRewards = iStack_Core[_poolId]
                .totalCoinRewards
                .add(crosschain_swap);
            require(
                IREWARDSPOOL(REWARDS_POOL[_poolId]).Process_Reward(
                    crosschain_swap,
                    payable(address(this)),
                    true
                )
            );
            _user[user.stack.id][_poolId] = user.stack;
            cc_id = cc_id + 1;
            emit CrossChain(
                user.stack.owner,
                crosschain_swap,
                block.timestamp,
                cc_id,
                _poolId
            );
            emit Network_Harvest_Yield(address(this), crosschain_swap);
        }
        return true;
    }

    function EMERGENCY_WITHDRAW_Token(address token) public virtual override {
        require(
            IERC20(token).transfer(
                OPERATOR,
                IERC20(token).balanceOf(address(this))
            )
        );
    }

    function EMERGENCY_WITHDRAW_Ether() public payable override {
        (bool success, ) = OPERATOR.call{value: address(this).balance}("");
        require(success == true);
    }
}
