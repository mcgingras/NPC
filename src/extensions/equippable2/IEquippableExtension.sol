// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IEquippableExtension {
  function ext_setupEquipped(address owner, uint256[] memory _tokenIds) external;
  function ext_getEquippedTokenIds(address owner) external view returns (uint256[] memory);
}