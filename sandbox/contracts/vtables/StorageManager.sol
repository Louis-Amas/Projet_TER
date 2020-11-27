// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import "./Storage.sol";

contract StorageManager is Storage {

    function getImplementationFromName(string memory func) external view
        returns (address impl)
    {
        return _getImplementation(bytes4(keccak256(bytes(func))));
    }

   function addImplementationFromName(string memory func, address impl) external {
        _addImplementation(bytes4(keccak256(bytes(func))), impl);
    }


    function _addImplementation(bytes4 func, address impl) internal {
        implementations[func] = impl;
    }

    function _getImplementation(bytes4 func) internal view returns (address impl) {
        if (implementations[func] == address(0))
            return _fallback;
        return implementations[func];
    }
}
