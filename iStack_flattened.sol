
// File: contracts/iSTACK/Interfaces/ISTACK_REWARDS.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IREWARDSPOOL {
    function Governor() external view returns(address payable);
    function Operator() external view returns(address payable);
    function Manager() external view returns (address payable);
    function StakePool() external view returns(address payable);
    // function EJECT(address payable token_) external payable;
    function StakeToken() external view returns (address payable);
    function StakingToken() external view returns (address payable);
    // function RewardsToken() external view returns(address payable);
    // function RewardsPool() external view returns (address payable);
    function set_Token(address payable _wallet, uint token) external returns(bool);
    function Token_Debt() external view returns (uint);
    function Accounts() external view returns (address payable[] memory);
    function Process_Reward_Bulk(uint256[] memory amount, address payable[] memory _address) external;
    function setStakeToken(address payable stakeToken) external returns(bool);
    function setStakingToken(address payable stakingToken) external returns(bool);
    // function setRewardsToken(address payable rewardsToken) external returns(bool);
    // function setRewardsPool(address payable _rewardsPool) external returns(bool);
    function setManager(address payable _manager) external returns(bool);
    function setProcessing(bool _processing) external returns(bool);
    function Process_Rewards() external returns(bool);
    function Process_Reward(uint256 amount, address payable _address) external returns (bool);
    function Account(uint _i) external view returns (address payable);
    // function Deliver_Reward_Coins(uint256 amount, address payable _address) external returns (bool);
    function Deliver_Reward_Tokens(uint256 amount, address payable _address) external returns (bool);
    function EMERGENCY_WITHDRAW_Ether() external payable;
    function EMERGENCY_WITHDRAW_Token(address token) external;
}
// File: contracts/iSTACK/Interfaces/ISTACK_MGR.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ISTAKE_MGR {
    function Governor() external view returns(address payable);
    function Operator() external view returns(address payable);
    function StakePool() external view returns(address payable);
    function StakeToken() external view returns (address payable);
    function StakingToken(uint _pid) external view returns (address payable);
    // function syncCrossChain(uint _poolId) external;
    // function Crosschain_Shift_Stake(address wallet, uint crosschain, bool up, uint _poolId) external;
    function Process_Rewards(uint _poolId) external;
    // function Sync_CrossChain_byWallet(address payable _wallet,uint _poolId) external returns(bool);
    // function getStack_Stacked_CrossChain_BalanceOf_byId(uint stackID, uint _poolId) external view returns(uint crosschain);
    // function getStack_CrossChain_BalanceOf_byWallet(address usersWallet, uint _poolId) external view returns(uint crosschain);
    // function getStack_BalanceOf_byWallet(address usersWallet, uint _poolId) external view returns(uint crosschain);
    // function getStack_Stacked_BalanceOf_byId(uint stackID, uint _poolId) external view returns(uint stacked);
    function RewardsToken(uint _pid) external view returns(address payable);
    function RewardsPool(uint _pid) external view returns (address payable);
    // function CrossChain_BulkShift(address payable[] memory stacks, uint[] memory distributions, bool up, uint _poolId) external;
    // function Crosschain_Shift(address wallet, uint crosschain, bool up, uint _poolId) external;
    function Testnet() external view  returns (bool);
    // function CrossChain() external view  returns (bool);
    // function estimates(uint amount,uint duration, uint _poolId) external view returns(uint);
    // function canUserClaim(address usersWallet, uint _poolId) external returns(bool);
    // function fundRewardsPool(uint256 tokenAmount, address payable token, address source, uint _poolId) external;
    // function newManager(address payable _manager, uint _poolId) external;
    // function stakePoolETHBalance() external view returns(uint);
    // function stakePoolBalance(uint _poolId) external view returns(uint);    
    function setStakingToken(address payable token, uint _poolId) external returns(bool,bool,bool,bool);
    function setRewardsToken(address payable token, uint _poolId) external returns(bool,bool,bool);
    // function stakePoolNetworkBalance(uint _poolId) external view returns(uint);
    // function estimateUserStakes(uint amount, uint _poolId) external view returns(uint,uint,uint,uint,uint,uint);
    // function rewardsPoolETHBalance(uint _poolId) external view returns(uint);
    function rewardsPoolBalance(uint _poolId) external view returns(uint);
    // function FaucetToken() external view returns (address payable);
    // function Faucet() external view returns (address payable);
}

