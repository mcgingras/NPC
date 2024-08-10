// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import { ERC20Rails } from "0xrails/cores/ERC20/ERC20Rails.sol";
import { ERC721Rails } from "0xrails/cores/ERC721/ERC721Rails.sol";
import { ERC1155Rails } from "0xrails/cores/ERC1155/ERC1155Rails.sol";
import { TokenFactory } from "groupos/factory/TokenFactory.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";




// 84532
/// -----------------
/// SCRIPTS
/// -----------------
// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $BASE_SEPOLIA_RPC_URL script/x_DeployRails.s.sol:Deploy
// forge verify-contract --chain 84532 --etherscan-api-key $ETHERSCAN_API_KEY 0x31Ad4E29Eb81aC275bD6B61cbeA417ffF7d81F76 src/extensions/equippable/EquippableExtension.sol:EquippableExtension --watch
// forge verify-contract --chain 84532 --etherscan-api-key $ETHERSCAN_API_KEY 0xDA206772674FDd37554B5B157168BA2CcA8D1bB2 src/extensions/registry/RegistryExtension.sol:RegistryExtension --watch
// forge verify-contract --chain 84532 --etherscan-api-key $ETHERSCAN_API_KEY 0xF0c5255799b29439c121f0Db6DFb969578d55f24 src/Easel.sol:Easel --watch

/// -----------------
/// FINAL CONTRACT ADDRESSES
/// -----------------
/// address registryExtension = 0x92ee25B0f5aBE7e9477D357314bF5ffd8CD52c1F;
/// address equippableExtension = 0x95AD1fA839105Fccc699Fa0a38c644cBFD30599e;
/// address easel = 0x9320Fc9A6DE47A326fBd12795Ba731859360cdaD;
/// address equipTransferGuard = 0x0512105FC31bd1a35C48289908de89D9412B3d94;

/// @notice Script for deploying the "independent" extensions -- aka the extensions that do not have any dependencies.


//   erc20Rails @0x4adcaacba2541c508020335567608f789d852956
//   erc721Rails @0xb43401be3d96e22b259efb0656d6adabe5eaa6cf
//   erc1155Rails @0x558ead6671fde2563bbb2ae454765904879aadc6
//   tokenFactoryImpl @0xa24A4b9873372CC51e5FeDEEBdAB9d3Fc5A089B0
//   tokenFactoryProxy @0x43fB252f9E2C64e532aB879B2153d6B717dE1C43

contract Deploy is Script {
    function logAddress(string memory name, string memory deployment) internal view {
        console2.logString(string.concat(name, deployment));
    }

    function run() public {
        vm.startBroadcast();
        address _owner = 0x65A3870F48B5237f27f674Ec42eA1E017E111D63;
        // ERC20Rails erc20Rails = ERC20Rails(0x4adcaacba2541c508020335567608f789d852956);
        // ERC721Rails erc721Rails = ERC721Rails(0xb43401be3d96e22b259efb0656d6adabe5eaa6cf);
        // ERC1155Rails erc1155Rails = ERC1155Rails(0x558ead6671fde2563bbb2ae454765904879aadc6);
        TokenFactory tokenFactoryImpl = TokenFactory(0xa24A4b9873372CC51e5FeDEEBdAB9d3Fc5A089B0);
        bytes memory tokenFactoryInitData = abi.encodeWithSelector(TokenFactory.initialize.selector, _owner, 0x4adcAACBA2541c508020335567608f789d852956, 0xb43401Be3d96E22b259EFB0656d6aDaBE5Eaa6cF, 0x558eAd6671fdE2563bBB2AE454765904879aAdC6);
        address tokenFactoryProxy = address(new ERC1967Proxy(address(tokenFactoryImpl), tokenFactoryInitData));

        // logAddress("erc20Rails @", Strings.toHexString(address(erc20Rails)));
        // logAddress("erc721Rails @", Strings.toHexString(address(erc721Rails)));
        // logAddress("erc1155Rails @", Strings.toHexString(address(erc1155Rails)));
        logAddress("tokenFactoryProxy @", Strings.toHexString(tokenFactoryProxy));
        // logAddress("tokenFactoryImpl @", Strings.toHexString(address(tokenFactoryImpl)));
        vm.stopBroadcast();
    }
}
