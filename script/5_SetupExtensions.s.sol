// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import { ITokenMetadataExtension } from "../src/extensions/tokenMetadata/ITokenMetadataExtension.sol";

/// -----------------
/// SCRIPTS
/// -----------------
// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $SEPOLIA_RPC_URL script/5_SetupExtensions.s.sol:Deploy

contract Deploy is Script {
    address public erc1155tokenContract = 0x8F071320A60E4Aac7dA5FBA5F201F9bcc66f86e9;
    address public npc721TokenContract = 0xF1eFc9e4C5238C5bCf3d30774480325893435a2A;
    address public erc6551Registry = 0x000000006551c19487814612e58FE06813775758;
    address public erc6551AccountImpl = 0x41C8f39463A868d3A88af00cd0fe7102F30E44eC;
    address public easel = 0x74c3DbC26278bc2Ef8C7ff1cb7ece926c17adB0a;

    function run() public {
      vm.startBroadcast();
      ITokenMetadataExtension(npc721TokenContract).ext_setup(
        address(erc6551Registry),
        address(easel),
        erc1155tokenContract,
        address(erc6551AccountImpl),
        block.chainid,
        bytes32(0)
      );
      vm.stopBroadcast();
    }
}
