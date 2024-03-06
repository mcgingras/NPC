// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IGuard } from "0xrails/guard/interface/IGuard.sol";
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
import { EquipTransferGuard } from "../src/guards/EquipGuard.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

/// @title EquipGuardTest
/// @author frog @0xmcg
/// @notice Tests guard on transfer
contract EquipGuardTest is Test {
    address public caller = address(1);
    address public recipient = address(2);
    address public fake = address(3);
    EquippableExtension public equippableExtension = new EquippableExtension();
    TokenFactory public tokenFactoryImpl;
    TokenFactory public tokenFactoryProxy;
    ERC1155Rails public erc1155Rails = new ERC1155Rails();
    EquipTransferGuard public equipGuard = new EquipTransferGuard();
    address payable token;
    bytes32 salt = 0x00000000;

    function setUp() public {
      vm.startPrank(caller);
      tokenFactoryImpl = new TokenFactory();
      tokenFactoryProxy = TokenFactory(address(new ERC1967Proxy(address(tokenFactoryImpl), '')));
      tokenFactoryProxy.initialize(caller, fake, fake, address(erc1155Rails));

      bytes memory addGetAllExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IEquippableExtension.ext_getEquippedTokenIds.selector, address(equippableExtension)
      );

      bytes memory addTokenIdExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IEquippableExtension.ext_addTokenId.selector, address(equippableExtension)
      );

      bytes memory addIsTokenIdEquippedExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IEquippableExtension.ext_isTokenIdEquipped.selector, address(equippableExtension)
      );

      bytes[] memory initCalls = new bytes[](3);
      initCalls[0] = addGetAllExtension;
      initCalls[1] = addTokenIdExtension;
      initCalls[2] = addIsTokenIdEquippedExtension;

      bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, initCalls);

      token = tokenFactoryProxy.createERC1155(
        payable(erc1155Rails),
        salt,
        caller,
        "Noun Citizens",
        "NPC",
        initData
      );
      vm.stopPrank();
    }

    /// @notice Test that the guard is set
    /// This means that the guard is set on the transfer tx type
    /// @dev 0x5cc15eb80ba37777 -> transfer
    function test_setGuardSanityCheck() public {
      vm.startPrank(caller);
      ERC1155Rails(token).setGuard(hex"5cc15eb80ba37777", address(equipGuard));
      assertEq(ERC1155Rails(token).guardOf(hex"5cc15eb80ba37777"), address(equipGuard));
      vm.stopPrank();
    }

    /// @notice
    /// The transfer should work fine because the token is not equipped
    /// The transfer guard only prevents transfers of an equipped token
    function test_transferNotBlockedBecauseTokenNotEquipped() public {
      vm.startPrank(caller);
      ERC1155Rails(token).setGuard(hex"5cc15eb80ba37777", address(equipGuard));
      ERC1155Rails(token).mintTo(caller, 1, 1);
      ERC1155Rails(token).safeTransferFrom(caller, recipient, 1, 1, "");

      assertEq(ERC1155Rails(token).balanceOf(caller, 1), 0);
      assertEq(ERC1155Rails(token).balanceOf(recipient, 1), 1);
      vm.stopPrank();
    }

    /// @notice
    /// The transfer should be blocked because the token is equipped
    function test_transferBlockedBecauseTokenIsEquipped() public {
      vm.startPrank(caller);
      ERC1155Rails(token).setGuard(hex"5cc15eb80ba37777", address(equipGuard));
      ERC1155Rails(token).mintTo(caller, 1, 1);
      IEquippableExtension(token).ext_addTokenId(caller, 1, 0);

      vm.expectRevert("Cannot transfer equipped token.");
      ERC1155Rails(token).safeTransferFrom(caller, recipient, 1, 1, "");
      vm.stopPrank();
    }

    /// @notice
    /// If the user has > 1 of the same token, the transfer should not be blocked
    /// You should be able to transfer n-1 of your n tokens (so you have 1 left to be equipped)
    function test_transferNotBlockedBecauseMoreThan1TokenOwned() public {
        vm.startPrank(caller);
        ERC1155Rails(token).setGuard(hex"5cc15eb80ba37777", address(equipGuard));
        ERC1155Rails(token).mintTo(caller, 1, 2);
        IEquippableExtension(token).ext_addTokenId(caller, 1, 0);
        ERC1155Rails(token).safeTransferFrom(caller, recipient, 1, 1, "");

        assertEq(ERC1155Rails(token).balanceOf(caller, 1), 1);
        assertEq(ERC1155Rails(token).balanceOf(recipient, 1), 1);
        vm.stopPrank();
    }
}
