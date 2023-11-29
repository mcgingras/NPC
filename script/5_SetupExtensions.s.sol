// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import { ITokenMetadataExtension } from "../src/extensions/tokenMetadata/ITokenMetadataExtension.sol";

/// -----------------
/// SCRIPTS
/// -----------------
// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $GOERLI_RPC_URL script/5_SetupExtensions.s.sol:Deploy

contract Deploy is Script {
    address public erc1155tokenContract = 0x4E2B820D5679CcfEAbe33Cf67872BCaE9df898dE;
    address public npc721TokenContract = 0x30512C982e4461521E26812401C848b44d6cC36F;
    address public erc6551Registry = 0x000000006551c19487814612e58FE06813775758;
    address public erc6551AccountImpl = 0x41C8f39463A868d3A88af00cd0fe7102F30E44eC;
    address public easel = 0xF0c5255799b29439c121f0Db6DFb969578d55f24;

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
