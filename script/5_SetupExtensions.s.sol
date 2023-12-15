// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import { ITokenMetadataExtension } from "../src/extensions/tokenMetadata/ITokenMetadataExtension.sol";

/// -----------------
/// SCRIPTS
/// -----------------
// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $GOERLI_RPC_URL script/5_SetupExtensions.s.sol:Deploy

contract Deploy is Script {
    address public erc1155tokenContract = 0x7f039ADCc26f97ac65133973695A355eF94619B1;
    address public npc721TokenContract = 0x5Cb66EeB32A4fAE5C4f87FC8e3d03d5b7c15bf50;
    address public erc6551Registry = 0x000000006551c19487814612e58FE06813775758;
    address public erc6551AccountImpl = 0x41C8f39463A868d3A88af00cd0fe7102F30E44eC;
    address public easel = 0x08698193B4581d39D8B8d955D7703d14Ef86c458;

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
