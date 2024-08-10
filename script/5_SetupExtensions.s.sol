// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import { IBaseMetadataExtension } from "../src/extensions/baseMetadata/IBaseMetadataExtension.sol";
import { ITraitMetadataExtension } from "../src/extensions/traitMetadata/ITraitMetadataExtension.sol";
import { ERC1155Rails } from "0xrails/cores/ERC1155/ERC1155Rails.sol";

/// -----------------
/// SCRIPTS
/// -----------------
// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $BASE_SEPOLIA_RPC_URL script/5_SetupExtensions.s.sol:Deploy

contract Deploy is Script {
    address public erc1155tokenContract = 0xb185d82B82257994c4f252Cc094385657370083b;
    address public npc721TokenContract = 0x0AEA8ce800c5609e61E799648195620d1B62B3fd;
    address public erc6551Registry = 0x000000006551c19487814612e58FE06813775758;
    address public erc6551AccountImpl = 0x41C8f39463A868d3A88af00cd0fe7102F30E44eC;
    address public easel = 0x9320Fc9A6DE47A326fBd12795Ba731859360cdaD;
    address public equipTransferGuard = 0x0512105FC31bd1a35C48289908de89D9412B3d94;

    function run() public {
      vm.startBroadcast();

      /// setup base NFT metadata extension
      IBaseMetadataExtension(npc721TokenContract).ext_setup(
        address(erc6551Registry),
        address(easel),
        erc1155tokenContract,
        address(erc6551AccountImpl),
        block.chainid,
        bytes32(0)
      );

      /// setup trait NFT metadata extension
      ITraitMetadataExtension(erc1155tokenContract).ext_setup(address(easel));

      /// add transfer guard to trait
      /// @dev 0x5cc15eb80ba37777 -> transfer
      ERC1155Rails(payable(erc1155tokenContract)).setGuard(hex"5cc15eb80ba37777", address(equipTransferGuard));

      vm.stopBroadcast();
    }
}
