//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IWWW_WEB3 {
    struct iWWW {
        uint256 id;
        iMsg messages;
        iTopic topics;
        iComment comments;
    }
    struct iTopic {
        uint256 id;
        string header;
        string[] topic;
    }
    struct iComment {
        uint256 id;
        string[] comment;
        uint256 topic_id;
        uint256 comment_id;
        address payable poster;
    }
    struct iMsg {
        uint256 id;
        string subject;
        string[] message;
        address payable iVault;
        address payable sender;
        address payable receiver;
        address payable[] _allowed;
        address payable[] _rejected;
    }
    struct iWeb3 {
        uint256 id;
        iWWW website;
        iTopic topics;
        iMsg messages;
        iComment comments;
    }
    // iEx.website.id  
    // iTopic iEx.website.topic.topic = "topic"
    // iMsg iEx.website.message.message = "message"
    // iMsg iEx.website.message._allowed.push(allowedList) || iEx.website.message._rejected.push(blockedList)
    // iComment iEx.website.comment.comment = "comment"

    function EMERGENCY_WITHDRAW_Ether() external payable;
    function EMERGENCY_WITHDRAW_Token(address token) external;
}
