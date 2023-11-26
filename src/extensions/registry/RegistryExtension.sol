// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { console2 } from "forge-std/Test.sol";
import { Extension } from "0xrails/extension/Extension.sol";
import { RegistryExtensionData } from "./RegistryExtensionData.sol";

contract RegistryExtension is Extension {
    // can we put events in extensions?
    event TraitRegistered(uint256 traitId);

    constructor() Extension() {

    }

    /*===============
        EXTENSION
    ===============*/

    /// @inheritdoc Extension
    function getAllSelectors() public pure override returns (bytes4[] memory selectors) {
        selectors = new bytes4[](2);
        selectors[0] = this.ext_registerTrait.selector;
        selectors[1] = this.ext_getImageDataForTrait.selector;
        return selectors;
    }

    /// @inheritdoc Extension
    function signatureOf(bytes4 selector) public pure override returns (string memory) {
        if (selector == this.ext_registerTrait.selector) {
            return "ext_registerTrait(bytes,string)";
        } else if (selector == this.ext_getImageDataForTrait.selector) {
            return "ext_getImageDataForTrait(uint256)";
        } else {
            return "";
        }
    }

    /// @dev traitId index starts at 1, not 0
    /// If we decide to change this -- make sure to update test too :)
    function ext_registerTrait(bytes memory rleBytes, string memory name) public {
      uint256 currentTraitIdCount = RegistryExtensionData.layout().traitIdCount;
      uint256 newTraitIdCount = currentTraitIdCount + 1;
      RegistryExtensionData.layout().traits[newTraitIdCount] = RegistryExtensionData.Trait({
          name: name,
          rleBytes: rleBytes
      });

      RegistryExtensionData.layout().traitIdCount = newTraitIdCount;
      emit TraitRegistered(newTraitIdCount);
    }

    function ext_getImageDataForTrait(uint256 traitId) public view returns (bytes memory) {
      RegistryExtensionData.Trait memory trait = RegistryExtensionData.layout().traits[traitId];
      return trait.rleBytes;
    }
}
