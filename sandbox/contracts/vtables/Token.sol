// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import "./Storage.sol";

contract Token_V0_Storage is Storage {
    address public admin;
    uint256 public total_amount;
    mapping(address => uint256) internal _balances;

    function initialize(address addr) public {
        require(addr != address(0));
        admin = addr;
        total_amount = 0;
    }

    modifier isAdmin() {
        require(admin == msg.sender);
        _;
    }

    modifier senderHasSufficientBalance(uint256 value) {
        require(_balances[msg.sender] > value, "Unsufficient balance!");
        _;
    }

    function getMyBalance() public view returns (uint256 value) {
        return _balances[msg.sender];
    }
}

contract Mint is Token_V0_Storage {
    function mint(address account, uint256 value) external isAdmin {
        _balances[account] = value;
        total_amount += value;
    }
}

contract Burn is Token_V0_Storage {
    function burn(uint256 value) senderHasSufficientBalance(value) external {
        _balances[msg.sender] -= value;
        total_amount -= value;
    }
}


contract TransferTo is Token_V0_Storage {
    function transferTo(address account, uint256 value) external
    senderHasSufficientBalance(value) {
        require(account != address(0x0), "Can't tranfer to address 0.");
        _balances[msg.sender] -= value;
        _balances[account] += value;
    }
}

contract Token_V1_Storage is Token_V0_Storage {
    uint256 public burnedCoin;
}

contract BurnUpgraded is Token_V1_Storage {
    function burn(uint256 value) senderHasSufficientBalance(value) external {
        _balances[msg.sender] -= value;
        burnedCoin += value;
    }
}

contract GetBurnedCoin is Token_V1_Storage {
    function getBurnedCoin() external {
        _balances[msg.sender] += burnedCoin;
        burnedCoin = 0;
    }
} 
