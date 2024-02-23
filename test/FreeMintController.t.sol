// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { FeeManager } from "../src/modules/FeeManager.sol";
import { FreeMintController } from "../src/modules/FreeMintController.sol";
import { ERC721Rails } from "0xrails/cores/ERC721/ERC721Rails.sol";
import { IERC721Rails } from "0xrails/cores/ERC721/interface/IERC721Rails.sol";
import { ERC1155Rails } from "0xrails/cores/ERC1155/ERC1155Rails.sol";
import { IERC1155Rails } from "0xrails/cores/ERC1155/interface/IERC1155Rails.sol";
import { IPermissions } from "0xrails/access/permissions/interface/IPermissions.sol";
import { IERC721 } from "0xrails/cores/ERC721/interface/IERC721.sol";
import { IERC1155 } from "0xrails/cores/ERC1155/interface/IERC1155.sol";
import { TokenFactory } from "groupos/factory/TokenFactory.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";


/// @title FreeMintControllerTest
/// @author frog @0xmcg
/// @notice Tests for FreeMintController contract.
contract FreeMintControllerTest is Test {
    TokenFactory public tokenFactoryImpl;
    TokenFactory public tokenFactoryProxy;
    ERC1155Rails public erc1155Rails;
    ERC721Rails public erc721Rails;
    address payable tokenContract1155;
    address payable tokenContract721;
    FeeManager public feeManager;
    FreeMintController public freeMintController;
    address public caller = address(1);
    address public feeRecipient1 = address(123);
    address public feeRecipient2 = address(456);
    bytes32 salt = 0x00000000;

    function setUp() public {
      vm.startPrank(caller);
      erc721Rails = new ERC721Rails();
      erc1155Rails = new ERC1155Rails();
      feeManager = new FeeManager(caller, .001 ether);
      address[] memory feeRecipients = new address[](2);
      feeRecipients[0] = feeRecipient1;
      feeRecipients[1] = feeRecipient2;
      freeMintController = new FreeMintController(caller, address(feeManager), feeRecipients);

      tokenFactoryImpl = new TokenFactory();
      tokenFactoryProxy = TokenFactory(address(new ERC1967Proxy(address(tokenFactoryImpl), '')));
      tokenFactoryProxy.initialize(caller, address(123), address(erc721Rails), address(erc1155Rails));

      tokenContract1155 = tokenFactoryProxy.createERC1155(
        payable(erc1155Rails),
        salt,
        caller,
        "NPC Trait",
        "NPCT",
        ""
      );

      tokenContract721 = tokenFactoryProxy.createERC721(
        payable(erc721Rails),
        salt,
        caller,
        "NPC Collection",
        "NPCC",
        ""
      );
      vm.stopPrank();
    }

    // not minting through module -- this is a sanity check
    function test_mintOwner() public {
      vm.startPrank(caller);
      IERC1155Rails(tokenContract1155).mintTo(caller, 1, 1);
      assertEq(IERC1155(tokenContract1155).balanceOf(caller, 1), 1);
      vm.stopPrank();
    }

    function test_mintNonOwner() public {
      vm.startPrank(address(2));
      vm.expectRevert();
      IERC1155Rails(tokenContract1155).mintTo(caller, 1, 1);
      vm.stopPrank();
    }

    function test_freeMintNotEnabledDoesNothing() public {
      vm.startPrank(address(2));
      vm.expectRevert();
      freeMintController.mint1155To(address(tokenContract1155), caller, 1);
      vm.stopPrank();
    }

    function test_freeMintModule721() public {
      vm.startPrank(caller);
      bytes8 mintPermission = hex"38381131ea27ecba";
      IPermissions(tokenContract721).addPermission(mintPermission, address(freeMintController));
      vm.stopPrank();

      vm.startPrank(address(2));
      vm.deal(address(2), 1 ether);
      freeMintController.mint721To{value: .001 ether}(address(tokenContract721), caller);
      assertEq(IERC721(tokenContract721).balanceOf(caller), 1);
      vm.stopPrank();
    }

    function test_freeMintModule1155() public {
      vm.startPrank(caller);
      bytes8 mintPermission = hex"38381131ea27ecba";
      IPermissions(tokenContract1155).addPermission(mintPermission, address(freeMintController));
      vm.stopPrank();

      vm.startPrank(address(2));
      vm.deal(address(2), 1 ether);
      freeMintController.mint1155To{value: .001 ether}(address(tokenContract1155), caller, 1);
      assertEq(IERC1155(tokenContract1155).balanceOf(caller, 1), 1);
      vm.stopPrank();
    }

    function test_withdrawFees() public {
      vm.startPrank(caller);
      // get eth balance of caller
      uint256 feeRecipient1Balance = address(feeRecipient1).balance;
      uint256 feeRecipient2Balance = address(feeRecipient2).balance;
      assertEq(feeRecipient1Balance, 0);
      assertEq(feeRecipient2Balance, 0);
      // add mint controller and mint
      bytes8 mintPermission = hex"38381131ea27ecba";
      IPermissions(tokenContract1155).addPermission(mintPermission, address(freeMintController));
      vm.deal(caller, 1 ether);
      freeMintController.mint1155To{value: .001 ether}(address(tokenContract1155), caller, 1);
      // withdraw fees
      freeMintController.withdrawFees();
      assertEq(address(feeRecipient1).balance, .0005 ether);
      assertEq(address(feeRecipient2).balance, .0005 ether);
      vm.stopPrank();
    }

    function test_withdrawFeesNotOwner() public {
      vm.startPrank(address(2));
      vm.expectRevert();
      freeMintController.withdrawFees();
      vm.stopPrank();
    }

    function test_mintBatch() public {
      vm.startPrank(caller);
      // add mint controller and mint
      bytes8 mintPermission = hex"38381131ea27ecba";
      IPermissions(tokenContract1155).addPermission(mintPermission, address(freeMintController));
      vm.deal(caller, 1 ether);
      uint256[] memory tokenIds = new uint256[](2);
      tokenIds[0] = 1;
      tokenIds[1] = 2;
      uint256[] memory amounts = new uint256[](2);
      amounts[0] = 1;
      amounts[1] = 1;
      // too low of fee for two mints
      vm.expectRevert();
      freeMintController.batchMint1155To{value: .001 ether}(address(tokenContract1155), caller, tokenIds, amounts);
      freeMintController.batchMint1155To{value: .002 ether}(address(tokenContract1155), caller, tokenIds, amounts);
      assertEq(IERC1155(tokenContract1155).balanceOf(caller, 1), 1);
      assertEq(IERC1155(tokenContract1155).balanceOf(caller, 2), 1);
      vm.stopPrank();
    }
}
