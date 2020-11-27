// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

import "./BasicErc20Token.sol";
import "../interfaces/IDiamondCut.sol";

contract AdvancedTokenVote1202 {

    mapping(uint/*issueId*/ => string/*issueDesc*/) public issueDescriptions;
    mapping(uint/*issueId*/ => uint[]/*option*/) internal options;
    mapping(uint/*issueId*/ => bool) internal isOpen;

    mapping(uint/*issueId*/ => mapping (address/*user*/ => uint256/*weight*/)) public weights;
    mapping(uint/*issueId*/ => mapping (uint => uint256)) public weightedVoteCounts;
    mapping(uint/*issueId*/ => mapping (address => uint)) public  ballots;

    mapping(uint/*issueId*/ => IDiamondCut.FacetCut[]) public upgrades;

    BasicErc20Token private token;
    address[] voters;

    mapping(address/*voterAddr*/ => uint/*upgradeId*/) public votes;

    constructor(address _tokenAddr, address[] memory _voters) {
        token = BasicErc20Token(_tokenAddr);
        voters = _voters;
    }


    // Needs to be also protected by a vote
//     function addVoter(address _voter) internal {
    //     for (uint i = 0; i < voters.length; ++i) {
    //         if (voters[i] == _voter) {
    //             return false;
    //         }
    //     }
    //     voters.push(_voter);
    //     return true;
    // }
    //
    // function removeVoter(address _voter) internal returns (bool deleted) {
    //     for (uint i = 0; i < voters.length; ++i) {
    //         if (voters[i] == _voter) {
    //             delete voters[i];
    //             return true;
    //         }
    //     }
    //     return false;
    // }


    // function createIssue(uint issueId, address _tokenAddr, uint[] memory options_,
    //     address[] memory qualifiedVoters_, string memory issueDesc_
    // ) public {
    //     require(options_.length >= 2);
    //     options[issueId] = options_;
    //     BasicErc20Token token = BasicErc20Token(_tokenAddr);
    //     isOpen[issueId] = true;
    //
    //     // We realize the ERC20 will need to be extended to support snapshoting the weights/balances.
    //     for (uint i = 0; i < qualifiedVoters_.length; i++) {
    //         address voter = qualifiedVoters_[i];
    //         weights[issueId][voter] = token.balanceOf(voter);
    //     }
    //     issueDescriptions[issueId] = issueDesc_;
    //
    // }

    
    function askForUpgrade(uint upgradeId, IDiamondCut.FacetCut[] memory _upgrades) public {
        require(upgrades[upgradeId].length == 0);
        require(_upgrades.length >= 1);
        isOpen[upgradeId] = true;
        for (uint i = 0; _upgrades.length > i; ++i) {
            upgrades[upgradeId].push(_upgrades[i]);
        }

    }


    function vote(uint issueId, uint option) public returns (bool success) {
        require(isOpen[issueId]);
        // TODO check if option is valid

        uint256 weight = weights[issueId][msg.sender];
        weightedVoteCounts[issueId][option] += weight;  // initial value is zero
        ballots[issueId][msg.sender] = option;
        emit OnVote(issueId, msg.sender, option);
        return true;
    }


    // function vote(uint upgradeId) public returns (bool success) {
    //     require(isOpen[upgradeId]);
    //     // TODO check if option is valid
    //
    //     uint256 weight = weights[upgradeId][msg.sender];
    //     weightedVoteCounts[upgradeId][option] += weight;  // initial value is zero
    //     ballots[upgradeId][msg.sender] = option;
    //     emit OnVote(upgradeId, msg.sender, option);
    //     return true;
    // }

    function setStatus(uint issueId, bool isOpen_) public returns (bool success) {
        // Should have a sense of ownership. Only Owner should be able to set the status
        isOpen[issueId] = isOpen_;
        emit OnStatusChange(issueId, isOpen_);
        return true;
    }

    function ballotOf(uint issueId, address addr) public view returns (uint option) {
        return ballots[issueId][addr];
    }

    function weightOf(uint issueId, address addr) public view returns (uint weight) {
        return weights[issueId][addr];
    }

    function getStatus(uint issueId) public view returns (bool isOpen_) {
        return isOpen[issueId];
    }

    function weightedVoteCountsOf(uint issueId, uint option) public view returns (uint count) {
        return weightedVoteCounts[issueId][option];
    }

    // TODO: changed to topOptions if determined
    function winningOption(uint issueId) public view returns (uint option) {
        uint ci = 0;
        for (uint i = 1; i < options[issueId].length; i++) {
            uint optionI = options[issueId][i];
            uint optionCi = options[issueId][ci];
            if (weightedVoteCounts[issueId][optionI] > weightedVoteCounts[issueId][optionCi]) {
                ci = i;
            } // else keep it there
        }
        return options[issueId][ci];
    }

    function issueDescription(uint issueId) public view returns (string memory desc) {
        return issueDescriptions[issueId];
    }

    function availableOptions(uint issueId) public view returns (uint[] memory options_) {
        return options[issueId];
    }



    event OnVote(uint issueId, address indexed _from, uint _value);
    event OnStatusChange(uint issueId, bool newIsOpen);

}
