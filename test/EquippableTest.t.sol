// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { ERC1155Rails } from "0xrails/cores/ERC1155/ERC1155Rails.sol";
import { IERC1155Rails } from "0xrails/cores/ERC1155/interface/IERC1155Rails.sol";
import { IExtensions } from "0xrails/extension/interface/IExtensions.sol";
import { Multicall } from "openzeppelin-contracts/utils/Multicall.sol";
import { TokenFactory } from "groupos/factory/TokenFactory.sol";
import { TokenMetadataExtension } from "../src/extensions/tokenMetadata/tokenMetadataExtension.sol";
import { ITokenMetadataExtension } from "../src/extensions/tokenMetadata/ITokenMetadataExtension.sol";
import { EquippableExtension } from "../src/extensions/equippable/EquippableExtension.sol";
import { IEquippableExtension } from "../src/extensions/equippable/IEquippableExtension.sol";

/// @title EquippableExtensionTest
/// @author frog @0xmcg
/// @notice Tests behavior of the equippable extension
contract EquippableExtensionTest is Test {
    address public caller = address(1);
    EquippableExtension public equippableExtension = new EquippableExtension();
    TokenFactory public tokenFactory = new TokenFactory();
    ERC1155Rails public erc1155Rails = new ERC1155Rails();
    address payable token;

    function setUp() public {
      vm.startPrank(caller);
      bytes memory addSetupEquippedExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IEquippableExtension.ext_setupEquipped.selector, address(equippableExtension)
      );

      bytes memory addGetAllExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IEquippableExtension.ext_getEquippedTokenIds.selector, address(equippableExtension)
      );

      bytes memory addTokenIdExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IEquippableExtension.ext_addTokenId.selector, address(equippableExtension)
      );

      bytes memory removeTokenIdExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IEquippableExtension.ext_removeTokenId.selector, address(equippableExtension)
      );

      bytes[] memory initCalls = new bytes[](4);
      initCalls[0] = addSetupEquippedExtension;
      initCalls[1] = addGetAllExtension;
      initCalls[2] = addTokenIdExtension;
      initCalls[3] = removeTokenIdExtension;

      bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, initCalls);

      token = tokenFactory.createERC1155(
        payable(erc1155Rails),
        caller,
        "Noun Citizens",
        "NPC",
        initData
      );
      vm.stopPrank();
    }

    function test_TokenSetupSanityCheck() public {
      assertEq(ERC1155Rails(token).name(), "Noun Citizens");
    }

    function test_GetEquippedTokenIdShouldBeEmpty() public {
      assertEq(IEquippableExtension(token).ext_getEquippedTokenIds(caller).length, 0);
    }

    function test_AddTokenId() public {
      vm.startPrank(caller);
      IERC1155Rails(token).mintTo(caller, 1, 1);
      IEquippableExtension(token).ext_addTokenId(caller, 1, 0);
      assertEq(IEquippableExtension(token).ext_getEquippedTokenIds(caller).length, 1);
      assertEq(IEquippableExtension(token).ext_getEquippedTokenIds(caller)[0], 1);
      vm.stopPrank();
    }

    function test_AddMultipleTokenIds() public {
      vm.startPrank(caller);
      IERC1155Rails(token).mintTo(caller, 1, 1);
      IERC1155Rails(token).mintTo(caller, 2, 1);
      IEquippableExtension(token).ext_addTokenId(caller, 1, 0);
      IEquippableExtension(token).ext_addTokenId(caller, 2, 1);
      assertEq(IEquippableExtension(token).ext_getEquippedTokenIds(caller).length, 2);
      assertEq(IEquippableExtension(token).ext_getEquippedTokenIds(caller)[0], 1);
      assertEq(IEquippableExtension(token).ext_getEquippedTokenIds(caller)[1], 2);
      vm.stopPrank();
    }

    function test_RemoveTokenId() public {
      vm.startPrank(caller);
      IERC1155Rails(token).mintTo(caller, 1, 1);
      IEquippableExtension(token).ext_addTokenId(caller, 1, 0);
      assertEq(IEquippableExtension(token).ext_getEquippedTokenIds(caller).length, 1);
      assertEq(IEquippableExtension(token).ext_getEquippedTokenIds(caller)[0], 1);
      IEquippableExtension(token).ext_removeTokenId(caller, 1);
      assertEq(IEquippableExtension(token).ext_getEquippedTokenIds(caller).length, 0);
      vm.stopPrank();
    }

    function test_RemoveFromMiddle() public {
      vm.startPrank(caller);
      IERC1155Rails(token).mintTo(caller, 1, 1);
      IERC1155Rails(token).mintTo(caller, 2, 1);
      IERC1155Rails(token).mintTo(caller, 3, 1);
      IEquippableExtension(token).ext_addTokenId(caller, 1, 0);
      IEquippableExtension(token).ext_addTokenId(caller, 2, 1);
      IEquippableExtension(token).ext_addTokenId(caller, 3, 2);
      assertEq(IEquippableExtension(token).ext_getEquippedTokenIds(caller).length, 3);
      assertEq(IEquippableExtension(token).ext_getEquippedTokenIds(caller)[0], 1);
      assertEq(IEquippableExtension(token).ext_getEquippedTokenIds(caller)[1], 2);
      assertEq(IEquippableExtension(token).ext_getEquippedTokenIds(caller)[2], 3);
      IEquippableExtension(token).ext_removeTokenId(caller, 2);
      assertEq(IEquippableExtension(token).ext_getEquippedTokenIds(caller).length, 2);
      assertEq(IEquippableExtension(token).ext_getEquippedTokenIds(caller)[0], 1);
      assertEq(IEquippableExtension(token).ext_getEquippedTokenIds(caller)[1], 3);
      vm.stopPrank();
    }

    // possibly deprecating this...
    // function test_SetupEquipped() public {
    //   uint256[] memory tokenIds = new uint256[](2);
    //   tokenIds[0] = 1;
    //   tokenIds[1] = 2;
    //   IEquippableExtension(address(equippableExtension)).ext_setupEquipped(caller, tokenIds);
    //   assertEq(IEquippableExtension(address(equippableExtension)).ext_getEquippedTokenIds(caller).length, 2);
    // }
}
