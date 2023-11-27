// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import { Easel } from "../src/Easel.sol";
import { TokenMetadataExtension } from "../src/extensions/tokenMetadata/tokenMetadataExtension.sol";
import { MetadataExtension } from "../src/extensions/metadata/MetadataExtension.sol";
import { EquippableExtension } from "../src/extensions/equippable/EquippableExtension.sol";
import { RegistryExtension } from "../src/extensions/registry/RegistryExtension.sol";

/// -----------------
/// SCRIPTS
/// -----------------
// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $GOERLI_RPC_URL script/1_DeployTokenMetadataExtension.s.sol:Deploy
// forge verify-contract --chain 5 --etherscan-api-key $ETHERSCAN_API_KEY 0xb7539fbfcbe9e64e85ea865980cd47e0962aae6d src/Character.sol:Character


/// -----------------
/// FINAL CONTRACT ADDRESSES
/// -----------------
/// address tokenMetadataExtension = 0x3A55ccb904a9AdA4dE1a9332993C5918B7845050;
/// address metadataExtension = 0xc02745dB005ad04304C2058ecB0f5db74Cb12A32;

contract Deploy is Script {
    function run() public {
        vm.startBroadcast();
        address easel = 0xF0c5255799b29439c121f0Db6DFb969578d55f24;
        address erc6551Registry = 0x000000006551c19487814612e58FE06813775758;
        TokenMetadataExtension tokenMetadataExtension = new TokenMetadataExtension(easel, erc6551Registry);
        MetadataExtension metadataExtension = new MetadataExtension(address(easel));
        vm.stopBroadcast();
    }
}
