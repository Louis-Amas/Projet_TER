// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

import "../interfaces/IDiamondCut.sol";
import "./LibDiamond.sol";

library Utils {

    bytes32 constant INVESTMENT_STORAGE = keccak256("investment.storage");
 
    struct InvestmentStorage {
        uint initialSupply;
        uint currentSupply;
        uint version;
    }

    function getInvestmentStorage() internal pure returns (InvestmentStorage storage st) {
        bytes32 position = INVESTMENT_STORAGE;
        assembly {
            st.slot := position
        }
    }
     
    bytes32 constant FIXED_DIAMOND_STORAGE = keccak256("diamond.fixed.diamondCuts");
 
    struct FixedDiamondStorage {
        mapping(uint => IDiamondCut.FacetCut[]) diamondCuts;
        uint maxVersion;
    }


    function getFixedDiamondStorage() internal pure returns (FixedDiamondStorage storage st) {
        bytes32 position = FIXED_DIAMOND_STORAGE;
        assembly {
            st.slot := position
        }
    }

    function changeBehavior() internal {
        InvestmentStorage storage st = getInvestmentStorage();
        if (st.initialSupply / 2 > st.currentSupply) {
            st.version += 1;
            switchBehavior(st.version);
        }
        if (st.initialSupply / 4 > st.currentSupply) {
            st.version += 1;
            switchBehavior(st.version);
        }
    }


    function switchBehavior(uint version) internal {
        Utils.FixedDiamondStorage storage st = Utils.getFixedDiamondStorage();
        require(version > 0 || version < st.maxVersion, "Behavior doen't exists");
        // _applyUpgrades(st.diamondCuts[version]);
        LibDiamond.diamondCut(st.diamondCuts[version], address(0), new bytes(0));

    }
}
