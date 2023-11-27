// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import { IRegistryExtension } from "../src/extensions/registry/IRegistryExtension.sol";

/// -----------------
/// SCRIPTS
/// -----------------
// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $GOERLI_RPC_URL script/4_AddTraits.s.sol:Deploy

contract Deploy is Script {
    address public erc1155tokenContract = 0x4E2B820D5679CcfEAbe33Cf67872BCaE9df898dE;

    struct Trait {
      bytes rleBytes;
      string filename;
    }

    string public file;

    function setUp() public {
      file = readInput("image-data-v2");
    }

    function readInput(string memory input) view internal returns (string memory) {
      string memory inputDir = string.concat(vm.projectRoot(), "/script/input/");
      string memory filePath = string.concat(input, ".json");
      return vm.readFile(string.concat(inputDir, filePath));
    }

    function decodeImageType(string memory path) view internal returns (Trait[] memory) {
      bytes memory values = vm.parseJson(file, path);
      Trait[] memory decode = abi.decode(values, (Trait[]));
      return decode;
    }

    function addTraitsToRegistry(string memory path) public {
      Trait[] memory decode = decodeImageType(path);
      for (uint256 i = 0; i < decode.length; i++) {
        Trait memory trait = decode[i];
        IRegistryExtension(erc1155tokenContract).ext_registerTrait(trait.rleBytes, trait.filename);
      }
    }

    function run() public {
      addTraitsToRegistry("images.bodies");
      addTraitsToRegistry("images.accessories");
      addTraitsToRegistry("images.heads");
      addTraitsToRegistry("images.glasses");
    }
}
