// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

import "./interfaces/IDiamondCut.sol";
import "./libraries/Utils.sol";
import "./Diamond.sol";

abstract contract FixedDiamond is Diamond {

    constructor(IDiamondCut.FacetCut[][] memory _diamondCuts) Diamond() {
        require(_diamondCuts.length >= 1, "Need at least one DiamondCut");
        Utils.FixedDiamondStorage storage st = Utils.getFixedDiamondStorage();
        st.maxVersion = _diamondCuts.length;
        for (uint i = 0; _diamondCuts.length > i; ++i) {
            for (uint j = 0; _diamondCuts[i].length > j; ++j) {
                st.diamondCuts[i].push(_diamondCuts[i][j]);
            }   
        }
        _applyUpgrades(st.diamondCuts[0]);
    }

}
