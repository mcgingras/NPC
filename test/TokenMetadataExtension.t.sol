// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { ERC721Rails } from "0xrails/cores/ERC721/ERC721Rails.sol";
import {IExtensions} from "0xrails/extension/interface/IExtensions.sol";
import {Multicall} from "openzeppelin-contracts/utils/Multicall.sol";
import { Easel } from "../src/Easel.sol";
import { ERC6551Registry } from "../src/ERC6551Registry.sol";
import { ERC6551Account } from "../src/ERC6551Account.sol";
import { TokenFactory } from "groupos/factory/TokenFactory.sol";
import { TokenMetadataExtension } from "../src/extensions/metadata/tokenMetadataExtension.sol";
import { ITokenMetadataExtension } from "../src/extensions/metadata/ITokenMetadataExtension.sol";
import { EquippableExtension } from "../src/extensions/equippable/EquippableExtension.sol";
import { IEquippableExtension } from "../src/extensions/equippable/IEquippableExtension.sol";
import { Equippable } from "../src/extensions/equippable/Equippable.sol";


/// @title TokenMetadataExtensionTest
/// @author frog @0xmcg
/// @notice Tests the 0xRails factory + custom metadata extensions for Noun Citizens.
contract TokenMetadataExtensionTest is Test {
    address public caller = address(1);
    ERC6551Registry public registry = new ERC6551Registry();
    ERC6551Account public accountImpl = new ERC6551Account();
    Easel public easel = new Easel();
    TokenMetadataExtension public tokenMetadataExtension = new TokenMetadataExtension(address(easel), address(registry));
    TokenFactory public tokenFactory = new TokenFactory();
    ERC721Rails public erc721Rails = new ERC721Rails();
    Equippable equippable = new Equippable();
    EquippableExtension public equippableExtension = new EquippableExtension(address(equippable));

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
      bytes memory addSetupMetadata = abi.encodeWithSelector(
        IExtensions.setExtension.selector, ITokenMetadataExtension.ext_setup.selector, address(tokenMetadataExtension));

      bytes memory addTokenURIExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, ITokenMetadataExtension.ext_tokenURI.selector, address(tokenMetadataExtension));

      bytes memory addContractURIExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector,
        ITokenMetadataExtension.ext_contractURI.selector,
        address(tokenMetadataExtension));

      bytes memory addSetupEquippedExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IEquippableExtension.ext_setupEquipped.selector, address(equippableExtension)
      );

      bytes memory addGetAllExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IEquippableExtension.ext_getEquippedTokenIds.selector, address(equippableExtension)
      );

      bytes[] memory initCalls = new bytes[](5);
      initCalls[0] = addSetupMetadata;
      initCalls[1] = addTokenURIExtension;
      initCalls[2] = addContractURIExtension;
      initCalls[3] = addSetupEquippedExtension;
      initCalls[4] = addGetAllExtension;

      bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, initCalls);

      address payable token = tokenFactory.createERC721(
        payable(erc721Rails),
        caller,
        "Noun Citizens",
        "NPC",
        initData
      );

      // replace address 2 with trait 1155 deployed through factory
      ITokenMetadataExtension(token).ext_setup(address(registry), address(easel), address(2), address(accountImpl), block.chainid, bytes32(0));

      assertEq(ERC721Rails(token).name(), "Noun Citizens");
      assertEq(ERC721Rails(token).tokenURI(0), "TEMP_TOKEN_URI");
      assertEq(ERC721Rails(token).contractURI(), "TEMP_CONTRACT_URI");

      vm.stopPrank();
    }
}
