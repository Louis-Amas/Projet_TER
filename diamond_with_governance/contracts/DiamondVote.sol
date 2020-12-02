// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

import "./VoteToken.sol";
import "./interfaces/IDiamondCut.sol";

enum Status {Open, Accepted, Refused}

abstract contract DiamondVote {

    bytes32 constant ADVANCE_DIAMOND_STORAGE = keccak256("diamond.advancedtokenvote");

    struct AdvancedTokenVoteStorage {
        mapping(uint/*upgradeId*/ => Status) status;
        mapping(uint/*upgradeId*/ => address[]/*voters*/) voters;
        mapping(uint/*upgradeId*/ => mapping(address/*voter*/ => bool)) votersVote;
        mapping(uint/*upgradeId*/ => mapping (address/*user*/ => uint256/*weight*/)) weights;
        mapping(uint/*upgradeId*/ => uint256/*weight*/) totalWeights;
        mapping(uint/*upgradeId*/ => uint256) voteCounts;
        mapping(uint/*upgradeId*/ => IDiamondCut.FacetCut[]) upgrades;
        VoteToken token;
        uint nonce;
    }

    function getAdvancedTokenVoteStorage() internal pure returns (AdvancedTokenVoteStorage storage st) {
        bytes32 pos = ADVANCE_DIAMOND_STORAGE;
        assembly {
            st.slot := pos
        }
    }

    constructor(address _tokenAddr) {
        AdvancedTokenVoteStorage storage st = getAdvancedTokenVoteStorage();
        st.token = VoteToken(_tokenAddr);
        st.nonce = 0;
    }

    function askForUpgrade(IDiamondCut.FacetCut[] memory _upgrades) public {
        AdvancedTokenVoteStorage storage st = getAdvancedTokenVoteStorage();
        require(_upgrades.length >= 1, "Count of upgrades should be greater or equal to 1");
        require(st.token.balanceOf(msg.sender) != 0, "Balance of user should be greater than 0");
        
        st.status[st.nonce] = Status.Open;

        for (uint i = 0; _upgrades.length > i; ++i) {
            st.upgrades[st.nonce].push(_upgrades[i]);
        }
        
        /* Keep track of who has right to vote for this upgrade*/
        st.voters[st.nonce] = st.token.getHolders(); 
        /* Init weights to current ERC20 balance of each voters*/
        for (uint i = 0 ; st.voters[st.nonce].length > i ; ++i) {
            uint256 balance = st.token.balanceOf(st.voters[st.nonce][i]);
            st.weights[st.nonce][st.voters[st.nonce][i]] = balance;
            st.totalWeights[st.nonce] += balance;
        }
        _vote(st.nonce);
        st.nonce++;
    }
    
    function vote(uint upgradeId) virtual public returns (bool success);

    function _vote(uint upgradeId) internal returns (bool success) {
        AdvancedTokenVoteStorage storage st = getAdvancedTokenVoteStorage();
        require(st.status[upgradeId] == Status.Open);
        require(st.votersVote[upgradeId][msg.sender] != true, "Voter already voted");


        st.votersVote[upgradeId][msg.sender] = true;
        uint256 weight = st.weights[upgradeId][msg.sender];

        st.voteCounts[upgradeId] += weight;
        emit OnVote(upgradeId, msg.sender); 
        
        return st.voteCounts[upgradeId] > st.totalWeights[upgradeId] / 2;

    }

    function _setStatus(uint upgradeId, Status status_) internal returns (bool success) {
        AdvancedTokenVoteStorage storage st = getAdvancedTokenVoteStorage();
        st.status[upgradeId] = status_;
        emit OnStatusChange(upgradeId, status_);
        return true;
    }

    function weightOf(uint upgradeId, address addr) public view returns (uint weight) {
        AdvancedTokenVoteStorage storage st = getAdvancedTokenVoteStorage();
        return st.weights[upgradeId][addr];
    }

    function getStatus(uint upgradeId) public view returns (Status status_) {
        AdvancedTokenVoteStorage storage st = getAdvancedTokenVoteStorage();
        return st.status[upgradeId];
    }
    
    function getUpgrade(uint upgradeId) public view returns (IDiamondCut.FacetCut[] memory _upgrades) {
        AdvancedTokenVoteStorage storage st = getAdvancedTokenVoteStorage();
        return st.upgrades[upgradeId];
    }

    function voteCountsOf(uint upgradeId) public view returns (uint count) {
        AdvancedTokenVoteStorage storage st = getAdvancedTokenVoteStorage();
        return st.voteCounts[upgradeId];
    }

    event OnVote(uint upgradeId, address indexed _from);
    event OnStatusChange(uint upgradeId, Status _status);

}
