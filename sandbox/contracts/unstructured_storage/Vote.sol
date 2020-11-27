// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

/// @title Voting without delegation.
contract Vote {

    struct Voter {
        bool hasRightToVote;
        bool voted;  
    }


    struct Proposal {
        bytes32 name;
        uint voteCount;
    }

    address public chairperson;


    mapping(address => Voter) public voters;

    Proposal[] public proposals;

    function initialize(bytes32[] memory proposalNames) virtual public {
        chairperson = msg.sender;
        require(proposalNames.length > 1, "Provide candidates");
        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }


    function giveRightToVote(address voter) public {

        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
         require(
            !voters[voter].hasRightToVote,
            "The voter has already right to vote."
        );       
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        voters[voter].hasRightToVote = true;
    }

    modifier hasRightToVote(address user) {
        require(voters[user].hasRightToVote, "Do not have right to vote.");
        _;
    }

    modifier notAlreadyVote(address user) {
       require(!voters[user].voted, "Already voted.");
       _;
    }

    function vote(uint proposal) virtual public 
        hasRightToVote(msg.sender) notAlreadyVote(msg.sender) {
        voters[msg.sender].voted = true;
        proposals[proposal].voteCount += 1;
    }

    function winningProposal() public view
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    function winnerName() public view
            returns (bytes32 winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }
}
