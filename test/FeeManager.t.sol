// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { FeeManager } from "../src/modules/FeeManager.sol";


/// @title FeeManagerTest
/// @author frog @0xmcg
/// @notice Tests for FeeManger contract.
contract FeeManagerTest is Test {
  FeeManager public feeManager;
  address public caller = address(1);
  address public fakeCollection = address(2);

  function setUp() public {
    vm.startPrank(caller);
    feeManager = new FeeManager(caller, .001 ether);
    vm.stopPrank();
  }

  function test_getFeesExpectDefault() public {
    vm.startPrank(caller);
    assertEq(feeManager.getFeeTotals(fakeCollection), .001 ether);
    vm.stopPrank();
  }

  function test_getFeesExpectCollection() public {
    vm.startPrank(caller);
    feeManager.setCollectionFees(fakeCollection, .002 ether);
    assertEq(feeManager.getFeeTotals(fakeCollection), .002 ether);
    vm.stopPrank();
  }

  function test_getFeesAfterRemovingCollection() public {
    vm.startPrank(caller);
    feeManager.setCollectionFees(fakeCollection, .002 ether);
    feeManager.removeCollectionFees(fakeCollection);
    assertEq(feeManager.getFeeTotals(fakeCollection), .001 ether);
    vm.stopPrank();
  }

  function test_setDefaultFeesAsOwner() public {
    vm.startPrank(caller);
    feeManager.setDefaultFees(.003 ether);
    assertEq(feeManager.getFeeTotals(fakeCollection), .003 ether);
    vm.stopPrank();
  }

  function test_setDefaultFeesAsNonOwner() public {
    vm.startPrank(address(3));
    vm.expectRevert("Ownable: caller is not the owner");
    feeManager.setDefaultFees(.004 ether);
    vm.stopPrank();
  }
}