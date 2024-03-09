// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { console2 } from "forge-std/Test.sol";
import { Extension } from "0xrails/extension/Extension.sol";
import { TraitMetadataExtensionData } from "./TraitMetadataExtensionData.sol";
import { Easel } from "../../Easel.sol";
import { IRegistryExtension } from "../../extensions/registry/IRegistryExtension.sol";
import "openzeppelin-contracts/utils/Base64.sol";
import "openzeppelin-contracts/utils/Strings.sol";

/// @title TraitMetadataExtension
/// @notice Extension for generating token URIs for the 1155 trait tokens
contract TraitMetadataExtension is Extension {
    using Strings for uint256;

    // TODO: it's possible this isn't necessary because we need to call setup anyways
    // whats the difference between this and the setup function?
    constructor(address _easel) Extension() {
        TraitMetadataExtensionData.layout().easel = _easel;
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

    function ext_setup(address easel) external {
        TraitMetadataExtensionData.layout().easel = easel;
    }

    // TODO: add image + link
    function ext_contractURI() external pure returns (string memory uri) {
        string memory json = '{"name":"Noun Playable Citizens Trait","description":"Tokenbound Nouns traits.""image":"","external_link": ""}';
        return string.concat("data:application/json;utf8,", json);
    }

    function ext_tokenURI(uint256 tokenId) external returns (string memory uri) {
      require(TraitMetadataExtensionData.layout().easel != address(0), "TraitMetadataExtension: easel not configured");
      address easel = TraitMetadataExtensionData.layout().easel;

      bytes[] memory parts = new bytes[](1);
      bytes memory data = IRegistryExtension(address(this)).ext_getImageDataForTrait(tokenId);
      parts[0] = data;
      string memory output = string(Easel(easel).generateSVGForParts(parts));

      string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "NPC Trait #', tokenId.toString(), '", "description": "Trait to equip to NPC.", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
      output = string(abi.encodePacked('data:application/json;base64,', json));

      return output;
    }
}
