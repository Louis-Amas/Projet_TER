// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

import "../libraries/Utils.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange2 is ERC20 {

    constructor() ERC20("Investment", "INV") {
    }     

    function exchangeEtherToToken() public payable {
        Utils.InvestmentStorage storage st = Utils.getInvestmentStorage();
        int256 delta = int256(st.currentSupply) - (int256(msg.value) * 1);
        require(delta >= 0, "Not enough token");
        _mint(msg.sender, msg.value * 5);
        st.currentSupply -= msg.value * 5;
        Utils.changeBehavior();
    }

}
