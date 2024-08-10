// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import { Easel } from "../src/Easel.sol";
import { BaseMetadataExtension } from "../src/extensions/baseMetadata/baseMetadataExtension.sol";
import { TraitMetadataExtension } from "../src/extensions/traitMetadata/TraitMetadataExtension.sol";
import { EquippableExtension } from "../src/extensions/equippable/EquippableExtension.sol";
import { RegistryExtension } from "../src/extensions/registry/RegistryExtension.sol";

// 13648447 block number
/// -----------------
/// SCRIPTS
/// -----------------
// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $BASE_SEPOLIA_RPC_URL script/1_DeployTokenMetadataExtension.s.sol:Deploy
// forge verify-contract --chain 84532 --etherscan-api-key $ETHERSCAN_API_KEY --constructor-args $(cast abi-encode "constructor(address,address)" "0xF0c5255799b29439c121f0Db6DFb969578d55f24" "0x000000006551c19487814612e58FE06813775758" 18 1000000000000000000000) 0x3A55ccb904a9AdA4dE1a9332993C5918B7845050 src/extensions/tokenMetadata/TokenMetadataExtension.sol:TokenMetadataExtension --watch
// forge verify-contract --chain 84532 --etherscan-api-key $ETHERSCAN_API_KEY --constructor-args $(cast abi-encode "constructor(address)" "0xF0c5255799b29439c121f0Db6DFb969578d55f24" 18 1000000000000000000000) 0xc02745dB005ad04304C2058ecB0f5db74Cb12A32 src/extensions/metadata/MetadataExtension.sol:MetadataExtension --watch

/// -----------------
/// FINAL CONTRACT ADDRESSES
/// -----------------
/// address baseMetadataExtension = 0x232f550a04e7bC128F5850a7EB8aaFe60F3A3faE;
/// address traitMetadataExtension = 0x35Ae03B8a2862B2AdD7Cd7730A51077240C46a1E;

contract Deploy is Script {
    function run() public {
        vm.startBroadcast();
        address easel = 0x9320Fc9A6DE47A326fBd12795Ba731859360cdaD;
        address erc6551Registry = 0x000000006551c19487814612e58FE06813775758;
        new BaseMetadataExtension(easel, erc6551Registry);
        new TraitMetadataExtension(address(easel));
        vm.stopBroadcast();
    }
}
