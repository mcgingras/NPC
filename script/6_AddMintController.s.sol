// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import { IPermissions } from "0xrails/access/permissions/interface/IPermissions.sol";
import { FeeManager } from "../src/modules/FeeManager.sol";
import { FreeMintController } from "../src/modules/FreeMintController.sol";

/// -----------------
/// SCRIPTS
/// -----------------
// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $BASE_SEPOLIA_RPC_URL script/6_AddMintController.s.sol:Deploy

// -- FreeMintController = 0x2C30c5E187145Fbbf595bB623939FEF639ed4600
// -- FeeMananger = 0xf3947789Cb449C001C22a055761bab65Af5AA33E

contract Deploy is Script {
    address public erc1155tokenContract = 0xb185d82B82257994c4f252Cc094385657370083b;
    address public erc721tokenContract = 0x0AEA8ce800c5609e61E799648195620d1B62B3fd;
    FeeManager public feeManager;
    FreeMintController public freeMintController;

    function run() public {
        vm.startBroadcast();
        feeManager = new FeeManager(msg.sender, .001 ether);
        address[] memory feeRecipients = new address[](2);
        feeRecipients[0] = address(0x65A3870F48B5237f27f674Ec42eA1E017E111D63);
        feeRecipients[1] = address(0x55045DA52be49461aF91a235E4303D4a9B2312AE);
        freeMintController = new FreeMintController(msg.sender, address(feeManager), feeRecipients);
        bytes8 mintPermission = hex"38381131ea27ecba";
        IPermissions(erc1155tokenContract).addPermission(mintPermission, address(freeMintController));
        IPermissions(erc721tokenContract).addPermission(mintPermission, address(freeMintController));
        vm.stopBroadcast();
    }
}
