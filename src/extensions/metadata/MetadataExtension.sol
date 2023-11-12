// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { console2 } from "forge-std/Test.sol";
import { Extension } from "0xrails/extension/Extension.sol";
import { MetadataExtensionData } from "./MetadataExtensionData.sol";
import { Easel } from "../../Easel.sol";
import { IRegistryExtension } from "../../extensions/registry/IRegistryExtension.sol";


contract MetadataExtension is Extension {
    // no matter what I do, the constructor is set but seems to be wiped out....
    constructor(address _easel) Extension() {
        console2.log("in constr", _easel);
        MetadataExtensionData.layout().easel = _easel;
    }

    /*===============
        EXTENSION
    ===============*/

    /// @inheritdoc Extension
    function getAllSelectors() public pure override returns (bytes4[] memory selectors) {
        selectors = new bytes4[](3);
        selectors[0] = this.ext_contractURI.selector;
        selectors[1] = this.ext_tokenURI.selector;
        selectors[2] = this.ext_setup.selector;
        return selectors;
    }

    /// @inheritdoc Extension
    function signatureOf(bytes4 selector) public pure override returns (string memory) {
        if (selector == this.ext_contractURI.selector) {
            return "ext_contractURI()";
        } else if (selector == this.ext_tokenURI.selector) {
            return "ext_tokenURI(uint256)";
        } else if (selector == this.ext_setup.selector) {
            return "ext_setup(address)";
        } else {
            return "";
        }
    }

    // not sure why these are not being set in the constructor?
    function ext_setup(address easel) external {
        MetadataExtensionData.layout().easel = easel;
    }

    // if this is a proper extension then we would probably want to store this per address
    function ext_contractURI() external view returns (string memory uri) {
        string memory json = '{"name":"Noun Playable Citizens Trait","description":"Tokenbound Nouns traits.""image":"","external_link": ""}';
        return string.concat("data:application/json;utf8,", json);
    }

    function ext_tokenURI(uint256 tokenId) external returns (string memory uri) {
      require(MetadataExtensionData.layout().easel != address(0), "TokenMetadataExtension: easel not configured");
      address easel = MetadataExtensionData.layout().easel;

      bytes[] memory parts = new bytes[](1);
      bytes memory data = IRegistryExtension(address(this)).ext_getImageDataForTrait(tokenId);
      parts[0] = data;
      return Easel(easel).generateSVGForParts(parts);
    }
}
