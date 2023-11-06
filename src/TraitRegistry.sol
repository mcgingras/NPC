// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { ERC1155 } from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import { ERC1155Enumerable } from "./ERC1155Enumerable.sol";

/// @title TraitRegistry
/// @author frog, @0xmcg on twitter
/// @notice Stores nouns traits to be used in build-a-noun
/// @dev coming soon...
contract TraitRegistry is ERC1155, ERC1155Enumerable {
    event TraitRegistered(uint256 traitId);

    uint256 public traitIdCount;
    mapping (uint256 => Trait) public traits;

    // TODO: replace with proper uri...
    constructor() ERC1155("uri") {}

    /// @notice Trait struct
    struct Trait {
      bytes rleBytes;
    }

    /// @notice Registers a new trait to the collection of traits available for use in build-a-noun.
    /// @dev Check out nouns documentation for more infomation about RLE.
    /// TODO: add "onlyOwner" modifier
    function registerTrait(bytes memory rleBytes) public {
      Trait memory trait = Trait(rleBytes);
      uint256 traitId = traitIdCount;
      traits[traitId] = trait;
      traitIdCount++;
      emit TraitRegistered(traitId);
    }

    function getRleBytesForTrait(uint256 traitId) public view returns (bytes memory) {
      return traits[traitId].rleBytes;
    }

    function mint(address to, uint256 id, uint256 amount, bytes memory data) public {
        require(to != address(0), "ERC1155: mint to the zero address");

        if (balanceOf(to, id) == 0) {
            _addTokenToOwnerEnumeration(to, id);
        }

         _mint(to, id, amount, data);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        public
        override
    {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        // Perform the ownership bookkeeping
        if (from != address(0)) {
            uint256 fromBalance = balanceOf(from, id);
            if (fromBalance - amount == 0) {
                _removeTokenFromOwnerEnumeration(from, id);
            }
        }

        if (to != address(0) && balanceOf(to, id) == 0) {
            _addTokenToOwnerEnumeration(to, id);
        }

        // Call the ERC1155 safeTransferFrom function
        super.safeTransferFrom(from, to, id, amount, data);
    }
}
