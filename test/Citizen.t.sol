// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { ERC721Rails } from "0xrails/cores/ERC721/ERC721Rails.sol";
import {IExtensions} from "0xrails/extension/interface/IExtensions.sol";
import {Multicall} from "openzeppelin-contracts/utils/Multicall.sol";
import { TokenFactory } from "groupos/factory/TokenFactory.sol";
import { TokenMetadataExtension } from "../src/extensions/tokenMetadataExtension.sol";
import { ITokenMetadataExtension } from "../src/extensions/ITokenMetadataExtension.sol";

interface ITokenFactory {
  function createERC721(
    address payable implementation,
    address owner,
    string memory name,
    string memory symbol,
    bytes calldata initData
  ) external returns (address payable token);
}

/// @title NounCitizenTest
/// @author frog @0xmcg
/// @notice Tests the 0xRails factory + custom metadata extensions for Noun Citizens.
contract NounCitizenTest is Test {

    address public caller = address(1);
    TokenMetadataExtension public tokenMetadataExtension = new TokenMetadataExtension();
    TokenFactory public tokenFactory = new TokenFactory();
    ERC721Rails public erc721Rails = new ERC721Rails();

    function setUp() public {
      //
    }

    function test_CreateTokenWithFactory() public {
      vm.startPrank(caller);
      address payable token = tokenFactory.createERC721(
        payable(erc721Rails),
        caller,
        "Noun Citizens",
        "NPC",
        ""
      );

      assertEq(ERC721Rails(token).name(), "Noun Citizens");
      vm.stopPrank();
    }

    function test_TokenURIExtension() public {
      vm.startPrank(caller);
      bytes memory addTokenURIExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, ITokenMetadataExtension.ext_tokenURI.selector, address(tokenMetadataExtension)
      );

      bytes memory addContractURIExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector,
        ITokenMetadataExtension.ext_contractURI.selector,
        address(tokenMetadataExtension)
      );

      bytes[] memory initCalls = new bytes[](2);
      initCalls[0] = addTokenURIExtension;
      initCalls[1] = addContractURIExtension;

      bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, initCalls);

      address payable token = tokenFactory.createERC721(
        payable(erc721Rails),
        caller,
        "Noun Citizens",
        "NPC",
        initData
      );

      assertEq(ERC721Rails(token).name(), "Noun Citizens");
      assertEq(ERC721Rails(token).tokenURI(0), "TEMP_TOKEN_URI");
      assertEq(ERC721Rails(token).contractURI(), "TEMP_CONTRACT_URI");

      vm.stopPrank();
    }

}
