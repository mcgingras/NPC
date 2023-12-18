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
/// address tokenMetadataExtension = 0xE4AbEdA33F1B040AAd17Babd8dC9Ab6eB686AD58;
/// address metadataExtension = 0x3cA34E441F12c914f7B29A3F60604DBE410EC58f;

contract Deploy is Script {
    function run() public {
        vm.startBroadcast();
        address easel = 0xA074f5520B8A40A85c49f9EAA5B66915F89892db;
        address erc6551Registry = 0x000000006551c19487814612e58FE06813775758;
        TokenMetadataExtension tokenMetadataExtension = new TokenMetadataExtension(easel, erc6551Registry);
        MetadataExtension metadataExtension = new MetadataExtension(address(easel));
        vm.stopBroadcast();
    }
}
