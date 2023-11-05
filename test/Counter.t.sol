// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import { ERC721 } from "openzeppelin-contracts/token/ERC721/ERC721.sol";
import { ERC6551Registry } from "erc6551/ERC6551Registry.sol";
import { ERC6551Account } from "erc6551/examples/simple/ERC6551Account.sol";
import { ERC6551AccountProxy } from "erc6551/examples/upgradeable/ERC6551AccountProxy.sol";
import { ERC6551AccountUpgradeable } from "erc6551/examples/upgradeable/ERC6551AccountUpgradeable.sol";

/// @title AccountTest
/// @author frog @0xmcg
/// @notice Tests for 6551 TBA contract and exploring various methods of creating account implementations.
contract AccountTest is Test {
    ERC721 public demoNFT;
    ERC6551Registry public registry;
    ERC6551Account public simpleAccountImplementation;
    address public caller = address(1);

    function setUp() public {
      vm.startPrank(caller);
      demoNFT = new ERC721("DemoNFT", "DNFT");
      registry = new ERC6551Registry();
      simpleAccountImplementation = new ERC6551Account();

      demoNFT._mint(caller, 1);
      vm.stopPrank();
      // maybe mint a token to the caller so we can test account related item activity.
    }

    /// @notice tests thr 6551 reference "simple" account
    // function test_simple() public {
    // }
}
