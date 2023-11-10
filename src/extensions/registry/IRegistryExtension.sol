// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IRegistryExtension {
  function ext_registerTrait(bytes memory rleBytes, string memory name) external;
  function ext_getImageDataForTrait(uint256 traitId) external returns (bytes memory);
}