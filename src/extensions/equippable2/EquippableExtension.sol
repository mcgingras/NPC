// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IERC1155 } from "0xrails/cores/ERC1155/interface/IERC1155.sol";
import { Extension } from "0xrails/extension/Extension.sol";
import { EquippableExtensionData } from "./EquippableExtensionData.sol";

contract EquippableExtension is Extension {
    // not sure if this is going to cause a storage collision
    uint256 constant SENTINEL_TOKEN_ID = 0;

    constructor() Extension() {}

    /*===============
        EXTENSION
    ===============*/

    /// @inheritdoc Extension
    function getAllSelectors() public pure override returns (bytes4[] memory selectors) {
        selectors = new bytes4[](2);
        selectors[0] = this.ext_setupEquipped.selector;
        selectors[1] = this.ext_getEquippedTokenIds.selector;
        return selectors;
    }

    /// @inheritdoc Extension
    function signatureOf(bytes4 selector) public pure override returns (string memory) {
        if (selector == this.ext_setupEquipped.selector) {
            return "ext_setupEquipped(address,uint256[])";
        } else if (selector == this.ext_getEquippedTokenIds.selector) {
            return "ext_getEquippedTokenIds(address)";
        } else {
            return "";
        }
    }

    function ext_setupEquipped(address owner, uint256[] memory _tokenIds) public {
      uint256 currentTokenId = SENTINEL_TOKEN_ID;

      for (uint256 i = 0; i < _tokenIds.length; i++) {
          uint256 tokenId = _tokenIds[i];
          require(IERC1155(address(this)).balanceOf(owner, tokenId) > 0, "Address must own token.");
          require(tokenId != SENTINEL_TOKEN_ID && currentTokenId != tokenId, "No cycles.");
          EquippableExtensionData.layout()._equippedByOwner[owner][currentTokenId] = tokenId;
          currentTokenId = tokenId;
      }

      EquippableExtensionData.layout()._equippedByOwner[owner][currentTokenId] = SENTINEL_TOKEN_ID;
      EquippableExtensionData.layout()._counts[owner] = _tokenIds.length;
    }

    function ext_getEquippedTokenIds(address owner) public view returns (uint256[] memory) {
      uint256[] memory array = new uint256[](EquippableExtensionData.layout()._counts[owner]);

      uint256 index = 0;
      uint256 currentTokenId = EquippableExtensionData.layout()._equippedByOwner[owner][SENTINEL_TOKEN_ID];
      while (currentTokenId != SENTINEL_TOKEN_ID) {
          array[index] = currentTokenId;
          currentTokenId = EquippableExtensionData.layout()._equippedByOwner[owner][currentTokenId];
          index++;
      }

      return array;
    }
}
