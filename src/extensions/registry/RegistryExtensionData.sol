// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library RegistryExtensionData {
    bytes32 internal constant SLOT = keccak256(abi.encode(uint256(keccak256("0xrails.Extensions.RegistryExtension")) - 1));

    struct Trait {
      string name;
      bytes rleBytes;
    }

    struct Layout {
        uint256 traitIdCount;
        mapping (uint256 => Trait) traits;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = SLOT;
        assembly {
            l.slot := slot
        }
    }
}
