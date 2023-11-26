// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library EquippableExtensionData {
    bytes32 internal constant SLOT = keccak256(abi.encode(uint256(keccak256("0xrails.Extensions.EquippableExtension")) - 1));

    struct Layout {
        // uint256 constant SENTINEL_TOKEN_ID = 0;
        mapping(address => mapping(uint256 => uint256)) _equippedByOwner;
        mapping(address => uint256) _counts;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = SLOT;
        assembly {
            l.slot := slot
        }
    }
}
