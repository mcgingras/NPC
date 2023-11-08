// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IEquippableExtension {
  function _getEquippable() external view returns (address);
  function ext_setupEquipped(address owner, uint256[] memory _tokenIds) external;
  function ext_equipTokenId(address owner, uint256 tokenId) external;
  function ext_unequipTokenId(address owner, uint256 tokenId) external;
  function ext_getEquippedTokenIds(address owner) external view returns (uint256[] memory);
}