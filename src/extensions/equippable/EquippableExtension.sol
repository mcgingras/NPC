// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { console2 } from "forge-std/Test.sol";
import { Extension } from "0xrails/extension/Extension.sol";
import { IEquippable } from "./IEquippable.sol";
import { IEquippableExtension } from "./IEquippableExtension.sol";
import { EquippableExtensionData } from "./EquippableExtensionData.sol";

contract EquippableExtension is Extension, EquippableExtensionData {
    constructor(address equippable) Extension() EquippableExtensionData(equippable) {}

    /*===============
        EXTENSION
    ===============*/

    /// @inheritdoc Extension
    function getAllSelectors() public pure override returns (bytes4[] memory selectors) {
        selectors = new bytes4[](4);
        selectors[0] = this.ext_setupEquipped.selector;
        selectors[1] = this.ext_equipTokenId.selector;
        selectors[2] = this.ext_unequipTokenId.selector;
        selectors[3] = this.ext_getEquippedTokenIds.selector;
        return selectors;
    }

    /// @inheritdoc Extension
    function signatureOf(bytes4 selector) public pure override returns (string memory) {
        if (selector == this.ext_setupEquipped.selector) {
          return "ext_setupEquipped(address,uint256[])";
        } else if (selector == this.ext_equipTokenId.selector) {
            return "ext_equipTokenId(address,uint256)";
        } else if (selector == this.ext_unequipTokenId.selector) {
            return "ext_unequipTokenId(address,uint256)";
        } else if (selector == this.ext_getEquippedTokenIds.selector) {
            return "ext_getEquippedTokenIds(address)";
        } else {
            return "";
        }
    }

    function ext_setupEquipped(address owner, uint256[] memory _tokenIds) external {
        return IEquippable(_getEquippable()).setupEquipped(owner, _tokenIds);
    }

    function ext_equipTokenId(address owner, uint256 tokenId) external {
        return IEquippable(_getEquippable()).equipTokenId(owner, tokenId);
    }

    function ext_unequipTokenId(address owner, uint256 tokenId) external {
       return IEquippable(_getEquippable()).unequipTokenId(owner, tokenId);
    }

    function ext_getEquippedTokenIds(address owner) external view returns (uint256[] memory) {
        console2.log(_getEquippable());
        return IEquippable(_getEquippable()).getEquippedTokenIds(owner);
    }
}
