// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IERC6551Registry } from "./ERC6551/ERC6551Registry.sol";
import { TraitRegistry } from "./TraitRegistry.sol";
import { Easel } from "./Easel.sol";

/// This contract also probably has to be aware of the TraitRegistry contract.
/// And maybe even the salt so it can reconstruct the account address for a given tokenId.
contract Renderer {
  address public base;
  address public erc6551Registry;
  address public traitRegistry;
  address public implementation;
  address public easel;

  constructor(address _base, address _implementation, address _erc6551Registry, address _traitRegistry, address _easel) {
    base = _base;
    traitRegistry = _traitRegistry;
    erc6551Registry = _erc6551Registry;
    implementation = _implementation;
    easel = _easel;
  }

  /// The meat and potatoes of this contract.
  /// Starting very simple... no equipping. All traits owned are rendered.
  function tokenURI(uint256 tokenId) public view returns (string memory) {
    address tbaAddressForToken = IERC6551Registry(erc6551Registry).account(implementation, bytes32(0), block.chainid, base, tokenId);
    uint256[] memory tokens = TraitRegistry(traitRegistry).tokensOfOwner(tbaAddressForToken);

    bytes[] memory traitParts = new bytes[](tokens.length);
    for (uint256 i = 0; i < tokens.length; i++) {
      uint256 traitId = tokens[i];
      traitParts[i] = TraitRegistry(traitRegistry).getRleBytesForTrait(traitId);
    }

    return Easel(easel).generateSVGForParts(traitParts);
  }

  /// TODO: add "onlyOwner" modifier
  function setTraitRegistry(address _traitRegistry) public {
    traitRegistry = _traitRegistry;
  }
}