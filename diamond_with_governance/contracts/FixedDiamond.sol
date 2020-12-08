// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

import "./interfaces/IDiamondCut.sol";
import "./libraries/LibDiamond.sol";
import "./Diamond.sol";

contract FixedDiamond is Diamond {
   
    mapping(uint => IDiamondCut.FacetCut[]) private diamondCuts;

    constructor(IDiamondCut.FacetCut[][] memory _diamondCuts) Diamond() {
        for (uint i = 0; _diamondCuts.length > i; ++i) {
            for (uint j = 0; _diamondCuts[i].length > j; ++j) {
                diamondCuts[i].push(_diamondCuts[i][j]);
            }
            
        }
    }

    function switchBehavior(uint version) private {
        //check if version exist
        _applyUpgrades(diamondCuts[version]);
    }
}
