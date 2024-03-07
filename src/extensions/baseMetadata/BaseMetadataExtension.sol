// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Extension } from "0xrails/extension/Extension.sol";
import { BaseMetadataExtensionData } from "./BaseMetadataExtensionData.sol";
import { Easel } from "../../Easel.sol";
import { IERC6551Registry } from "../../ERC6551Registry.sol";
import { IRegistryExtension } from "../../extensions/registry/IRegistryExtension.sol";
import { IEquippableExtension } from "../../extensions/equippable/IEquippableExtension.sol";
import "openzeppelin-contracts/utils/Base64.sol";
import "openzeppelin-contracts/utils/Strings.sol";


/// @title BaseMetadataExtension
/// @notice Extension for generating token URIs for the 721 base NFT token
contract BaseMetadataExtension is Extension {
    using Strings for uint256;

    constructor(address _easel, address _erc6551Registry) Extension() {
        BaseMetadataExtensionData.layout().easel = _easel;
        BaseMetadataExtensionData.layout().erc6551Registry = _erc6551Registry;
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
            return "ext_setup(address,address,address,address,uint256,bytes32)";
        } else {
            return "";
        }
    }

    function ext_setup(address registry, address easel, address traitContractAddress, address implementation, uint256 chainId, bytes32 salt) external {
        BaseMetadataExtensionData.layout().erc6551Registry = registry;
        BaseMetadataExtensionData.layout().easel = easel;
        BaseMetadataExtensionData.layout().accountConfigs[address(this)] = BaseMetadataExtensionData.Account({
            traitContractAddress: traitContractAddress,
            implementation: implementation,
            chainId: chainId,
            salt: salt
        });
    }

    // TODO:
    // Implement this function for 1155 tokens
    function ext_contractURI() external pure returns (string memory uri) {
        string memory json = '{"name":"Noun Playable Citizens","description":"Tokenbound Nouns.""image":"","external_link": ""}';
        return string.concat("data:application/json;utf8,", json);
    }

    function ext_tokenURI(uint256 tokenId) external returns (string memory uri) {
      require(BaseMetadataExtensionData.layout().easel != address(0), "BaseMetadataExtension: easel not configured");
      require(BaseMetadataExtensionData.layout().erc6551Registry != address(0), "BaseMetadataExtension: erc6551Registry not configured");
      require(BaseMetadataExtensionData.layout().accountConfigs[address(this)].implementation != address(0), "BaseMetadataExtension: nftContractAddress not configured");

      BaseMetadataExtensionData.Account memory account = BaseMetadataExtensionData.layout().accountConfigs[address(this)];
      address easel = BaseMetadataExtensionData.layout().easel;
      address erc6551Registry = BaseMetadataExtensionData.layout().erc6551Registry;

      address tbaAddressForToken = IERC6551Registry(erc6551Registry).account(
          account.implementation,
          account.salt,
          account.chainId,
          address(this),
          tokenId
      );

      uint256[] memory tokens = IEquippableExtension(account.traitContractAddress).ext_getEquippedTokenIds(tbaAddressForToken);

      bytes[] memory traitParts = new bytes[](tokens.length);
      for (uint256 i = 0; i < tokens.length; i++) {
          uint256 traitId = tokens[i];
          traitParts[i] = IRegistryExtension(account.traitContractAddress).ext_getImageDataForTrait(traitId);
      }

      string memory output = string(Easel(easel).generateSVGForParts(traitParts));
      string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "NPC #', tokenId.toString(), '", "description": "Noun Playable Character", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
      output = string(abi.encodePacked('data:application/json;base64,', json));

      return output;
    }
}
