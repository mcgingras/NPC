// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import { ITokenMetadataExtension } from "../src/extensions/tokenMetadata/ITokenMetadataExtension.sol";

/// -----------------
/// SCRIPTS
/// -----------------
// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $GOERLI_RPC_URL script/5_SetupExtensions.s.sol:Deploy

contract Deploy is Script {
    address public erc1155tokenContract = 0x810cdD881Db44eE29747CB44516fD69185e02b2F;
    address public npc721TokenContract = 0xC2c16A16Bcb774663a84C44a960693E73F273617;
    address public erc6551Registry = 0x000000006551c19487814612e58FE06813775758;
    address public erc6551AccountImpl = 0x41C8f39463A868d3A88af00cd0fe7102F30E44eC;
    address public easel = 0xA074f5520B8A40A85c49f9EAA5B66915F89892db;

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
