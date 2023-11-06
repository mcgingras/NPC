// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Renderer } from "./Renderer.sol";
import { ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/// @title BuiltNoun (NAME TBD! Definitely going to change.)
/// @author frog, @0xmcg on twitter.
/// @notice ERC721 designed to be used as a base contract for build-a-noun.
/// A 6551 TBA should be deployed alongside each token minted.
contract BuiltNoun is ERC721 {
  uint256 public nounIdCount;
  address public renderer;

  constructor(address _renderer) ERC721("Build-a-Noun", "TBA-N") {
    renderer = _renderer;
  }

  function mint(address to) public {
    _mint(to, nounIdCount);
    nounIdCount++;
  }

  function tokenURI (uint256 tokenId) public view override returns (string memory) {
    return Renderer(renderer).tokenURI(tokenId);
  }

  /// TODO: add "onlyOwner" modifier
  function setRenderer(address _renderer) public {
    renderer = _renderer;
  }
}