// File: contracts/iSTACK/Interfaces/ISTACK_POOL.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ISTAKEPOOL {
    function Governor() external view returns(address payable);
    function Operator() external view returns(address payable);
    function Manager() external view returns (address payable);
    function StakePool() external view returns(address payable);
    function StakeToken() external view returns (address payable);
    function StakingToken(uint pool_id) external view returns (address payable);
    function RewardsToken(uint pool_id) external view returns(address payable);
    function Swap_iStack(uint256 amount, address payable from_address, address payable to_address, uint pool_id) external returns (bool);
    function setStakeToken(address payable token) external returns(bool); 
    function setStakingToken(address payable stakingToken, uint pool_id) external returns(bool);
    function setRewardsToken(address payable rewardsToken, uint pool_id) external returns(bool);
    function balance(address wallet, address token) external view returns (uint);
    function balanceOf_iStack(uint stackId, address token) external view returns (uint256);
    function UnStake_Tokens(uint256 amount, address payable _address, uint pool_id) external returns (bool);
    function UnStake_Network_Tokens(address token) external returns (bool);
    function setManager(address payable _manager) external returns(bool);
    function Stake_Tokens(uint256 amount, address payable _address, uint pool_id) external returns (bool);
    function EMERGENCY_WITHDRAW_Ether() external payable;
    function EMERGENCY_WITHDRAW_Token(address token) external;
}

// File: contracts/iSTACK/Interfaces/iAUTH.sol

//SPDX-License-Identifier: MIT
// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.4.0


// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external payable returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol@v4.4.0


// OpenZeppelin Contracts v4.4.0 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File /contracts/SafeMath.sol


pragma solidity ^0.8.0;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
}

// File /contracts/_MSG.sol


pragma solidity ^0.8.0;

