// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

contract Storage {
    address internal _fallback;
    mapping(bytes4 => address) implementations;
}
