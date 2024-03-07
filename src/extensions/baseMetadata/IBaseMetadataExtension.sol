// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IBaseMetadataExtension {
  function ext_setup(address registry, address easel, address traitContractAddress, address implementation, uint256 chainId, bytes32 salt) external;
  function ext_contractURI() external;
  function ext_tokenURI(uint256 tokenId) external;
}