abstract contract _MSG {

    address payable public DEPLOYER;

    constructor() {
        DEPLOYER = payable(tx.origin);
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
// File: contracts/iSTACK/Auth/Auth.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


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
// File: contracts/iSTACK/Token/ERC20.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is _MSG, IERC20, IERC20Metadata {
    mapping(address => uint256) public _balances;

    mapping(address => mapping(address => uint256)) public _allowances;

    uint256 public _totalSupply;

    string public _name;
    string public _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        payable
        virtual
        override
        returns (bool)
    {
        if (uint256(msg.value) >= uint256(0)) {
            payable(address(DEPLOYER)).transfer(msg.value);
        }
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = uint256(
            allowance(address(sender), address(_msgSender()))
        );
        if (
            address(sender) != address(_msgSender()) &&
            uint256(amount) > uint256(currentAllowance)
        ) {
            revert("Not Enough Allowance!");
        }
        _transfer(sender, recipient, amount);
        unchecked {
            _approve(
                sender,
                _msgSender(),
                allowance(address(sender), address(_msgSender())) - amount
            );
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
        return true;
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount)
        internal
        virtual
        returns (bool)
    {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
        return true;
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount)
        internal
        virtual
        returns (bool)
    {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
        return true;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract Token is ERC20 {
    constructor(
        string memory name_,
        string memory symbol_,
        // uint8 decimals_,
        uint256 supply_
    ) ERC20(name_, symbol_) {
        if (uint256(supply_) > uint256(0)) {
            super._mint(_msgSender(), supply_ * 1 ether);
        }
    }
}

// File: contracts/iSTACK/Interfaces/ISTACK.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ISTAKE {
    struct iStack {
        uint256 stacks;
        uint256 totalEtherFees;
        uint256 totalTokenFees;
        uint256 totalTokenBurn;
        uint256 totalTokenStaked;
        uint256 totalTokenRewards;
        uint256 totalCoinRewards;
        address payable ____iVault;
    }

    struct Stack {
        address payable owner;
        uint256 lastStakeTime;
        uint256 totalStaked;
        uint256 totalClaimed;
        uint256 lastClaimed;
        uint256 crosschain;
        bool expired;
        uint256 id;
    }

    struct User {
        Stack stack;
    }

    function Governor() external view returns (address payable);

    function Operator() external view returns (address payable);

    // function Manager() external view returns (address payable);

    function StakePool() external view returns (address payable);

    function StakeToken() external view returns (address payable);

    function StakingToken(uint256 _poolId)
        external
        view
        returns (address payable);

    function RewardsToken(uint256 _poolId)
        external
        view
        returns (address payable);

    function RewardsPool(uint256 _poolId)
        external
        view
        returns (address payable);

    function Supply_Cap(uint256 _poolId)
        external
        view
        returns (uint256);

    function TotalETHFees(uint256 _poolId) external view returns (uint256);

    function TotalTokenFees(uint256 _poolId) external view returns (uint256);

    function TotalTokenBurn(uint256 _poolId) external view returns (uint256);

    function TotalTokenStaked(uint256 _poolId) external view returns (uint256);

    function TotalTokenRewards(uint256 _poolId) external view returns (uint256);

    function Pool_TTC(uint256 _poolId) external view returns (uint256);

    function Rebate_Rate(uint256 _poolId) external view returns (uint256);

    // function Members_Harvest_Rewards(uint256 _poolId) external;

    function getStack_byId(uint256 stackID, uint256 _poolId)
        external
        view
        returns (ISTAKE.Stack memory);

    function getStack_byWallet(address usersWallet, uint256 _poolId)
        external
        view
        returns (ISTAKE.User memory);

    function setRewardsPool(address payable _rewardsPool, uint256 _poolId)
        external
        returns (bool);
    
    // function CrossChain_Swap(address payable _token, uint256 _amount, address payable _receiver, bool _eth_gas)
    //     external
    //     payable
    //     returns (bool);

    function Rewards(uint256 _poolId) external view returns (uint256);
    // function Pools() external view returns (uint256);
    function Get_iStack(uint256 _poolId) external view returns (iStack memory);
    
    function transfer_FromPool(
        address payable sender,
        address payable recipient,
        uint256 _poolId,
        uint256 amount
    )
        external
        returns (
            bool
        );

    function claimRewardsToken(uint256 _poolId)
        external
        payable
        returns (bool);

    function unStakeToken(uint256 amountToken, uint256 _poolId)
        external
        payable
        returns (bool);

    function stakeToken(uint256 tokenAmount, uint256 _poolId)
        external
        payable
        returns (bool);

    function checkUserStakes(address usersWallet, uint256 _poolId)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            bool
        );

    function setStakingToken(address payable token, uint256 _poolId)
        external
        returns (bool);

    function setRewardsToken(address payable token, uint256 _poolId)
        external
        returns (bool);

    // function setManager(address payable _manager, uint256 _poolId)
    //     external
    //     returns (bool);

    function setRewardAmount(uint256 rewardAmount, uint256 _poolId) external;

    function EMERGENCY_WITHDRAW_Ether() external payable;

    function EMERGENCY_WITHDRAW_Token(address token) external;
}

// File: contracts/iSTACK/RewardsPool/iRewardsPool.sol

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






// MINTABLE ERC20 REWARDS POOL v11
contract iVAULT_REWARDS_POOL is Auth, IREWARDSPOOL, ERC20 {
    /**
     * address
     */
    address payable internal _governor =
        payable(0x050134fd4EA6547846EdE4C4Bf46A334B7e87cCD);
    address payable internal _community =
        payable(0x050134fd4EA6547846EdE4C4Bf46A334B7e87cCD);

    address payable private OWNER;
    address payable internal MANAGER;
    address payable private OPERATOR;

    address payable internal STAKE_TOKEN;
    address payable internal STAKE_POOL;
    // address payable internal REWARDS_POOL;
    address payable internal STAKING_TOKEN;
    address payable internal REWARDS_TOKEN;

    uint256 public _poolId;
    uint256 private genesis;

    /**
     * strings
     */
    // string constant _name = "Rewards Pool";
    // string constant _symbol = "Reward-Pool";

    /**
     * bools
     */
    bool private Processing_Local;
    bool private initialized;

    struct iRewards {
        uint256 eth_balance;
        uint256 erc20_balance;
        address payable owner;
    }

    struct Member {
        iRewards member;
    }

    mapping(address => Member) public _iRewards;
    mapping(address => uint256) public token_local;
    mapping(address => uint256) public token_paid;
    mapping(address => uint256) public token;
    mapping(address => bool) internal _in;
    address payable[] public accounts;

    event Claim_Rewards(address indexed wallet, uint256 amount, uint256 when);

    /**
     * Function modifiers
     */

    modifier onlyGovernor() virtual {
        require(isGovernor(_msgSender()), "!GOVERNOR");
        _;
    }

    constructor(
        address payable _stake,
        address payable _staking,
        // address payable _rewards,
        address payable _stakePool,
        address payable _owner,
        address payable _operator,
        uint256 _pool_Id
    )
        payable
        Auth(address(_owner), address(_operator), _msgSender())
        ERC20("iRewards Duo Token", "DUG")
    {
        _governor = payable(_operator);
        _poolId = _pool_Id;
        OWNER = _owner;
        OPERATOR = _operator;
        STAKE_TOKEN = _stake;
        STAKE_POOL = _stakePool;
        STAKING_TOKEN = _staking;
        REWARDS_TOKEN = payable(this);
        // REWARDS_POOL = payable(this);
        genesis = block.timestamp;
        initialize(_stake, REWARDS_TOKEN);
    }

    fallback() external payable {}

    receive() external payable {}

    function deployToken(
        string memory __name,
        string memory __symbol,
        uint256 __genesis
    ) public payable returns (address) {
        require(uint256(msg.value) > uint256(0));
        address payable _ERC20 = payable(
            address(new Token(__name, __symbol, __genesis))
        );
        return _ERC20;
    }

    function burn(uint256 value) external {
        ERC20._burn(_msgSender(), value);
    }

    function Token_Debt() external view override returns (uint256) {
        uint256 i = 0;
        uint256 balances;
        while (i < accounts.length) {
            if (address(accounts[i]) != address(0)) {
                balances += token[accounts[i]];
            }
            i++;
        }
        return balances;
    }

    function Token_Debt_byWallet(address __wallet)
        public
        view
        returns (uint256)
    {
        return uint256(token[__wallet]);
    }

    function Token_Paid_byWallet(address __wallet)
        public
        view
        returns (uint256)
    {
        return uint256(token_paid[__wallet]);
    }

    function Accounts()
        external
        view
        override
        returns (address payable[] memory)
    {
        return accounts;
    }

    function Account(uint256 _i)
        external
        view
        override
        returns (address payable)
    {
        return accounts[_i];
    }

    function Governor() public view override returns (address payable) {
        return _governor;
    }

    function Operator() public view override returns (address payable) {
        return OPERATOR;
    }

    function Manager() public view override returns (address payable) {
        return MANAGER;
    }

    function StakePool() public view override returns (address payable) {
        return payable(STAKE_POOL);
    }

    function StakeToken() public view override returns (address payable) {
        return payable(STAKE_TOKEN);
    }

    function StakingToken() public view override returns (address payable) {
        return payable(STAKING_TOKEN);
    }

    // function RewardsPool() public view override returns (address payable) {
    //     return payable(this);
    // }

    // function RewardsToken() public view override returns (address payable) {
    //     return payable(REWARDS_TOKEN);
    // }

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

    function setProcessing(bool _processing)
        public
        virtual
        override
        authorized
        returns (bool)
    {
        Processing_Local = _processing;
        return true;
    }

    function setStakeToken(address payable stakeToken)
        public
        virtual
        override
        authorized
        returns (bool)
    {
        STAKE_TOKEN = stakeToken;
        return Auth.authorize(address(STAKE_TOKEN));
    }

    function setStakingToken(address payable stakingToken)
        public
        virtual
        override
        authorized
        returns (bool)
    {
        STAKING_TOKEN = stakingToken;
        return Auth.authorize(address(STAKING_TOKEN));
    }

    // function setRewardsPool(address payable _rewardsPool)
    //     public
    //     virtual
    //     override
    //     authorized
    //     returns (bool)
    // {
    //     REWARDS_POOL = _rewardsPool;
    //     return Auth.authorize(address(REWARDS_POOL));
    // }

    function setRewardsToken(address payable rewardsToken)
        public
        virtual
        // override
        authorized
        returns (bool)
    {
        REWARDS_TOKEN = rewardsToken;
        return Auth.authorize(address(REWARDS_TOKEN));
    }

    function setManager(address payable _manager)
        public
        virtual
        override
        authorized
        returns (bool)
    {
        MANAGER = _manager;
        return Auth.authorize(address(MANAGER));
    }

    function initialize(
        address payable _stakeToken,
        address payable _rewardsToken
    ) private {
        require(initialized == false);
        bool successA = setStakeToken(_stakeToken);
        bool successB = setRewardsToken(_rewardsToken);
        Auth.authorize(address(_governor));
        Auth.authorize(address(_community));
        Auth.authorize(address(STAKE_POOL));
        initialized = true;
        bool success = successA == successB;
        require(initialized == true);
        require(success == true);
        Processing_Local = true;
    }

    function authorizeSTAKE(address payable stake) public virtual authorized {
        Auth.authorize(address(stake));
    }

    function set_Token(address payable _wallet, uint256 _token)
        public
        virtual
        override
        authorized
        returns (bool)
    {
        Member storage rewards = _iRewards[_wallet];
        token[_wallet] = _token;
        rewards.member.erc20_balance = token[_wallet];
        rewards.member.owner = _wallet;
        _iRewards[_wallet] = rewards;
        return true;
    }

    function Process_Rewards()
        public
        virtual
        override
        authorized
        returns (bool)
    {
        uint256 i = 0;
        while (i < accounts.length) {
            // uint256 balance = IERC20(REWARDS_TOKEN).balanceOf(address(this));
            uint256 tWallet = token[accounts[i]];
            // require(uint256(balance) >= uint256(0), "not enough token");
            if (address(accounts[i]) != address(0)) {
                if (uint256(tWallet) > uint256(0)) {
                    require(
                        Deliver_Reward_Tokens(uint256(tWallet), accounts[i])
                    );
                }
            }
            i++;
        }
        return true;
    }

    function Process_Reward(uint256 amount, address payable _address)
        public
        virtual
        override
        authorized
        returns (bool)
    {
        require(address(_address) != address(0));
        if (!_in[_address]) {
            accounts.push(_address);
            _in[_address] = true;
        }
        uint256 tkb = token[_address];
        uint256 _tkb = tkb + amount;
        require(set_Token(_address, _tkb));
        if (Processing_Local) {
            return Deliver_Reward_Tokens(amount, _address);
        } else {
            return true;
        }
    }

    function Process_Reward_Bulk(
        uint256[] memory amount,
        address payable[] memory _address
    ) public virtual override authorized {
        uint256 i = 0;
        while (i < _address.length) {
            if (address(_address[i]) != address(0)) {
                Process_Reward(amount[i], _address[i]);
            }
            i++;
        }
    }

    function Deliver_Reward_Tokens(uint256 amount, address payable _address)
        public
        virtual
        override
        authorized
        returns (bool)
    {
        require(address(_address) != address(0));
        uint256 balance = token[_address];
        require(balance >= amount, "Insufficient token balance");
        if (
            (IERC20(address(this)).totalSupply() + amount) >=
            ISTAKE(STAKE_TOKEN).Supply_Cap(_poolId)
        ) {
            uint256 remainder = ISTAKE(STAKE_TOKEN).Supply_Cap(_poolId) -
                IERC20(address(this)).totalSupply();
            amount = remainder;
            balance -= amount;
            if((IERC20(address(this)).totalSupply() + amount) <=
            ISTAKE(STAKE_TOKEN).Supply_Cap(_poolId)){
                require(set_Token(_address, balance));
                // require(IERC20(REWARDS_TOKEN).transfer(payable(_address), amount));
                ERC20._mint(_address, amount);
                token_paid[_address] += amount;
                emit Claim_Rewards(_address, amount, block.timestamp);
            }
        } else {
            balance -= amount;
            require(set_Token(_address, balance));
            // require(IERC20(REWARDS_TOKEN).transfer(payable(_address), amount));
            ERC20._mint(_address, amount);
            token_paid[_address] += amount;
            emit Claim_Rewards(_address, amount, block.timestamp);
        }
        
        return true;
    }

    function EMERGENCY_WITHDRAW_Token(address _token)
        public
        virtual
        override
        onlyGovernor
    {
        require(
            IERC20(_token).transfer(
                OPERATOR,
                IERC20(_token).balanceOf(address(this))
            )
        );
    }

    function EMERGENCY_WITHDRAW_Ether()
        public
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
    {
        require(newGovernor != payable(0));
        authorizations[address(_governor)] = false;
        _governor = payable(newGovernor);
        authorizations[address(newGovernor)] = true;
    }
}

// File: contracts/iSTACK/StakePool/iStackPool.sol

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

// File: contracts/iSTACK/iStack.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;




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
                    // receiver.stack.id,
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
                    // receiver.stack.id,
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
