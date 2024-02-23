// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import { IPermissions } from "0xrails/access/permissions/interface/IPermissions.sol";
import { FeeManager } from "../src/modules/FeeManager.sol";
import { FreeMintController } from "../src/modules/FreeMintController.sol";

/// -----------------
/// SCRIPTS
/// -----------------
// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $SEPOLIA_RPC_URL script/6_AddMintController.s.sol:Deploy

// -- FreeMintController = 0xDF5BB9e221c2Ee30a8EA0AD693B85E10B55fE951
// -- FeeMananger = 0xC1A5fA81B1C0768c73242e6891e3032C360B8821

contract Deploy is Script {
    address public erc1155tokenContract = 0x8F071320A60E4Aac7dA5FBA5F201F9bcc66f86e9;
    address public erc721tokenContract = 0xF1eFc9e4C5238C5bCf3d30774480325893435a2A;
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
