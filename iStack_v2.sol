//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Interfaces/ISTACK.sol";
import "./StakePool/iStackPool.sol";
import "./RewardsPool/iRewardsPool.sol";

// import "./Deploy/iDeploy_Manager.sol";

contract StakeToken_DeFi is _MSG, ERC20, Auth, ISTAKE {
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
    uint256 private burnRate = 1000;
    uint256 private _network_Rewards = 0;

    mapping(uint256 => iStack) internal iStack_Core;
    mapping(address => uint256) internal TOKEN_POOL;
    mapping(uint256 => address payable) internal REWARDS_POOL;
    mapping(uint256 => address payable) internal STAKING_TOKEN;
    mapping(uint256 => address payable) internal REWARDS_TOKEN;

    mapping(uint256 => uint256) internal REBATE;
    mapping(uint256 => uint256) internal REBATE_TIME_TO_UNSTAKE;
    mapping(uint256 => uint256) internal REBATE_TIME_TO_CLAIM;

    mapping(address => mapping(address => mapping(uint256 => bool)))
        private iMigrated;
    mapping(address => mapping(uint256 => User)) private users;
    mapping(uint256 => mapping(uint256 => Stack)) private _user;
    mapping(uint256 => address) private _stackOwner;
    mapping(uint256 => bool) private MaxSupply;
    mapping(uint256 => uint256) private SupplyCap;
    mapping(address => bool) private isStaking;

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
    event Member_Gain(address indexed _member, uint256 _amount);
    event Network_Gain(address indexed _iVault, uint256 _amount);
    event Member_Harvest_Yield(address indexed _member, uint256 _amount);
    event Network_Harvest_Yield(address indexed _iVault, uint256 _amount);

    constructor(
        address payable _owner,
        address payable _operator,
        uint256 _genesis
    )
        Auth(address(_msgSender()), address(_owner), address(_operator))
        ERC20("Stacked Duo Token", "DIG")
    {
        uint256 _pool_ID = 0;
        pools++;
        BP = 10000;

        OWNER = _owner;
        OPERATOR = _operator;

        _mint(tx.origin, _genesis * 1 ether);
        SupplyCap[_pool_ID] = _genesis * 1 ether;
        isStaking[tx.origin] = false;

        REBATE[_pool_ID] = uint256(1 ether);
        REBATE_TIME_TO_CLAIM[_pool_ID] = 1 minutes;
        REBATE_TIME_TO_UNSTAKE[_pool_ID] = 1 minutes;

        genesis = block.timestamp + 1 minutes;

        STAKE_TOKEN = payable(this);
        STAKING_TOKEN[_pool_ID] = STAKE_TOKEN;

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
            new iVAULT_REWARDS_POOL(
                STAKE_TOKEN,
                STAKING_TOKEN[_pool_ID],
                // REWARDS_TOKEN[_pool_ID],
                STAKE_POOL,
                OWNER,
                OPERATOR,
                _pool_ID
            )
        );
        REWARDS_TOKEN[_pool_ID] = REWARDS_POOL[_pool_ID];

        // MANAGER = payable(
        //     address(
        //         new iDeploy_MGR(
        //             isTestnet,
        //             STAKE_TOKEN,
        //             STAKING_TOKEN[_pool_ID],
        //             // REWARDS_TOKEN[_pool_ID],
        //             REWARDS_POOL[_pool_ID],
        //             STAKE_POOL,
        //             OWNER,
        //             OPERATOR
        //         )
        //     )
        // );
        // require(setManager(MANAGER, _pool_ID));
        _approve(_msgSender(), address(this), type(uint256).max);
    }

    fallback() external payable {}

    receive() external payable {}

    function Governor() public view override returns (address payable) {
        return OWNER;
    }

    function Operator() public view override returns (address payable) {
        return OPERATOR;
    }

    // function Manager() public view override returns (address payable) {
    //     return MANAGER;
    // }

    function StakePool() public view override returns (address payable) {
        return STAKE_POOL;
    }

    function Rebate_Rate(uint256 _poolId)
        public
        view
        override
        returns (uint256)
    {
        return REBATE[_poolId];
    }

    function Supply_Cap(uint256 _poolId)
        external
        view
        override
        returns (uint256)
    {
        return SupplyCap[_poolId];
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

    function Token_Pool(address payable _token) public view returns (uint256) {
        return TOKEN_POOL[_token];
    }

    // function setManager(address payable _manager, uint256 _poolId)
    //     public
    //     override
    //     authorized
    //     returns (bool)
    // {
    //     MANAGER = _manager;
    //     ISTAKEPOOL(STAKE_POOL).setManager(MANAGER);
    //     IREWARDSPOOL(REWARDS_POOL[_poolId]).setManager(MANAGER);
    //     return Auth.authorize(address(MANAGER));
    // }

    function Pools() public view returns (uint256) {
        return pools;
    }

    // function setIsMigrateable(
    //     address _address,
    //     uint256 _poolId,
    //     bool _isMigrateable
    // ) public virtual authorized {
    //     isMigrateable[_address][_poolId] = _isMigrateable;
    // }

    // function iMigrate(address _iStack, uint256 _poolId) public virtual {
    //     require(isMigrateable[_iStack][_poolId]);
    //     User memory member = ISTAKE(_iStack).getStack_byWallet(
    //         _msgSender(),
    //         _poolId
    //     );
    //     require(
    //         uint256(member.stack.id) != uint256(0),
    //         "Only iStack holders can migrate"
    //     );
    //     require(
    //         iMigrated[_msgSender()][_iStack][_poolId] == false,
    //         "This iStack has already been migrated"
    //     );
    //     iMigrated[_msgSender()][_iStack][_poolId] = true;
    //     address payable _ST = ISTAKE(_iStack).StakingToken(_poolId);
    //     uint256 x = 0;
    //     uint256 _p = 0;
    //     address payable _s;
    //     while (x < pools) {
    //         address payable _st = StakingToken(x);
    //         if (address(_st) == address(_ST)) {
    //             _s = _st;
    //             _p = x;
    //             break;
    //         } else {
    //             x++;
    //         }
    //     }
    //     require(
    //         ISTAKE(payable(_iStack)).transfer_FromPool(
    //             payable(_msgSender()),
    //             payable(this),
    //             _poolId,
    //             member.stack.totalStaked
    //         )
    //     );
    //     require(
    //         ISTAKE(payable(_iStack)).unStakeToken(
    //             member.stack.totalStaked,
    //             _poolId
    //         )
    //     );
    //     require(stakeToken(member.stack.totalStaked, _p));
    // }

    function setSupply(uint256 _poolId, uint256 _supply) public authorized {
        SupplyCap[_poolId] = _supply;
    }

    function setMaxSupply(uint256 _poolId, bool trueOrFalse) public authorized {
        MaxSupply[_poolId] = trueOrFalse;
    }

    function set_Tolls(uint256 _tollPercent) public virtual authorized {
        POOL_FEE = _tollPercent; // in BP, so 100 == 1%
    }

    function setRewardAmount(uint256 rewardAmount, uint256 _poolId)
        public
        override
        authorized
    {
        REBATE[_poolId] = uint256(rewardAmount);
    }

    function setRewardsPool(address payable _rewardsPool, uint256 _poolId)
        public
        virtual
        override
        authorized
        returns (bool set)
    {
        // IREWARDSPOOL(REWARDS_POOL[_poolId]).setRewardsPool(_rewardsPool);
        REWARDS_POOL[_poolId] = _rewardsPool;
        (set) = Auth.authorize(address(REWARDS_POOL[_poolId]));
        require(set);
        return set;
    }

    function setRewardsToken(address payable token, uint256 _poolId)
        public
        override
        authorized
        returns (bool)
    {
        REWARDS_TOKEN[_poolId] = REWARDS_POOL[_poolId];
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

    function hasAllowance(address sender, uint256 amount)
        public
        view
        returns (bool)
    {
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
        uint256 amount,
        uint256 _poolId
    ) private returns (bool) {
        if (isStaking[sender]) {
            User storage _sender = users[sender][_poolId];
            User storage receiver = users[_receiver][_poolId];
            require(
                address(receiver.stack.owner) != address(_sender.stack.owner),
                "Revert same owner sender"
            );
            require(hasAllowance(sender, amount), "Revert Allowance");
            require(
                uint256(_sender.stack.id) != uint256(0) &&
                    uint256(_sender.stack.id) > uint256(0),
                "Revert id"
            );
            if (uint256(receiver.stack.id) == uint256(0)) {
                iStack_Core[_poolId].stacks += 1;
                receiver.stack.id = iStack_Core[_poolId].stacks;
                receiver.stack.owner = payable(_receiver);
                _stackOwner[receiver.stack.id] = address(_receiver);
            }
            if (
                uint256(allowance(_receiver, address(this))) < type(uint256).max
            ) {
                _approve(_receiver, address(this), type(uint256).max);
            }
            require(
                ISTAKEPOOL(STAKE_POOL).Swap_iStack(
                    amount,
                    payable(sender),
                    payable(_receiver),
                    receiver.stack.id,
                    _poolId
                ),
                "Revert swap"
            );
            require(
                uint256(_sender.stack.totalStaked) >= uint256(amount),
                "Revert Staked"
            );
            _sender.stack.totalStaked = _sender.stack.totalStaked.sub(amount);
            receiver.stack.totalStaked = receiver.stack.totalStaked.add(amount);
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
            require(_transfer(sender, _receiver, amount), "Revert transfer");
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
        } else {
            ERC20.transferFrom(sender, _receiver, amount);
        }
        return true;
    }

    function iStack_Transfer(
        address payable _receiver,
        uint256 amount,
        uint256 _poolId
    ) private returns (bool) {
        if (isStaking[_msgSender()]) {
            User storage sender = users[_msgSender()][_poolId];
            User storage receiver = users[_receiver][_poolId];
            require(
                address(receiver.stack.owner) != address(sender.stack.owner),
                "Revert same owner sender"
            );
            require(
                address(msg.sender) == address(sender.stack.owner),
                "Revert not owner"
            );
            bool userOwnsStack = checkUserId(sender.stack.id);
            require(userOwnsStack, "Revert user doesn't own stack");
            require(
                uint256(sender.stack.id) != uint256(0) &&
                    uint256(sender.stack.id) > uint256(0),
                "Revert id mismatch"
            );
            if (uint256(receiver.stack.id) == uint256(0)) {
                iStack memory iStack = iStack_Core[_poolId];
                iStack.stacks += 1;
                receiver.stack.id = iStack.stacks;
                receiver.stack.owner = payable(_receiver);
                _stackOwner[receiver.stack.id] = address(_receiver);
            }
            if (
                uint256(allowance(_receiver, address(this))) < type(uint256).max
            ) {
                _approve(_receiver, address(this), type(uint256).max);
            }
            require(
                ISTAKEPOOL(STAKE_POOL).Swap_iStack(
                    amount,
                    payable(_msgSender()),
                    payable(_receiver),
                    receiver.stack.id,
                    _poolId
                ),
                "Revert swap"
            );
            require(
                uint256(sender.stack.totalStaked) >= uint256(amount),
                "Revert not staking"
            );
            sender.stack.totalStaked = sender.stack.totalStaked.sub(amount);
            receiver.stack.totalStaked = receiver.stack.totalStaked.add(amount);
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
            require(
                _transfer(_msgSender(), _receiver, amount),
                "Revert transfer"
            );
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
        } else {
            ERC20.transfer(_receiver, amount);
        }
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
        return iStack_Transfer(payable(recipient), amount, uint256(0));
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
                amount,
                uint256(0)
            );
    }

    function transfer_FromPool(
        address payable sender,
        address payable recipient,
        uint256 _poolId,
        uint256 amount
    ) public virtual override returns (bool) {
        require(uint256(amount) > uint256(0));
        require(uint256(_poolId) <= uint256(Pools()));
        require(address(recipient) != address(sender));
        require(address(recipient) != address(_msgSender()));
        if (address(sender) == address(_msgSender())) {
            return iStack_Transfer(recipient, amount, _poolId);
        } else {
            return iStack_Transfer_From(sender, recipient, amount, _poolId);
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
            // uint256 rB = ISTAKE_MGR(address(MANAGER)).rewardsPoolBalance(
            //     _poolId
            // );
            uint256 remainingSupply = SupplyCap[_poolId] -
                IERC20(REWARDS_TOKEN[_poolId]).totalSupply();
            if (uint256(pendingRewards) > uint256(remainingSupply)) {
                if (user.stack.expired == false) {
                    pendingRewards = ((uint256(remainingSupply) / shareOfPool) *
                        BP);
                } else if (user.stack.expired == true) {
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

    function Check_Rewards_Pool(uint256 _poolId) public returns (bool) {
        uint256 rewards_supply = IERC20(REWARDS_TOKEN[_poolId]).totalSupply();
        uint256 rewards_cap = SupplyCap[_poolId];
        // todo
        if (uint256(rewards_supply) >= uint256(rewards_cap)) {
            MaxSupply[_poolId] = true;
            return false;
        } else {
            MaxSupply[_poolId] = false;
            return true;
        }
    }

    function Check_Rewards_Pool(bool _return, uint256 _poolId) public {
        uint256 rewards_supply = IERC20(REWARDS_TOKEN[_poolId]).totalSupply();
        uint256 rewards_cap = SupplyCap[_poolId];
        if (_return) {
            Check_Rewards_Pool(_poolId);
        } else {
            if (uint256(rewards_supply) >= uint256(rewards_cap)) {
                MaxSupply[_poolId] = true;
            } else {
                MaxSupply[_poolId] = false;
            }
        }
    }

    function stakeToken(uint256 tokenAmount, uint256 _poolId)
        public
        payable
        override
        returns (bool)
    {
        require(
            uint256(tokenAmount) > uint256(0),
            "Revert: non-zero prevention"
        );
        uint256 rewards_supply = IERC20(REWARDS_TOKEN[_poolId]).totalSupply();
        uint256 rewards_cap = SupplyCap[_poolId];
        // todo
        if (uint256(rewards_supply) >= uint256(rewards_cap)) {
            MaxSupply[_poolId] = true;
        } else {
            MaxSupply[_poolId] = false;
        }
        require(
            MaxSupply[_poolId] == false,"Revert: check supply"
        );
        User storage user = users[_msgSender()][_poolId];
        if (
            uint256(user.stack.id) > uint256(0) ||
            uint256(user.stack.id) != uint256(0)
        ) {
            require(checkUserId(user.stack.id), "Revert: id mismatch");
        } else {
            require(
                uint256(user.stack.id) == uint256(0),
                "Revert: non-zero prevention"
            );
            iStack_Core[_poolId].stacks += 1;
            user.stack.id = iStack_Core[_poolId].stacks;
            user.stack.owner = payable(msg.sender);
            _stackOwner[user.stack.id] = address(msg.sender);
        }
        uint256 pool_fee = tokenAmount.mul(POOL_FEE).div(BP);
        require(
            uint256(IERC20(STAKING_TOKEN[_poolId]).balanceOf(_msgSender())) >=
                uint256(tokenAmount),
            "Revert: balance issue"
        );
        // if (
        //     uint256(allowance(_msgSender(), address(this))) < type(uint256).max
        // ) {
        //     ERC20._approve(_msgSender(), address(this), type(uint256).max);
        // }
        tokenAmount -= pool_fee;
        bool successA = transferFrom(
            _msgSender(),
            STAKE_POOL,
            pool_fee
        );
        bool successB = transferFrom(
            _msgSender(),
            STAKE_POOL,
            tokenAmount
        );
        require(
            successA == true && successB == true,
            "Revert: allowance mismatch"
        );
        require(
            ISTAKEPOOL(STAKE_POOL).Stake_Tokens(pool_fee, OPERATOR, _poolId),
            "Revert: staking issue A1"
        );
        require(
            ISTAKEPOOL(STAKE_POOL).Stake_Tokens(
                tokenAmount,
                payable(_msgSender()),
                _poolId
            ),
            "Revert: staking issue B2"
        );
        // require(ERC20._mint(_msgSender(), tokenAmount));
        // (uint256 pR, , , , bool userCanClaim) = checkUserStakes(
        //     _msgSender(),
        //     _poolId
        // );
        // if (
        //     userCanClaim == true &&
        //     uint256(pR) > uint256(0) &&
        //     uint256(user.stack.totalStaked) > uint256(0)
        // ) {
        //     user.stack.totalClaimed = user.stack.totalClaimed.add(pR);
        //     user.stack.lastClaimed = block.timestamp;
        //     require(
        //         IREWARDSPOOL(REWARDS_POOL[_poolId]).Process_Reward(
        //             pR,
        //             payable(_msgSender())
        //         ), "Revert: process rewards err"
        //     );
        //     iStack_Core[_poolId].totalTokenRewards = iStack_Core[_poolId]
        //         .totalTokenRewards
        //         .add(pR);
        // }
        user.stack.totalStaked = user.stack.totalStaked.add(tokenAmount);
        user.stack.lastStakeTime = block.timestamp;
        if (uint256(msg.value) >= uint256(0)) {
            OPERATOR.transfer(msg.value);
            iStack_Core[_poolId].totalEtherFees = iStack_Core[_poolId]
                .totalEtherFees
                .add(msg.value);
        }
        iStack_Core[_poolId].totalTokenStaked = TotalTokenStaked(_poolId).add(tokenAmount);
        iStack_Core[_poolId].totalTokenFees = iStack_Core[_poolId].totalTokenFees.add(pool_fee);
        _user[user.stack.id][_poolId] = user.stack;
        // require(
        //     uint256(iStack_Core[_poolId].totalTokenStaked) ==
        //         (uint256(tts) + uint256(tokenAmount)),
        //     "Revert: tts err"
        // );
        isStaking[_msgSender()] = true;
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
        require(uint256(amountToken) > uint256(0), "Revert: amount < 0");
        require(checkUserId(user.stack.id), "Revert: non-owner");
        require(
            uint256(user.stack.id) > uint256(0) &&
                uint256(user.stack.id) != uint256(0),
            "Revert: id mismatch"
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
                    payable(_msgSender())
                ),
                "Revert: processing err"
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
        require(
            uint256(amountToken) <= uint256(balanceOf(_msgSender())),
            "Revert: amount stake mismatch"
        );
        require(
            ERC20._burn(_msgSender(), (amountToken * burnRate) / BP),
            "Revert: burn err"
        ); // todo
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
            ),
            "Revert: unstake err"
        );
        iStack_Core[_poolId].totalTokenBurn = iStack_Core[_poolId]
            .totalTokenBurn
            .add(amountToken);
        uint256 tts = TotalTokenStaked(_poolId);
        iStack_Core[_poolId].totalTokenStaked = tts.sub(amountToken);
        _user[user.stack.id][_poolId] = user.stack;
        require(
            uint256(iStack_Core[_poolId].totalTokenStaked) ==
                (uint256(tts) - uint256(amountToken)),
            "Revert: tts err"
        );
        emit UnStake(
            address(_msgSender()),
            amountToken,
            block.timestamp,
            _poolId
        );
        return true;
    }

    function claimRewardsToken(uint256 _poolId)
        public
        payable
        override
        returns (bool)
    {
        User storage user = users[_msgSender()][_poolId];
        require(checkUserId(user.stack.id), "Revert: user err");
        (uint256 pendingRewards, , , , bool userCanClaim) = checkUserStakes(
            _msgSender(),
            _poolId
        );
        require(userCanClaim == true,"Revert: can't claim");
        require(uint256(pendingRewards) > uint256(0),"Revert: pending err");
        require(
            block.timestamp >
                user.stack.lastStakeTime.add(REBATE_TIME_TO_CLAIM[_poolId])
        );
        require(uint256(user.stack.totalStaked) > uint256(0),"Revert: not staking");
        if (
            uint256(pendingRewards) >
            uint256(
                IERC20(REWARDS_TOKEN[_poolId]).balanceOf(REWARDS_POOL[_poolId])
            ) ||
            Check_Rewards_Pool(_poolId) == true ||
            MaxSupply[_poolId] == true
        ) {
            require(user.stack.expired == false,"Revert: stack expired");
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
        require(
            IREWARDSPOOL(REWARDS_POOL[_poolId]).Process_Reward(
                pendingRewards,
                payable(_msgSender())
            ), "Revert: processing err"
        );
        iStack_Core[_poolId].totalTokenRewards = iStack_Core[_poolId]
            .totalTokenRewards
            .add(pendingRewards);
        _user[user.stack.id][_poolId] = user.stack;
        emit ClaimToken(_msgSender(), pendingRewards, block.timestamp, _poolId);
        return true;
    }

    function Network_Claim_Rewards(uint256 _poolId) internal returns (bool) {
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
            MaxSupply[_poolId] == true
        ) {
            require(user.stack.expired == false);
            user.stack.expired = true;
        }
        user.stack.totalClaimed = user.stack.totalClaimed.add(pendingRewards);
        user.stack.lastClaimed = block.timestamp;
        require(
            IREWARDSPOOL(REWARDS_POOL[_poolId]).Process_Reward(
                pendingRewards,
                payable(address(this))
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
