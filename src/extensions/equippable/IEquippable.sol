// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IEquippable {
  function setupEquipped(address owner, uint256[] memory _tokenIds) external;
  function equipTokenId(address owner, uint256 tokenId) external;
  function unequipTokenId(address owner, uint256 tokenId) external;
  function getEquippedTokenIds(address owner) external view returns (uint256[] memory);
}