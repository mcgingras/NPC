// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface ITraitMetadataExtension {
  function ext_setup(address easel) external;
  function ext_contractURI() external;
  function ext_tokenURI(uint256 tokenId) external;
}
