// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

import "./interfaces/IDiamondCut.sol";
import "./libraries/Utils.sol";
import "./FixedDiamond.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract SelfModifyingInvestment is FixedDiamond, ERC20 {
      
    constructor(uint _initialSupply,
                /* Versions should be audited and verified by users before deploying this contract */
                IDiamondCut.FacetCut[][] memory versions) 
            FixedDiamond(versions) 
            ERC20("Investment", "INV") {
        Utils.InvestmentStorage storage st = Utils.getInvestmentStorage();
        st.initialSupply = _initialSupply;
        st.currentSupply = _initialSupply;
        st.version = 0;
    }
}
