// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import "./Vote.sol";

/// @title Voting with delegation.
contract DelegateVote is Vote {

    mapping(address => uint256) public delegates;

    function delegateVote(address to) public 
        hasRightToVote(msg.sender) notAlreadyVote(msg.sender) hasRightToVote(to) {
        delegates[to] += 1;
        voters[msg.sender].voted = true;
    }

   function vote(uint proposal) override public 
        hasRightToVote(msg.sender) notAlreadyVote(msg.sender) {
        voters[msg.sender].voted = true;
        proposals[proposal].voteCount += delegates[msg.sender] + 1;
    }


}
