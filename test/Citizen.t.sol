// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { ERC721Rails } from "0xrails/cores/ERC721/ERC721Rails.sol";
import {IExtensions} from "0xrails/extension/interface/IExtensions.sol";
import { TokenMetadataExtension } from "../src/extensions/tokenMetadataExtension.sol";
import { ITokenMetadataExtension } from "../src/extensions/ITokenMetadataExtension.sol";
import {Multicall} from "openzeppelin-contracts/utils/Multicall.sol";

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
    // FORK
    uint256 public goerliFork;
    string public GOERLI_RPC_URL = vm.envString("GOERLI_RPC_URL");
    address public caller = address(1);

    //
    TokenMetadataExtension public tokenMetadataExtension = new TokenMetadataExtension();

    // CONSTANTS
    address public tokenFactory = 0x66B28Cc146A1a2cDF1073C2875D070733C7d01Af;
    address public erc721Rails  = 0x3F4f3680c80DBa28ae43FbE160420d4Ad8ca50E4;

    function setUp() public {
      goerliFork = vm.createFork(GOERLI_RPC_URL);
      vm.selectFork(goerliFork);
    }

    function test_CreateTokenWithFactory() public {
      vm.startPrank(caller);
      address payable token = ITokenFactory(tokenFactory).createERC721(
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

      address payable token = ITokenFactory(tokenFactory).createERC721(
        payable(erc721Rails),
        caller,
        "Noun Citizens",
        "NPC",
        initData
      );

      vm.stopPrank();
    }

}
