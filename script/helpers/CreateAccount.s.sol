// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import { ERC6551Registry } from "../../src/ERC6551Registry.sol";

/// -----------------
/// SCRIPTS
/// -----------------
// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $GOERLI_RPC_URL script/helpers/CreateAccount.s.sol:Deploy

/// tba - tokenId
/// 0xB55A435251992d8EDD70B6251b48dD3C1f03afC9 - 1


/// @notice Script for creating 6551 accounts
contract Deploy is Script {
    address public registry = 0x000000006551c19487814612e58FE06813775758;
    address public simpleAccountImplementation = 0x41C8f39463A868d3A88af00cd0fe7102F30E44eC;
    address public NPC721 = 0x30512C982e4461521E26812401C848b44d6cC36F;
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
