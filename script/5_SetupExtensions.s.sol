// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import { IBaseMetadataExtension } from "../src/extensions/baseMetadata/IBaseMetadataExtension.sol";
import { ITraitMetadataExtension } from "../src/extensions/traitMetadata/ITraitMetadataExtension.sol";
import { ERC1155Rails } from "0xrails/cores/ERC1155/ERC1155Rails.sol";

/// -----------------
/// SCRIPTS
/// -----------------
// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $SEPOLIA_RPC_URL script/5_SetupExtensions.s.sol:Deploy

contract Deploy is Script {
    address public erc1155tokenContract = 0x8F071320A60E4Aac7dA5FBA5F201F9bcc66f86e9;
    address public npc721TokenContract = 0xF1eFc9e4C5238C5bCf3d30774480325893435a2A;
    address public erc6551Registry = 0x000000006551c19487814612e58FE06813775758;
    address public erc6551AccountImpl = 0x41C8f39463A868d3A88af00cd0fe7102F30E44eC;
    address public easel = 0x74c3DbC26278bc2Ef8C7ff1cb7ece926c17adB0a;
    address public equipTransferGuard = 0x74c3DbC26278bc2Ef8C7ff1cb7ece926c17adB0a;

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
