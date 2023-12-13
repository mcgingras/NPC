// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import { IERC1155Rails } from "0xrails/cores/ERC1155/interface/IERC1155Rails.sol";
import { IEquippableExtension } from "../../src/extensions/equippable/IEquippableExtension.sol";

/// -----------------
/// SCRIPTS
/// -----------------
// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $GOERLI_RPC_URL script/helpers/MintAndEquipTrait.s.sol:Deploy


/// @notice Script for minting trait token and equipping it to a tba
contract Deploy is Script {
    address public Trait1155 = 0x34914c7c6Bd75c1C69e14F50CE5285c2F5335e5c;
    // UPDATE THIS WHEN YOU DEPLOY FOR NEW ACCOUNTS!
    address public tbaAddress = 0x77F19999120B87b2254b4C31D4d2A12833dCA390;
    uint256 public tokenId = 1;


    function run() public {
        vm.startBroadcast();
        IERC1155Rails(Trait1155).mintTo(tbaAddress, tokenId, 1);
        IEquippableExtension(Trait1155).ext_addTokenId(tbaAddress, tokenId, 0);
        vm.stopBroadcast();
    }
}