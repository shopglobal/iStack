// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
//                          (#####################*                            
//                    ,#######,                ./#######                       
//                 #####*     /##*          .(((,     (#####                   
//              ####(     .#(    /*/##* (#( (     ##      ####(                
//           *###(       /##,.*,   #(    .#*   ** ###        ####              
//         ,###.         #/ . /#/ ,   ##*     /#  # #/         ####            
//        ###/           #*#,  .,(#/**   # *#/.  .(#/#           ###(          
//      ,###           ,#,   ./. #*     .   #*.#,    ##            ###         
//     *###           ##                              ,##           ###        
//    .###          /#   ,#((((//////////((((((((###(.  (#           ###       
//    ###           #*            .,*******,.         (/ ##          ,###      
//   *##/           (## * (########################(, .,##            ###      
//   ###              ###                            ,##(             /##*     
//   ###                (#############################.               *##/     
//   ###.                 .((. ..             .,/###                  (##*     
//   *##(             ####/......,,,,,,,,,,.........*###*             ###      
//    ###         ####                                  ,###(        ,###      
//     ###     ##                    ..                       #(     ###       
//     ,###         /(##############################(####(,         ###        
//      ,###       ######        (       .         .  #####/      ###              
//        ###           (#######*.             ./#######*       ###             
//         ###               (###################*            ###

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
contract FREN_Share {
    
    string public name = unicode"frenShare☦🔒";
    string public symbol = unicode"frenShare☦🔑";

    uint BP = 10000;
    uint teamDonationMultiplier;
    
    address payable private _development = payable(0x417274F1bB40e7B9d761ac56D05b6b7fc19eA623);
    address payable private _operations = payable(0xd166dF9DFB917C3B960673e2F420F928d45C9be1);

    event Withdrawal( uint wad);
    event WithdrawToken(address indexed token, uint wad);
 
    constructor() payable { teamDonationMultiplier = 9000; }

    receive() external payable { }
    
    fallback() external payable { }

    function split(uint liquidity) public view returns(uint,uint,uint) {
        assert(uint(liquidity) > uint(0));
        uint communityLiquidity = (liquidity * teamDonationMultiplier) / BP;
        uint developmentLiquidity = (liquidity - communityLiquidity);
        uint totalSumOfLiquidity = communityLiquidity+developmentLiquidity;
        assert(uint(totalSumOfLiquidity)==uint(liquidity));
        return (totalSumOfLiquidity,communityLiquidity,developmentLiquidity);
    }

    function withdraw_ETH_v1() external virtual {
        (uint sumOfLiquidityWithdrawn,uint cliq, uint dliq) = split(address(this).balance);
        _operations.transfer(cliq);
        _development.transfer(dliq);
        emit Withdrawal(sumOfLiquidityWithdrawn);
    }

    function withdraw_ETH_v2() external virtual {
        (uint sumOfLiquidityWithdrawn,uint cliq, uint dliq) = split(address(this).balance);
        (bool successA,) = _operations.call{value: cliq}("");
        (bool successB,) = _development.call{value: dliq}("");
        require(successA == true,"Transaction failed");
        require(successB == true,"Transaction failed");
        emit Withdrawal(sumOfLiquidityWithdrawn);
    }

    function withdrawToken(address token) public virtual {
        (,uint cliq, uint dliq) = split(IERC20(token).balanceOf(address(this)));
        uint sumOfLiquidityWithdrawn = uint(cliq)+uint(dliq);
        require(IERC20(token).transfer(_operations, cliq));
        require(IERC20(token).transfer(_development, dliq));
        emit WithdrawToken(address(token), sumOfLiquidityWithdrawn);
    }

    function change_Operations(address payable _wallet) public virtual {
        require(address(msg.sender)<=address(_operations),"!AUTHORIZED");
        _operations = _wallet;
    }

    function change_Development(address payable _wallet) public virtual {
        require(address(msg.sender)<=address(_development),"!AUTHORIZED");
        _development = _wallet;
    }

    function adjust_Team_Distribution(uint amount) public virtual {
        require(address(msg.sender)<=address(_operations),"!AUTHORIZED");
        require(uint(amount)<=uint(9000));
        teamDonationMultiplier = amount;
    }
}
