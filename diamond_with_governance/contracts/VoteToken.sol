// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract VoteToken is ERC20 {

    address[] public holders;

    constructor(address[] memory _holders, uint256 initialSupply) ERC20("Vote", "VOT") {
        holders = _holders;
        for (uint i = 0 ; _holders.length > i; ++i) {
            _mint(holders[i], initialSupply);
        }
    }

    function getHoldersCount() view external returns (uint size){
        return holders.length;
    }

    function getHolders() view external returns (address[] memory _holders) {
        return holders;
    }
    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool success) {
        if (!ERC20.transfer(recipient, amount))
            return false;
        
        // Check if sender still have token
        bool senderNeedsToBeDeleted;
        if (ERC20.balanceOf(msg.sender) == 0) {
            senderNeedsToBeDeleted = true;
        }

        for (uint i = 0 ; holders.length > i ; ++i) {
            // If the sender has no longer token delete it from holders
            if (senderNeedsToBeDeleted && msg.sender == holders[i]) {
                holders[i] = holders[holders.length - 1];
                holders.pop();
            }
            if (holders[i] == recipient) {
                return true;
            }
        }
        holders.push(recipient);
        return true;

    }

    function transferFrom(address /*sender*/, address /*recipient*/, uint256 /*amount*/) public virtual override returns (bool) {
        revert();
    }
}
