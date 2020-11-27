// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

contract Proxy {

    bytes32 internal constant _impl = keccak256("test.implementation");

    function getImplementation() public view returns (address addr){
        return _getImplementation();
    }

    function _setImplementation(address newAddr) internal {
        bytes32 slot = _impl;
        assembly {
            sstore(slot, newAddr)
        }
    }

    function _getImplementation() internal view returns (address addr) {
        bytes32 slot = _impl;
        assembly {
            addr := sload(slot)
        }
    }

    function _delegate(address implementation) internal {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {
        _delegate(_getImplementation());
    }

    fallback()  external {
        _delegate(_getImplementation());
    }
}
