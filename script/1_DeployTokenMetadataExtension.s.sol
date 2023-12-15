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
// forge verify-contract --chain 5 --etherscan-api-key $ETHERSCAN_API_KEY --constructor-args $(cast abi-encode "constructor(address,address)" "0xF0c5255799b29439c121f0Db6DFb969578d55f24" "0x000000006551c19487814612e58FE06813775758" 18 1000000000000000000000) 0x3A55ccb904a9AdA4dE1a9332993C5918B7845050 src/extensions/tokenMetadata/TokenMetadataExtension.sol:TokenMetadataExtension --watch
// forge verify-contract --chain 5 --etherscan-api-key $ETHERSCAN_API_KEY --constructor-args $(cast abi-encode "constructor(address)" "0xF0c5255799b29439c121f0Db6DFb969578d55f24" 18 1000000000000000000000) 0xc02745dB005ad04304C2058ecB0f5db74Cb12A32 src/extensions/metadata/MetadataExtension.sol:MetadataExtension --watch


/// -----------------
/// FINAL CONTRACT ADDRESSES
/// -----------------
/// address tokenMetadataExtension = 0x98B4754f8266274ed4Ea80B440f075e76d18Ac89;
/// address metadataExtension = 0x9E49D7F5b41F6a8CD59eeeD49fd06fD9F6eEc5d9;

contract Deploy is Script {
    function run() public {
        vm.startBroadcast();
        address easel = 0x08698193B4581d39D8B8d955D7703d14Ef86c458;
        address erc6551Registry = 0x000000006551c19487814612e58FE06813775758;
        TokenMetadataExtension tokenMetadataExtension = new TokenMetadataExtension(easel, erc6551Registry);
        MetadataExtension metadataExtension = new MetadataExtension(address(easel));
        vm.stopBroadcast();
    }
}
