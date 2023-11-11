// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import { console2 } from "forge-std/Test.sol";

abstract contract EquippableExtensionData {
    constructor(address equippable) {
        EquippableStorage.write(equippable);
    }

    function _getEquippable() internal view returns (address) {
        EquippableStorage.Data storage data = EquippableStorage.read();
        return data.equippable;
    }
}

library EquippableStorage {
    bytes32 public constant STORAGE_POSITION = keccak256(abi.encode(uint256(keccak256("0xrails.Extensions.EquippableData")) -1));

    struct Data {
        address equippable;
    }

    function write(address newEquippable) internal {
        Data storage data = read();
        data.equippable = newEquippable;
    }

    function read() internal pure returns (Data storage data) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            data.slot := position
        }
    }
}
