// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import "./Proxy.sol";

contract OwnableProxy is Proxy {
    bytes32 internal constant _owner = keccak256("test.owner");

    constructor() {
        bytes32 slot = _owner;
        address sender = msg.sender;
        assembly {
            sstore(slot, sender)
        }
    }

    function _getOwner() private view returns (address owner) {
        bytes32 slot = _owner;
        assembly {
            owner := sload(slot)
        }

    }

    function _setOwner(address newOwner) private isOwner(msg.sender) {
        bytes32 slot = _owner;
        assembly {
            sstore(slot, newOwner)
        }

    }

    modifier isOwner(address addr) {
        address owner = _getOwner();
        require(owner == addr, "Caller is not owner");
        _;
    }

    function upgradeTo(address impl) public isOwner(msg.sender) {
        _setImplementation(impl);
    }

    function upgradeToAndCall(address impl, bytes calldata data) public 
        isOwner(msg.sender) returns (bool success) {
        _setImplementation(impl);
        (bool res, ) = impl.delegatecall(data);
        require(res);
        return res;
    }
}
