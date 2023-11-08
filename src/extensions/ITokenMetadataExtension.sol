// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface ITokenMetadataExtension {
  function ext_contractURI() external;
  function ext_tokenURI(uint256 tokenId) external;
}