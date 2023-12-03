// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import { ERC6551Registry } from "../../src/ERC6551Registry.sol";

/// -----------------
/// SCRIPTS
/// -----------------
// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $GOERLI_RPC_URL script/helpers/CreateAccount.s.sol:Deploy

/// tba - tokenId
/// 0x1dcdbd35c21eB88172F154cad0100896e8B4327d - 1


/// @notice Script for creating 6551 accounts
contract Deploy is Script {
    address public registry = 0x000000006551c19487814612e58FE06813775758;
    address public simpleAccountImplementation = 0x41C8f39463A868d3A88af00cd0fe7102F30E44eC;
    address public NPC721 = 0x28aAF781E430E5Ab48DDb44aEF0D621c0d0f0342;
    bytes32 public salt = bytes32(0);
    uint256 public chainId = 5;
    // UPDATE THIS WHEN YOU DEPLOY FOR NEW ACCOUNTS!
    uint256 public tokenId = 1;

    function run() public {
        vm.startBroadcast();
        address payable tbaAddress = payable(ERC6551Registry(registry).createAccount(
          address(simpleAccountImplementation),
          salt,
          chainId,
          address(NPC721),
          tokenId
        ));
        vm.stopBroadcast();
    }
}
