// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import { IRegistryExtension } from "../src/extensions/registry/IRegistryExtension.sol";

/// -----------------
/// SCRIPTS
/// -----------------
// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $BASE_SEPOLIA_RPC_URL script/4_AddTraits.s.sol:Deploy

contract Deploy is Script {
    address public erc1155tokenContract = 0xb185d82B82257994c4f252Cc094385657370083b;

    struct Trait {
      bytes rleBytes;
      string filename;
    }

    string public file;

    function setUp() public {
      file = readInput("image-data-v1");
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
      uint256 limit = 10;
    //   decode.length
      for (uint256 i = 0; i < limit; i++) {
        Trait memory trait = decode[i];
        IRegistryExtension(erc1155tokenContract).ext_registerTrait(trait.rleBytes, trait.filename);
      }
    }

    function run() public {
      vm.startBroadcast();
      // It helps if you comment these out and do them 1 at a time
      addTraitsToRegistry(".images.bodies");
    //   addTraitsToRegistry(".images.accessories");
    //   addTraitsToRegistry(".images.heads");
    //   addTraitsToRegistry(".images.glasses");
      vm.stopBroadcast();
    }
}
