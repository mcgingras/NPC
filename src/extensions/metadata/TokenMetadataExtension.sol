// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Extension } from "0xrails/extension/Extension.sol";
import { TokenMetadataExtensionData } from "./TokenMetadataExtensionData.sol";
import { Easel } from "../../Easel.sol";
import { IERC6551Registry } from "../../ERC6551Registry.sol";
import { IRegistryExtension } from "../../extensions/registry/IRegistryExtension.sol";
import { IEquippableExtension } from "../../extensions/equippable/IEquippableExtension.sol";

// How does extension system deal with collisions?
/// Goal of this contract is to let anyone extend their contract with a "TBA content renderer" metadata extension.
/// On a per collection basis, this contract should return the correct rendering logic.
/// 1. determine TBA address for tokenId (needs collection, tokenId, implementation and salt)
/// 2. get tokens owned by TBA address (so tokens need to be enumerable)
/// 3. for each token, get the output
/// 4. return the overall output as function of the sum of each token output
contract TokenMetadataExtension is Extension {
    constructor(address _easel, address _erc6551Registry) Extension() {
        TokenMetadataExtensionData.layout().easel = _easel;
        TokenMetadataExtensionData.layout().erc6551Registry = _erc6551Registry;
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

    // not sure why these are not being set in the constructor?
    function ext_setup(address registry, address easel, address traitContractAddress, address implementation, uint256 chainId, bytes32 salt) external {
        TokenMetadataExtensionData.layout().erc6551Registry = registry;
        TokenMetadataExtensionData.layout().easel = easel;
        TokenMetadataExtensionData.layout().accountConfigs[address(this)] = TokenMetadataExtensionData.Account({
            traitContractAddress: traitContractAddress,
            implementation: implementation,
            chainId: chainId,
            salt: salt
        });
    }

    function ext_contractURI() external view returns (string memory uri) {
        return "TEMP_CONTRACT_URI";
    }

    function ext_tokenURI(uint256 tokenId) external returns (string memory uri) {
      require(TokenMetadataExtensionData.layout().easel != address(0), "TokenMetadataExtension: easel not configured");
      require(TokenMetadataExtensionData.layout().erc6551Registry != address(0), "TokenMetadataExtension: erc6551Registry not configured");
      require(TokenMetadataExtensionData.layout().accountConfigs[address(this)].implementation != address(0), "TokenMetadataExtension: nftContractAddress not configured");

      TokenMetadataExtensionData.Account memory account = TokenMetadataExtensionData.layout().accountConfigs[address(this)];
      address easel = TokenMetadataExtensionData.layout().easel;
      address erc6551Registry = TokenMetadataExtensionData.layout().erc6551Registry;

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

      return Easel(easel).generateSVGForParts(traitParts);

      return "TEMP_TOKEN_URI";
    }
}
