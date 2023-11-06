// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IERC6551Registry } from "./ERC6551/ERC6551Registry.sol";
import { TraitRegistry } from "./TraitRegistry.sol";

/// This contract also probably has to be aware of the TraitRegistry contract.
/// And maybe even the salt so it can reconstruct the account address for a given tokenId.
contract Renderer {
  address public erc6551Registry;
  address public traitRegistry;

  constructor(address _traitRegistry) {
    traitRegistry = _traitRegistry;
  }

  /// The meat and potatoes of this contract.
  /// Starting very simple... no equipping. All traits owned are rendered.
  function tokenURI(uint256 tokenId) public view returns (string memory) {
    // const tbaAddressForToken = IERC6551Registry(erc6551Registry).account(
    //   address(this), // implementation
    //   bytes32(0), // salt
    //   block.chainid, // chainId
    //   address(this), // tokenContract
    //   tokenId, // tokenId
    // );

    // TraitRegistry(traitRegistry).getTraitsForOwner(tbaAddressForToken);

    return "";
  }

  /// TODO: add "onlyOwner" modifier
  function setTraitRegistry(address _traitRegistry) public {
    traitRegistry = _traitRegistry;
  }
}