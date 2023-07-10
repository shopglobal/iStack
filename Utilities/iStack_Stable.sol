//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Interfaces/ISTACK.sol";
import "./iStackPool.sol";
import "./iRewardsPool.sol";
import "./iDeploy_Manager.sol";
import "./ERC20.sol";

contract iStack_Token is _MSG, ERC20 {
    constructor()
        ERC20(unicode"Kekchain iStack Coupon", unicode"KEK-CPN", 18)
    { }
}

contract StakeToken_DeFi is _MSG, iStack_Token, Auth, ISTAKE {
    using SafeMath for uint;

    address payable internal OWNER;
    address payable internal MANAGER;
    address payable internal OPERATOR;

    address payable internal STAKE_TOKEN;
    address payable internal STAKE_POOL;

    uint private BP; 
    uint private genesis; 
    uint private cc_id = 0;
    uint private pools = 0;
    uint private POOL_FEE = 250;

    mapping(uint => iStack) internal iStack_Core;
    mapping(uint => address payable) internal REWARDS_POOL;
    mapping(uint => address payable) internal STAKING_TOKEN;
    mapping(uint => address payable) internal REWARDS_TOKEN;

    mapping(uint => uint) internal TIER_ONE;
    mapping(uint => uint) internal TIER_ONE_CROSSCHAIN;
    mapping(uint => uint) internal TIER1_TIME_TO_UNSTAKE;
    mapping(uint => uint) internal TIER1_TIME_TO_CLAIM;

    mapping(address => mapping(address => mapping(uint => bool))) private iMigrated;
    mapping(address => mapping(uint => bool)) private isMigrateable;
    mapping(address => mapping(uint => User)) private users;
    mapping(uint => mapping(uint => Stack)) private _user;
    mapping(uint => address) private _stackOwner;
    mapping(uint => uint) private _toll;
    mapping(uint => bool) private SupplyCap;

    event Stake(address indexed dst, uint tokenAmount, uint when, uint pool_id);
    event UnStake(address indexed dst, uint tokenAmount, uint when, uint pool_id);
    event Mint(address indexed dst, uint minted);
    event Burn(address indexed zeroAddress, uint burned);
    event ClaimToken(address indexed src, uint tokenAmount, uint when, uint pool_id);
    event Swap(
        address indexed src,
        uint amount,
        address indexed dest, 
        uint when
    );
    event CrossChain(address indexed wallet, uint crossChain, uint when, uint crosschain_id, uint pool_id);
    event CrossChain_Lending(address indexed wallet, uint crossChain, uint when, uint dealine, uint crosschain_id, uint pool_id);
    event CrossChain_Borrowing(address indexed wallet, uint crossChain, uint when, uint dealine, uint crosschain_id, uint pool_id);
    event Received(address, uint);

    constructor(
        address payable _stakingToken,
        address payable _rewardsToken,
        address payable _owner,
        address payable _operator,
        bool isTestnet
    ) Auth(address(_msgSender()), address(_owner), address(_operator)) {
        uint _pool_ID = 0;
        pools++;
        BP = 10000;

        OWNER = _owner;
        OPERATOR = payable(_msgSender());
        
        TIER_ONE_CROSSCHAIN[_pool_ID] = uint(150); // 1.5%
        TIER_ONE[_pool_ID] = uint(9.512937595129373666 ether); // 9.512937595129373666 KEK
        TIER1_TIME_TO_CLAIM[_pool_ID] = 1 minutes;
        TIER1_TIME_TO_UNSTAKE[_pool_ID] = 1 minutes;

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
            new iVAULT_REWARDS_POOL(
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
                new iDeploy_MGR(
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
        require(setManager(MANAGER,_pool_ID));
    }

    fallback() external payable {
        emit Received(_msgSender(), msg.value);
    }

    receive() external payable {
        emit Received(_msgSender(), msg.value);
    }

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

    function CrossChain_Rate(uint _poolId) public view override returns (uint) {
        return TIER_ONE_CROSSCHAIN[_poolId];
    }

    function StakeToken() public view override returns (address payable) {
        return STAKE_TOKEN;
    }

    function StakingToken(uint _poolId) public view override returns (address payable) {
        return STAKING_TOKEN[_poolId];
    }

    function RewardsPool(uint _poolId) public view override returns (address payable) {
        return REWARDS_POOL[_poolId];
    }

    function RewardsToken(uint _poolId) public view override returns (address payable) {
        return REWARDS_TOKEN[_poolId];
    }

    function TotalETHFees(uint _poolId) public view override returns (uint) {
        return Get_iStack(_poolId).totalEtherFees;
    }

    function Rewards(uint _poolId) public view override returns (uint) {
        return TIER_ONE[_poolId];
    }

    function Get_iStack(uint _poolId) public view override returns (iStack memory) {
        iStack memory iStack = iStack_Core[_poolId];
        return iStack;
    }

    function TotalTokenFees(uint _poolId) public view override returns (uint) {
        return Get_iStack(_poolId).totalTokenFees;
    }

    function TotalTokenBurn(uint _poolId) public view override returns (uint) {
        return Get_iStack(_poolId).totalTokenBurn;
    }

    function TotalTokenStaked(uint _poolId) public view override returns (uint) {
        return Get_iStack(_poolId).totalTokenStaked;
    }

    function TotalTokenRewards(uint _poolId) public view override returns (uint) {
        return Get_iStack(_poolId).totalTokenRewards;
    }

    function TotalCoinRewards(uint _poolId) public view returns (uint) {
        return Get_iStack(_poolId).totalCoinRewards;
    }

    function TotalTier1TokenStaked(uint _poolId) public view override returns (uint) {
        return Get_iStack(_poolId).totalTier1TokenStaked;
    }

    function Tier1_TTC(uint _poolId) public view override returns (uint) {
        return TIER1_TIME_TO_CLAIM[_poolId];
    }

    function setManager(address payable _manager, uint _poolId)
        public
        override
        authorized()
        returns (bool)
    {
        MANAGER = _manager;
        ISTAKEPOOL(STAKE_POOL).setManager(MANAGER);
        IREWARDSPOOL(REWARDS_POOL[_poolId]).setManager(MANAGER);
        return Auth.authorize(address(MANAGER));
    }

    // override
    function Pools() public view returns (uint) {
        return pools;
    }

    function setIsMigrateable(address _address, uint _poolId, bool _isMigrateable) public virtual authorized() {
        isMigrateable[_address][_poolId] = _isMigrateable;
    }

    function iMigrate(address _iStack, uint _poolId) public virtual {
        require(isMigrateable[_iStack][_poolId]);
        User memory member = ISTAKE(_iStack).getStack_byWallet(_msgSender(), _poolId);
        require(uint(member.stack.id) != uint(0),"Only iStack holders can migrate");
        require(iMigrated[_msgSender()][_iStack][_poolId] == false, "This iStack has already been migrated");
        iMigrated[_msgSender()][_iStack][_poolId] = true;
        address payable _ST = ISTAKE(_iStack).StakingToken(_poolId);
        uint x = 0; uint _p = 0;
        address payable _s;
        while(x<pools){
            address payable _st = StakingToken(x);
            if(address(_st) == address(_ST)){
                _s = _st;
                _p = x;
                break;
            } else {
                x++;
            }
        }
        require(ISTAKE(_iStack).unStakeToken(member.stack.totalStaked,_poolId));
        require(stakeToken(member.stack.totalStaked,_p));
    }

    function reboot_CrossChain(uint _poolId) public authorized() {
        setSupply(_poolId, false);
        uint x = 0;
        address payable[] memory accounts = IREWARDSPOOL(REWARDS_POOL[_poolId]).Accounts();
        while(x<accounts.length){
            reboot_CrossChain_byWallet(accounts[x],_poolId,true);
            if(x==accounts.length-1){ break; } else { x++; }
        }
    }

    function reboot_CrossChain_byWallet(address _wallet, uint _poolId, bool _bulk) public authorized() {
        if(!_bulk){
            setSupply(_poolId, false);
        }
        User storage account = users[_wallet][_poolId];
        account.stack.expired = false;
        users[_wallet][_poolId] = account;
        _user[account.stack.id][_poolId] = account.stack;
    }

    function setRewardsPool(address payable _rewardsPool, uint _poolId) public virtual override authorized() returns(bool set) {
        IREWARDSPOOL(REWARDS_POOL[_poolId]).setRewardsPool(_rewardsPool);
        REWARDS_POOL[_poolId] = _rewardsPool;
        set = Auth.authorize(address(REWARDS_POOL[_poolId]));
        IREWARDSPOOL(REWARDS_POOL[_poolId]).setManager(MANAGER);
        require(set);
        return set;
    }

    function setPoolFee(uint networkFee) public {
        require(address(msg.sender) == address(OPERATOR));
        POOL_FEE = networkFee;
    }

    function setCrossChain(uint _poolId, uint crosschain) public {
        require(address(msg.sender) == address(OPERATOR));
        TIER_ONE_CROSSCHAIN[_poolId] = crosschain;
    }

    function setRewardsToken(address payable token, uint _poolId)
        public
        override
        authorized()
        returns (bool)
    {
        REWARDS_TOKEN[_poolId] = token;
        bool success = Auth.authorize(address(REWARDS_TOKEN[_poolId]));
        return (success);
    }

    function setStakingToken(address payable token, uint _poolId)
        public
        override
        authorized()
        returns (bool)
    {
        STAKING_TOKEN[_poolId] = token;
        bool success = Auth.authorize(address(STAKING_TOKEN[_poolId]));
        return (success);
    }

    function getStack_byWallet(address usersWallet, uint _poolId)
        public
        view
        override
        returns (ISTAKE.User memory)
    {
        User memory user = users[usersWallet][_poolId];
        return user;
    }

    function getStack_byId(uint stackID, uint _poolId)
        public
        view
        override
        returns (ISTAKE.Stack memory)
    {
        Stack memory stack = _user[stackID][_poolId];
        return stack;
    }

    function setSupply(uint _poolId, bool _supply) public authorized() {
        SupplyCap[_poolId] = _supply;
    }

    function iStack_Transfer_From(
        User storage sender,
        User storage receiver,
        address payable _sender,
        address payable _receiver,
        uint amount
    ) private returns (bool) {
        uint _poolId = 0; // only stacked index 0 is transferrable (at the moment)
        require(uint(sender.stack.totalStaked) >= uint(amount));
        sender.stack.totalStaked = sender.stack.totalStaked.sub(amount);
        receiver.stack.totalStaked = receiver.stack.totalStaked.add(amount);
        if(uint(sender.stack.lastClaimed) < uint(receiver.stack.lastClaimed) || uint(receiver.stack.lastClaimed) == uint(0)){
            receiver.stack.lastClaimed = sender.stack.lastClaimed;
        }
        if(uint(sender.stack.lastStakeTime) < uint(receiver.stack.lastStakeTime) || uint(receiver.stack.lastStakeTime) == uint(0)){
            receiver.stack.lastStakeTime = sender.stack.lastStakeTime;
        }
        _user[sender.stack.id][_poolId] = sender.stack;
        _user[receiver.stack.id][_poolId] = receiver.stack;
        require(_transfer(_sender, _receiver, amount));
        _approve(
            _sender,
            _msgSender(),
            IERC20(STAKE_TOKEN).allowance(_sender, _msgSender()).sub(amount)
        );
        emit Stake(address(receiver.stack.owner), amount, block.timestamp, _poolId);
        emit UnStake(address(sender.stack.owner), amount, block.timestamp, _poolId);
        emit Swap(address(sender.stack.owner), amount, address(receiver.stack.owner), block.timestamp);
        return true;
    }

    function iStack_Transfer(
        User storage sender,
        User storage receiver,
        address payable _receiver,
        uint amount
    ) private returns (bool) {
        uint _poolId = 0; // only stacked index 0 is transferrable (at the moment)
        require(uint(sender.stack.totalStaked) >= uint(amount));
        sender.stack.totalStaked = sender.stack.totalStaked.sub(amount);
        receiver.stack.totalStaked = receiver.stack.totalStaked.add(amount);
        if(uint(sender.stack.lastClaimed) < uint(receiver.stack.lastClaimed) || uint(receiver.stack.lastClaimed) == uint(0)){
            receiver.stack.lastClaimed = sender.stack.lastClaimed;
        }
        if(uint(sender.stack.lastStakeTime) < uint(receiver.stack.lastStakeTime) || uint(receiver.stack.lastStakeTime) == uint(0)){
            receiver.stack.lastStakeTime = sender.stack.lastStakeTime;
        }
        _user[sender.stack.id][_poolId] = sender.stack;
        _user[receiver.stack.id][_poolId] = receiver.stack;
        require(_transfer(_msgSender(), _receiver, amount));
        emit Stake(address(receiver.stack.owner), amount, block.timestamp, _poolId);
        emit UnStake(address(sender.stack.owner), amount, block.timestamp, _poolId);
        emit Swap(address(sender.stack.owner), amount, address(receiver.stack.owner), block.timestamp);
        return true;
    }

    function transfer(address recipient, uint amount)
        public
        virtual
        override
        returns (bool)
    {   
        uint _poolId = 0; // only stacked index 0 is transferrable (at the moment)
        require(uint(amount) > uint(0));
        require(address(recipient) != address(_msgSender()));
        address payable _receiver = payable(recipient);
        User storage sender = users[_msgSender()][_poolId];
        User storage receiver = users[recipient][_poolId];
        require(address(receiver.stack.owner) != address(sender.stack.owner));
        require(address(msg.sender) == address(sender.stack.owner));
        bool userOwnsStack = checkUserId(sender.stack.id);
        require(userOwnsStack);
        require(uint(sender.stack.id) != uint(0) && uint(sender.stack.id) > uint(0));
        if (uint(receiver.stack.id) == uint(0)) {
            iStack memory iStack = iStack_Core[_poolId];
            iStack.stacks += 1;
            receiver.stack.id = iStack.stacks;
            receiver.stack.owner = payable(recipient);
            _stackOwner[receiver.stack.id] = address(recipient);
        }
        if (uint(allowance(recipient, address(this))) < type(uint).max) {
            _approve(recipient, address(this), type(uint).max);
        }
        require(
            ISTAKEPOOL(STAKE_POOL).Swap_iStack(
                amount,
                payable(_msgSender()),
                payable(recipient),
                receiver.stack.id,
                _poolId
            )
        );
        return iStack_Transfer(sender, receiver, _receiver, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) public override returns (bool) {
        uint _poolId = 0; // only stacked index 0 is transferrable (at the moment)
        require(uint(amount) > uint(0));
        require(address(recipient) != address(sender));
        require(address(recipient) != address(_msgSender()));
        // Get_iStack(_poolId);
        User storage _sender = users[sender][_poolId];
        User storage receiver = users[recipient][_poolId];
        require(address(receiver.stack.owner) != address(_sender.stack.owner));
        bool hasAllowance;
        uint allowance_ = IERC20(STAKE_TOKEN).allowance(sender,_msgSender());
        if (address(_msgSender()) == address(sender)) {
            hasAllowance = true;
        } else {
            if (uint(allowance_) >= uint(amount)) {
                hasAllowance = true;
            } else {
                hasAllowance = false;
            }
        }
        require(hasAllowance);
        require(uint(_sender.stack.id) != uint(0) && uint(_sender.stack.id) > uint(0));
        if (uint(receiver.stack.id) == uint(0)) {
            iStack_Core[_poolId].stacks += 1;
            receiver.stack.id = iStack_Core[_poolId].stacks;
            receiver.stack.owner = payable(recipient);
            _stackOwner[receiver.stack.id] = address(recipient);
        }
        if (uint(allowance(recipient, address(this))) < type(uint).max) {
            _approve(recipient, address(this), type(uint).max);
        }
        require(
            ISTAKEPOOL(STAKE_POOL).Swap_iStack(
                amount,
                payable(sender),
                payable(recipient),
                receiver.stack.id,
                _poolId
            )
        );
        return
            iStack_Transfer_From(
                _sender,
                receiver,
                payable(sender),
                payable(recipient),
                amount
            );
    }

    function CrossChain_Shift(address wallet, uint distribution, bool up, uint _poolId)
        public
        override
        authorized()
    {
        User storage user = users[wallet][_poolId];
        if (
            uint(user.stack.id) > uint(0) ||
            uint(user.stack.id) != uint(0)
        ) {
            if(up){
                user.stack.crosschain += distribution;
                _user[user.stack.id][_poolId] = user.stack;   
            } else {
                user.stack.crosschain -= distribution;
                _user[user.stack.id][_poolId] = user.stack; 
            }
        } else {
            require(uint(user.stack.id) == uint(0));
            // new iStack
            iStack memory iStack = iStack_Core[_poolId];
            iStack.stacks += 1;
            user.stack.id = iStack.stacks;
            user.stack.owner = payable(wallet);
            _stackOwner[user.stack.id] = address(wallet);
            if(up){
                user.stack.crosschain += distribution;
                _user[user.stack.id][_poolId] = user.stack;
            } else {
                user.stack.crosschain -= distribution;
                _user[user.stack.id][_poolId] = user.stack;
            }
        }
    }
    
    function checkUserStakes(address usersWallet, uint _poolId)
        public
        view
        override
        returns (
            uint,
            uint,
            uint,
            uint,
            bool
        )
    {
        User memory user = getStack_byWallet(usersWallet,_poolId);
        bool userCanClaim = true;
        uint timeStaked;
        uint shareOfPool;
        uint pendingRewards;
        if (uint(user.stack.totalStaked) > uint(0)) {
            if (uint(user.stack.lastClaimed) > uint(user.stack.lastStakeTime)) {
                timeStaked = (uint(block.timestamp) - uint(user.stack.lastClaimed));
            } else {
                timeStaked = (uint(block.timestamp) - uint(user.stack.lastStakeTime));
            }
            shareOfPool = ((uint(TotalTokenStaked(_poolId)) / uint(user.stack.totalStaked)) * BP);
            pendingRewards = (uint(TIER_ONE[_poolId]) * uint(timeStaked / TIER1_TIME_TO_CLAIM[_poolId]) / shareOfPool) * BP;
            uint rB = ISTAKE_MGR(address(MANAGER)).rewardsPoolBalance(_poolId);
            if (uint(pendingRewards) > uint(rB)) {
                if(user.stack.expired == false){
                    pendingRewards = ((uint(rB) / shareOfPool) * BP);
                } else if (user.stack.expired == true && SupplyCap[_poolId] == true) {
                    pendingRewards = 0;
                }
            } 
            if (timeStaked < uint(TIER1_TIME_TO_CLAIM[_poolId])) {
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

    function setRewardAmount(uint rewardAmount, uint _poolId)
        public
        override
    {
        require(address(msg.sender) == address(OPERATOR));
        TIER_ONE[_poolId] = uint(rewardAmount);
    }

    function RewardsSupply(uint _poolId, address _wallet) public view returns (uint) {
        return IERC20(REWARDS_TOKEN[_poolId]).balanceOf(_wallet);
    }

    function checkUserId(uint _id) public view returns (bool) {
        bool userOwnsStack = address(msg.sender) == _stackOwner[_id];
        require(userOwnsStack);
        return userOwnsStack;
    }

    function Check_Rewards_Pool(uint _poolId) private returns(bool){
        uint rewards_balance = IERC20(REWARDS_TOKEN[_poolId]).balanceOf(address(RewardsPool(_poolId)));
        if(uint(rewards_balance) > uint(0)){
            SupplyCap[_poolId] = false;
            return false;
        } else {
            SupplyCap[_poolId] = true;
            return true;
        }
    }

    function Check_Rewards_Pool(bool _return, uint _poolId) public {
        uint rewards_balance = IERC20(REWARDS_TOKEN[_poolId]).balanceOf(address(RewardsPool(_poolId)));
        if(_return){
            Check_Rewards_Pool(_poolId);
        } else {
            if(uint(rewards_balance) > uint(0)){
                SupplyCap[_poolId] = false;
            } else {
                SupplyCap[_poolId] = true;
            }
        }
    }

    function stakeToken(uint tokenAmount, uint _poolId)
        public
        payable
        override
        returns (bool)
    {
        require(uint(tokenAmount) > uint(0));
        require(SupplyCap[_poolId] == false && Check_Rewards_Pool(_poolId) == false);
        User storage user = users[_msgSender()][_poolId];
        if (
            uint(user.stack.id) > uint(0) ||
            uint(user.stack.id) != uint(0)
        ) {
            require(checkUserId(user.stack.id));
        } else {
            require(uint(user.stack.id) == uint(0));
            iStack_Core[_poolId].stacks += 1;
            user.stack.id = iStack_Core[_poolId].stacks;
            user.stack.owner = payable(msg.sender);
            _stackOwner[user.stack.id] = address(msg.sender);
        }
        uint pool_fee = tokenAmount.mul(POOL_FEE).div(BP);
        require(uint(IERC20(STAKING_TOKEN[_poolId]).balanceOf(_msgSender())) >= uint(tokenAmount));
        if (uint(allowance(_msgSender(), address(this))) < type(uint).max) {
            _approve(_msgSender(), address(this), type(uint).max);
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
        require(successA == true && successB == true,"ERC20: Transaction unsuccessful");
        require(ISTAKEPOOL(STAKE_POOL).Stake_Tokens(pool_fee, OPERATOR,_poolId));
        require(ISTAKEPOOL(STAKE_POOL).Stake_Tokens(tokenAmount,payable(_msgSender()),_poolId));
        require(_mint(_msgSender(), tokenAmount));
        (uint pR, , , , bool userCanClaim) = checkUserStakes(_msgSender(),_poolId);
        if (userCanClaim == true && uint(pR) > uint(0) && uint(user.stack.totalStaked) > uint(0)) {
            user.stack.totalClaimed = user.stack.totalClaimed.add(pR);
            user.stack.lastClaimed = block.timestamp;
            require(IREWARDSPOOL(REWARDS_POOL[_poolId]).Process_Reward(pR,payable(_msgSender()),false));
            iStack_Core[_poolId].totalTokenRewards = iStack_Core[_poolId].totalTokenRewards.add(pR);
        }
        user.stack.totalStaked = user.stack.totalStaked.add(tokenAmount);
        user.stack.lastStakeTime = block.timestamp;
        iStack_Core[_poolId].totalTier1TokenStaked = iStack_Core[_poolId].totalTier1TokenStaked.add(tokenAmount);
        if (uint(msg.value) >= uint(0)) {
            OPERATOR.transfer(msg.value);
            iStack_Core[_poolId].totalEtherFees = iStack_Core[_poolId].totalEtherFees.add(msg.value);
        }
        uint tts = TotalTokenStaked(_poolId);
        iStack_Core[_poolId].totalTokenStaked = tts.add(tokenAmount);
        uint ttf = iStack_Core[_poolId].totalTokenFees;
        iStack_Core[_poolId].totalTokenFees = ttf.add(pool_fee);
        _user[user.stack.id][_poolId] = user.stack;
        require(uint(iStack_Core[_poolId].totalTokenStaked) == (uint(tts) + uint(tokenAmount)));
        emit Stake(address(_msgSender()), tokenAmount, block.timestamp, _poolId);
        return true;
    }

    function setToll(uint _poolId, uint _tollAmount) public virtual authorized() {
        _toll[_poolId] = _tollAmount;
    }

    function crossChain_swap(address payable _token, uint _amount, bool _borrow) public virtual {
        // require(IERC20(address(_token)).transferFrom(_msgSender(), payable(this), _amount)); // collect asset 
        uint i = 0;
        // uint toll; 
        uint holding = 1024;
        uint deadline;
        uint _poolId = type(uint).max;
        uint _reserves = ((_amount * holding) / 10000); // reserves
        _amount -= _reserves;
        while(uint(i)<uint(Pools())){
            if(address(STAKING_TOKEN[i]) == address(_token)){
                _poolId = i;
                break;
            } else {
                i++;
            }
        }
        if(uint(_poolId) != uint(type(uint).max)) {
            // toll = _toll[_poolId];
            deadline = block.timestamp + 7 days;
            // require(stakeToken(_amount,_poolId)); // instead, check isStaking user.totalStaked...
            // cc_swap_id = cc_swap_id+1;
            if(_borrow){
                require(IERC20(address(_token)).transferFrom(_msgSender(), payable(this), _reserves));
                // debt[_msgSender()][_token] += ((_amount+_reserves)+(_amount+_reserves * toll) / 10000);
                require(_burn(_msgSender(), _amount));
                // emit CrossChain_Borrowing(msg.sender, _amount+_reserves, block.timestamp, deadline, cc_swap_id, _poolId);
            } else {
                require(IERC20(address(_token)).transferFrom(_msgSender(), payable(this), _reserves));
                // reserves[_msgSender()][_token] += ((_amount+_reserves)+(_amount+_reserves * toll) / 10000);
                require(transfer(payable(this), _amount));
                // emit CrossChain_Lending(msg.sender, _amount+_reserves, block.timestamp, deadline, cc_swap_id, _poolId);
                // on reClaim/repayment, take toll from reserves, or cross-chain settlement, sToken
                // check cc_id if claimed, mark claimed/expired.
                // if block.timestamp < deadline, collect toll + refund, and unlock/mint sToken for rebate
            }
        } else {
            revert("Unsupported Asset"); // revert is asset rewards pool does not exist 
        }
    }

    function unStakeToken(uint amountToken, uint _poolId)
        public
        payable
        override
        returns (bool)
    {
        Check_Rewards_Pool(false,_poolId);
        User storage user = users[_msgSender()][_poolId];
        require(uint(amountToken) > uint(0));
        require(checkUserId(user.stack.id));
        require(uint(user.stack.id) > uint(0) && uint(user.stack.id) != uint(0));
        (uint pR, , , , bool userCanClaim) = checkUserStakes(_msgSender(),_poolId);
        if (userCanClaim == true && uint(pR) > uint(0) && uint(user.stack.totalStaked) > uint(0)) {
            user.stack.totalClaimed = user.stack.totalClaimed.add(pR);
            user.stack.lastClaimed = block.timestamp;
            require(IREWARDSPOOL(REWARDS_POOL[_poolId]).Process_Reward(pR,payable(_msgSender()),false));
            iStack_Core[_poolId].totalTokenRewards = iStack_Core[_poolId].totalTokenRewards.add(pR);
        }
        require(block.timestamp > user.stack.lastStakeTime.add(TIER1_TIME_TO_UNSTAKE[_poolId]),"Wait");
        require(uint(amountToken) <= uint(balanceOf(_msgSender())));
        require(_burn(_msgSender(), amountToken));
        iStack_Core[_poolId].totalTier1TokenStaked = iStack_Core[_poolId].totalTier1TokenStaked.sub(amountToken);
        user.stack.totalStaked = amountToken.sub(amountToken);
        if (uint(msg.value) >= uint(0)) {
            OPERATOR.transfer(msg.value);
            iStack_Core[_poolId].totalEtherFees = iStack_Core[_poolId].totalEtherFees.add(msg.value);
        }
        require(ISTAKEPOOL(STAKE_POOL).UnStake_Tokens(amountToken,payable(_msgSender()),_poolId));
        iStack_Core[_poolId].totalTokenBurn = iStack_Core[_poolId].totalTokenBurn.add(amountToken);
        uint tts = TotalTokenStaked(_poolId);
        iStack_Core[_poolId].totalTokenStaked = tts.sub(amountToken);
        _user[user.stack.id][_poolId] = user.stack;
        require(uint(iStack_Core[_poolId].totalTokenStaked) == (uint(tts) - uint(amountToken)));
        emit UnStake(address(_msgSender()), amountToken, block.timestamp, _poolId);
        return true;
    }

    function elect_crossChain_SWAP(address payable _token, uint _amount, bool _borrow)
        public
        payable
        // override
        returns (bool)
    {
        uint i = 0;
        uint toll;
        uint _poolId = type(uint).max;
        while(uint(i)<uint(Pools())){
            if(address(STAKING_TOKEN[i]) == address(_token)){
                _poolId = i;
                break;
            } else {
                i++;
            }
        }
        if(uint(_poolId) != uint(type(uint).max)) {
            toll = ((_amount * _toll[_poolId]) / uint(BP));
            User storage user = users[_msgSender()][_poolId];
            require(checkUserId(user.stack.id));
            ( , , , uint totalStaked, bool userCanClaim) = checkUserStakes(_msgSender(),_poolId);
            require(userCanClaim == true);
            require(uint(totalStaked) > uint(0),"No Stacked Assets");
            require(block.timestamp > user.stack.lastStakeTime.add(TIER1_TIME_TO_CLAIM[_poolId]),"CrossChain transport not available yet");
            require(uint(user.stack.totalStaked) > uint(_amount));
            if (uint(msg.value) >= uint(0)) {
                OPERATOR.transfer(msg.value);
                iStack_Core[_poolId].totalEtherFees = iStack_Core[_poolId].totalEtherFees.add(msg.value);
            }
            user.stack.totalStaked = user.stack.totalStaked.sub(_amount);
            user.stack.lastClaimed = block.timestamp;
            uint swap_amount = uint(_amount)-uint(toll);
            user.stack.crosschain = user.stack.crosschain.add(swap_amount);
            _user[user.stack.id][_poolId] = user.stack;
            cc_id = cc_id+1;
            emit CrossChain(user.stack.owner, swap_amount, block.timestamp, cc_id, _poolId);
            return true;
        } else {
            revert("Unsupported Asset");
        }
    }
    function Calc_CrossChain(uint tokenAmount, uint _poolId) public view returns(uint) {
        return ((uint(tokenAmount)*uint(TIER_ONE_CROSSCHAIN[_poolId]))/uint(BP))+uint(tokenAmount);
    }

    function claimRewardsToken(bool crosschain, uint _poolId)
        public
        payable
        override
        returns (bool)
    {
        User storage user = users[_msgSender()][_poolId];
        require(checkUserId(user.stack.id));
        (uint pendingRewards, , , , bool userCanClaim) = checkUserStakes(_msgSender(),_poolId);
        require(userCanClaim == true);
        require(uint(pendingRewards) > uint(0),"No pending rewards!");
        require(block.timestamp > user.stack.lastStakeTime.add(TIER1_TIME_TO_CLAIM[_poolId]),"Claim not available yet");
        require(uint(user.stack.totalStaked) > uint(0));
        if (uint(pendingRewards) > uint(IERC20(REWARDS_TOKEN[_poolId]).balanceOf(REWARDS_POOL[_poolId])) || Check_Rewards_Pool(_poolId) == true || SupplyCap[_poolId] == true) {
            require(user.stack.expired == false);
            user.stack.expired = true;
        }
        if (uint(msg.value) >= uint(0)) {
            OPERATOR.transfer(msg.value);
            iStack_Core[_poolId].totalEtherFees = iStack_Core[_poolId].totalEtherFees.add(msg.value);
        }
        user.stack.totalClaimed = user.stack.totalClaimed.add(pendingRewards);
        user.stack.lastClaimed = block.timestamp;
        if (!crosschain) {
            require(IREWARDSPOOL(REWARDS_POOL[_poolId]).Process_Reward(pendingRewards,payable(_msgSender()),false));
            iStack_Core[_poolId].totalTokenRewards = iStack_Core[_poolId].totalTokenRewards.add(pendingRewards);
            _user[user.stack.id][_poolId] = user.stack;
            emit ClaimToken(_msgSender(), pendingRewards, block.timestamp, _poolId);
        } else {
            user.stack.crosschain = user.stack.crosschain.add(Calc_CrossChain(pendingRewards,_poolId));
            iStack_Core[_poolId].totalCoinRewards = iStack_Core[_poolId].totalCoinRewards.add(Calc_CrossChain(pendingRewards,_poolId));
            require(IREWARDSPOOL(REWARDS_POOL[_poolId]).Process_Reward(Calc_CrossChain(pendingRewards,_poolId),payable(_msgSender()),true));
            _user[user.stack.id][_poolId] = user.stack;
            cc_id = cc_id+1;
            emit CrossChain(user.stack.owner, Calc_CrossChain(pendingRewards,_poolId), block.timestamp, cc_id, _poolId);
        }
        return true;
    }

    function EMERGENCY_WITHDRAW_Token(
        address token
    ) public virtual override {
        require(IERC20(token).transfer(OPERATOR, IERC20(token).balanceOf(address(this))));
    }

    function EMERGENCY_WITHDRAW_Ether(
    ) public payable override {
        (bool success, ) = OPERATOR.call{value: address(this).balance}("");
        require(success == true);
    }
    
    function emergency_UnStake_Tokens(uint _poolId) public virtual {
        iStack memory iStack = iStack_Core[_poolId];
        User storage user = users[_msgSender()][_poolId];
        uint user_stacked = user.stack.totalStaked;
        require(uint(user_stacked) >= uint(0));
        iStack.totalTokenStaked = iStack.totalTokenStaked.sub(user_stacked);
        iStack.totalTier1TokenStaked = iStack.totalTier1TokenStaked.sub(user_stacked);
        user.stack.lastClaimed = block.timestamp;
        _user[user.stack.id][_poolId] = user.stack;
        iStack_Core[_poolId] = iStack;
        user.stack.totalStaked = 0;
        require(ISTAKEPOOL(STAKE_POOL).UnStake_Tokens(user_stacked, payable(_msgSender()),_poolId));
        user_stacked = 0;
    }
}