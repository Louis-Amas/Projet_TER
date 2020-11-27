// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import "./StorageManager.sol";

contract VTableProxy is StorageManager {

    constructor(address baseStorage) {
        _fallback = baseStorage;
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
        _delegate(_getImplementation(msg.sig));
    }
    // msg.sig contains 4 bytes function selector
    fallback()  external {
        _delegate(_getImplementation(msg.sig));
    }
}
