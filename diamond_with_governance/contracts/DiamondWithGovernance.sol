// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

import "./Diamond.sol";
import "./DiamondVote.sol";

contract DiamondWithGovernance is Diamond, DiamondVote {
    
    constructor(address _tokenAddr) Diamond() DiamondVote(_tokenAddr) {
    }

    function vote(uint upgradeId) override public returns (bool success) {
        if(_vote(upgradeId)) {
            _applyUpgrades(getUpgrade(upgradeId));
            _setStatus(upgradeId, Status.Accepted);
            return true;
        }
        return false;
    }


}
