// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import { Easel } from "../src/Easel.sol";
import { EquippableExtension } from "../src/extensions/equippable/EquippableExtension.sol";
import { RegistryExtension } from "../src/extensions/registry/RegistryExtension.sol";

/// -----------------
/// SCRIPTS
/// -----------------
// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $GOERLI_RPC_URL script/0_DeployIndependentExtensions.s.sol:Deploy
// forge verify-contract --chain 5 --etherscan-api-key $ETHERSCAN_API_KEY 0x31Ad4E29Eb81aC275bD6B61cbeA417ffF7d81F76 src/extensions/equippable/EquippableExtension.sol:EquippableExtension --watch
// forge verify-contract --chain 5 --etherscan-api-key $ETHERSCAN_API_KEY 0xDA206772674FDd37554B5B157168BA2CcA8D1bB2 src/extensions/registry/RegistryExtension.sol:RegistryExtension --watch
// forge verify-contract --chain 5 --etherscan-api-key $ETHERSCAN_API_KEY 0xF0c5255799b29439c121f0Db6DFb969578d55f24 src/Easel.sol:Easel --watch


/// -----------------
/// FINAL CONTRACT ADDRESSES
/// -----------------
/// address registryExtension = 0x30E10657bb6F4D7E9069C402744462901583B7F6;
/// address equippableExtension = 0xfE803c0228fd503C31c7Cb7f8d5E91af55804f3f;
/// address easel = 0x08698193B4581d39D8B8d955D7703d14Ef86c458;


/// @notice Script for deploying the "independent" extensions -- aka the extensions that do not have any dependencies.
contract Deploy is Script {
    function run() public {
        vm.startBroadcast();
        RegistryExtension registryExtension = new RegistryExtension();
        EquippableExtension equippableExtension = new EquippableExtension();
        Easel easel = new Easel();
        vm.stopBroadcast();
    }
}
