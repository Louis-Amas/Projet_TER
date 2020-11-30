// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

import "../VoteToken.sol";
import "../interfaces/IDiamondCut.sol";

contract AdvancedTokenVote1202 {

    mapping(uint/*issueId*/ => bool) internal isOpen;

    mapping(uint/*issueId*/ => mapping (address/*user*/ => uint256/*weight*/)) public weights;
    mapping(uint/*issueId*/ => uint256/*weight*/) public totalWeights;
    mapping(uint/*issueId*/ => uint256) public weightedVoteCounts;

    mapping(uint/*issueId*/ => IDiamondCut.FacetCut[]) public upgrades;

    VoteToken private token;
    address[] voters;


    constructor(address _tokenAddr, address[] memory _voters) {
        token = VoteToken(_tokenAddr);
        voters = _voters;
    }

    function askForUpgrade(uint upgradeId, IDiamondCut.FacetCut[] memory _upgrades) public {
        require(upgrades[upgradeId].length == 0);
        require(_upgrades.length >= 1);
        isOpen[upgradeId] = true;
        for (uint i = 0; _upgrades.length > i; ++i) {
            upgrades[upgradeId].push(_upgrades[i]);
        }

        /* Init weights to current ERC20 balance of each voters*/
        for (uint i = 0 ; voters.length > i ; ++i) {
            uint256 balance = token.balanceOf(voters[i]);
            weights[upgradeId][voters[i]] = balance;
            totalWeights[upgradeId] += balance;
        }

    }

    function vote(uint upgradeId) public returns (bool success) {
        require(isOpen[upgradeId]);

        uint256 weight = weights[upgradeId][msg.sender];

        weightedVoteCounts[upgradeId] += weight;

        emit OnVote(upgradeId, msg.sender); 
        return true;
    }

    function setStatus(uint issueId, bool isOpen_) public returns (bool success) {
        // Should have a sense of ownership. Only Owner should be able to set the status
        isOpen[issueId] = isOpen_;
        emit OnStatusChange(issueId, isOpen_);
        return true;
    }

    function weightOf(uint issueId, address addr) public view returns (uint weight) {
        return weights[issueId][addr];
    }

    function getStatus(uint issueId) public view returns (bool isOpen_) {
        return isOpen[issueId];
    }

    function weightedVoteCountsOf(uint upgradeId) public view returns (uint count) {
        return weightedVoteCounts[upgradeId];
    }

    event OnVote(uint upgradeId, address indexed _from);
    event OnStatusChange(uint issueId, bool newIsOpen);

}
