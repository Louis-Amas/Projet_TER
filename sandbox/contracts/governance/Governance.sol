// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

contract Governance {

    uint256 nonce;

    struct Elector{
        bool hasRightToVote;
        uint256 vote;
    }

    mapping(address => Elector) public electors;

    struct Proposal {
        string hash;
        address owner;
        address contractAdrress;
    }

    mapping(uint256 => Proposal) public proposals;
   
    event NewProposal(uint256 proposal);
    event AppovedProposal(uint256 proposal);
    event NewContractAddrValidation(address addr);

    bool proposalTurn;

    address[] _electors;

    function initialize(address[] memory addresses) public {
        require(addresses.length != 0);
        nonce = 0;
        for (uint i = 0; addresses.length > i; ++i) {
            electors[addresses[i]] = Elector({
                hasRightToVote: true,
                vote: 10
            });
        }
        _electors = addresses;
        proposalTurn = true;
    }
    


    modifier isElector() {
        require(electors[msg.sender].hasRightToVote, "User is not elector");
        _;
    }

    modifier canAddProposal() {
        require(proposalTurn);
        _;
    }

    function addProposal(string memory hash) external isElector canAddProposal {
        nonce += 1;
        electors[msg.sender].vote = nonce;
        proposals[nonce] = Proposal({
            hash: hash,
            owner: msg.sender,
            contractAdrress: address(0)
        });
        emit NewProposal(nonce);
    }

    function checkIfAllElectorsVoteForTheCurrentProposal() public view returns (bool success) {
        for (uint i = 0 ; _electors.length > i; ++i) {
            if ( electors[_electors[i]].vote != nonce)
                return false;
        }
        return true;
    }

    function voteForCurrentProposal() external isElector {
        require(nonce != 0);
        electors[msg.sender].vote = nonce;
        if (checkIfAllElectorsVoteForTheCurrentProposal()) {
            if (proposalTurn)
                manageApprovedProposal();
            else
                manageApprovedProposal(); //validate the change
        }

    }

    function manageApprovedProposal() internal {
        emit AppovedProposal(nonce);
        proposalTurn = false;
        for (uint i = 0 ; _electors.length > i; ++i) {
            electors[_electors[i]].vote = 0;
        }

    }

    function askForValidationOfContractAddress(address addr) public {
        require(msg.sender == proposals[nonce].owner);
        require(addr != address(0));
        proposals[nonce].contractAdrress = addr;
        electors[msg.sender].vote = nonce;

        emit NewContractAddrValidation(addr);
    }


}
