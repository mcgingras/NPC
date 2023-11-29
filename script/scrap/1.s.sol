// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import { IEquippableExtension } from "../../src/extensions/equippable/IEquippableExtension.sol";
import { IRegistryExtension } from "../../src/extensions/registry/IRegistryExtension.sol";
import { MultiPartRLEToSVG } from "../../src/lib/MultiPartRLEToSVG.sol";
import { Easel } from "../../src/Easel.sol";


/// -----------------
/// SCRIPTS
/// -----------------
// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $GOERLI_RPC_URL script/scrap/1.s.sol:Deploy


/// @notice Script for creating 6551 accounts
contract Deploy is Script {
    address public tbaAddressForToken = 0xB55A435251992d8EDD70B6251b48dD3C1f03afC9;
    address public traitContractAddress = 0x4E2B820D5679CcfEAbe33Cf67872BCaE9df898dE;
    address public easel = 0xF0c5255799b29439c121f0Db6DFb969578d55f24;

    function run() public {
        // vm.startBroadcast();
        uint256[] memory tokens = IEquippableExtension(traitContractAddress).ext_getEquippedTokenIds(tbaAddressForToken);
        bytes[] memory traitParts = new bytes[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
          uint256 traitId = tokens[i];
          traitParts[i] = IRegistryExtension(traitContractAddress).ext_getImageDataForTrait(traitId);
        }

        console2.log("traitParts", traitParts.length);
        string memory output = Easel(easel).generateSVGForParts(traitParts);
        console2.log(output);

        // vm.stopBroadcast();
    }
}
