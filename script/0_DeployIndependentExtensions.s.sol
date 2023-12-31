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
/// address registryExtension = 0x8c3Ef0d04395861c31C2Fc2EE4c7F9bc9BE319B4;
/// address equippableExtension = 0x5924b8fC00b388BC1D6B4a4091253ec517e783b3;
/// address easel = 0xA074f5520B8A40A85c49f9EAA5B66915F89892db;


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
