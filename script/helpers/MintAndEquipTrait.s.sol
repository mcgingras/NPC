// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import { IERC1155Rails } from "0xrails/cores/ERC1155/interface/IERC1155Rails.sol";
import { IEquippableExtension } from "../../src/extensions/equippable/IEquippableExtension.sol";

/// -----------------
/// SCRIPTS
/// -----------------
// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $SEPOLIA_RPC_URL script/helpers/MintAndEquipTrait.s.sol:Deploy


/// @notice Script for minting trait token and equipping it to a tba
contract Deploy is Script {
    address public Trait1155 = 0x8F071320A60E4Aac7dA5FBA5F201F9bcc66f86e9;
    // UPDATE THIS WHEN YOU DEPLOY FOR NEW ACCOUNTS!
    address public tbaAddress = 0x35F8f5f92D4B51cc31e2E8b83e0C5393Ef1be274;
    uint256 public bodyTokenId = 1;
    uint256 public accessoryTokenId = 40;
    uint256 public headTokenId = 50;
    uint256 public glassesTokenId = 60;


    function run() public {
        vm.startBroadcast();
        // mints a body
        // IERC1155Rails(Trait1155).mintTo(tbaAddress, bodyTokenId, 1);
        // IEquippableExtension(Trait1155).ext_addTokenId(tbaAddress, bodyTokenId, 0);

        // mints a chain
        // IERC1155Rails(Trait1155).mintTo(tbaAddress, accessoryTokenId, 1);
        // IEquippableExtension(Trait1155).ext_addTokenId(tbaAddress, accessoryTokenId, bodyTokenId);

        // mints a head
        // IERC1155Rails(Trait1155).mintTo(tbaAddress, headTokenId, 1);
        // IEquippableExtension(Trait1155).ext_addTokenId(tbaAddress, headTokenId, accessoryTokenId);

        // mints glasses
        // IERC1155Rails(Trait1155).mintTo(tbaAddress, glassesTokenId, 1);
        // IEquippableExtension(Trait1155).ext_addTokenId(tbaAddress, glassesTokenId, headTokenId);

        IEquippableExtension(Trait1155).ext_removeTokenId(tbaAddress, glassesTokenId);
        vm.stopBroadcast();
    }
}
