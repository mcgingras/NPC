// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { TraitRegistry } from "../src/TraitRegistry.sol";


/// @title TraitRegistryTest
/// @author frog @0xmcg
/// @notice Tests for TraitRegistry contract.
contract TraitRegistryTest is Test {
    TraitRegistry public traitRegistry;
    address public caller = address(1);


    function setUp() public {
      vm.startPrank(caller);
      traitRegistry = new TraitRegistry();
      vm.stopPrank();
    }

    // test -- what happens if we try to mint for a token that is not yet registered?

    function test_RegisterTrait() public {
      vm.startPrank(caller);
      bytes memory rleBytes = abi.encodePacked(uint8(1), uint8(2), uint8(3));
      traitRegistry.registerTrait(rleBytes);

      assertEq(traitRegistry.traitIdCount(), 1);
      assertEq(traitRegistry.getRleBytesForTrait(0), rleBytes);
      vm.stopPrank();
    }

    function test_Mint() public {
      vm.startPrank(caller);
      traitRegistry.mint(caller, 0, 1, "");
      assertEq(traitRegistry.balanceOf(caller, 0), 1);
    }

    function test_TokensOfOwnerSingleMint() public {
      vm.startPrank(caller);
      traitRegistry.mint(caller, 0, 1, "");
      uint256[] memory tokens = traitRegistry.tokensOfOwner(caller);
      assertEq(tokens.length, 1);
      vm.stopPrank();
    }

    /// despite minting twice, the owner should only have one token (with balance of two).
    function test_TokensOfOwnerDoubleMintOfSameToken() public {
      vm.startPrank(caller);
      traitRegistry.mint(caller, 0, 1, "");
      traitRegistry.mint(caller, 0, 1, "");
      uint256[] memory tokens = traitRegistry.tokensOfOwner(caller);
      assertEq(tokens.length, 1);
      vm.stopPrank();
    }

    function test_TokensOfOwnerDoubleMintOfDifferentTokens() public {
      vm.startPrank(caller);
      traitRegistry.mint(caller, 0, 1, "");
      traitRegistry.mint(caller, 1, 1, "");
      uint256[] memory tokens = traitRegistry.tokensOfOwner(caller);
      assertEq(tokens.length, 2);
      vm.stopPrank();
    }
}
