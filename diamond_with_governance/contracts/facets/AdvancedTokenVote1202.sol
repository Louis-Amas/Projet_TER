// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

import "../VoteToken.sol";
import "../interfaces/IDiamondCut.sol";

contract AdvancedTokenVote1202 {

    bytes32 constant ADVANCE_DIAMOND_STORAGE = keccak256("diamond.advancedtokenvote");

    struct AdvancedTokenVoteStorage {
        mapping(uint/*upgradeId*/ => bool) isOpen;
        mapping(uint/*upgradeId*/ => address[]/*voters*/) voters;
        mapping(uint/*upgradeId*/ => mapping (address/*user*/ => uint256/*weight*/)) weights;
        mapping(uint/*upgradeId*/ => uint256/*weight*/) totalWeights;
        mapping(uint/*upgradeId*/ => uint256) voteCounts;
        mapping(uint/*upgradeId*/ => IDiamondCut.FacetCut[]) upgrades;

        VoteToken token;
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
    }

    function askForUpgrade(uint upgradeId, IDiamondCut.FacetCut[] memory _upgrades) public {
        AdvancedTokenVoteStorage storage st = getAdvancedTokenVoteStorage();
        require(st.upgrades[upgradeId].length == 0);
        require(_upgrades.length >= 1);
        require(st.token.balanceOf(msg.sender) != 0);

        st.isOpen[upgradeId] = true;

        for (uint i = 0; _upgrades.length > i; ++i) {
            st.upgrades[upgradeId].push(_upgrades[i]);
        }
        
        /* Keep track of who has right to vote for this upgrade*/
        st.voters[upgradeId] = st.token.getHolders(); 
        /* Init weights to current ERC20 balance of each voters*/
        for (uint i = 0 ; st.voters[upgradeId].length > i ; ++i) {
            uint256 balance = st.token.balanceOf(st.voters[upgradeId][i]);
            st.weights[upgradeId][st.voters[upgradeId][i]] = balance;
            st.totalWeights[upgradeId] += balance;
        }

    }

    function vote(uint upgradeId) public returns (bool success) {
        AdvancedTokenVoteStorage storage st = getAdvancedTokenVoteStorage();
        require(st.isOpen[upgradeId]);

        uint256 weight = st.weights[upgradeId][msg.sender];

        st.voteCounts[upgradeId] += weight;
        if (st.voteCounts[upgradeId] > st.totalWeights[upgradeId] / 2) {
            //accept change
        } 

        emit OnVote(upgradeId, msg.sender); 
        return true;
    }

    function setStatus(uint upgradeId, bool isOpen_) public returns (bool success) {
        AdvancedTokenVoteStorage storage st = getAdvancedTokenVoteStorage();
        // Should have a sense of ownership. Only Owner should be able to set the status
        st.isOpen[upgradeId] = isOpen_;
        emit OnStatusChange(upgradeId, isOpen_);
        return true;
    }

    function weightOf(uint upgradeId, address addr) public view returns (uint weight) {
        AdvancedTokenVoteStorage storage st = getAdvancedTokenVoteStorage();
        return st.weights[upgradeId][addr];
    }

    function getStatus(uint upgradeId) public view returns (bool isOpen_) {
        AdvancedTokenVoteStorage storage st = getAdvancedTokenVoteStorage();
        return st.isOpen[upgradeId];
    }

    function voteCountsOf(uint upgradeId) public view returns (uint count) {
        AdvancedTokenVoteStorage storage st = getAdvancedTokenVoteStorage();
        return st.voteCounts[upgradeId];
    }

    event OnVote(uint upgradeId, address indexed _from);
    event OnStatusChange(uint upgradeId, bool newIsOpen);

}
