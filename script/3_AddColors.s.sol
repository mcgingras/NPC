// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import { IEasel } from "../src/interfaces/IEasel.sol";
import { IRegistryExtension } from "../src/extensions/registry/IRegistryExtension.sol";

/// -----------------
/// SCRIPTS
/// -----------------
// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $GOERLI_RPC_URL script/3_AddColors.s.sol:Deploy

contract Deploy is Script {
    address public easel = 0xF0c5255799b29439c121f0Db6DFb969578d55f24;
    string public file;
    uint8 paletteIndex = 0;

    function setUp() public {
      file = readInput("image-data-v2");
    }

    function readInput(string memory input) view internal returns (string memory) {
      string memory inputDir = string.concat(vm.projectRoot(), "/script/input/");
      string memory filePath = string.concat(input, ".json");
      return vm.readFile(string.concat(inputDir, filePath));
    }

    function addColorsToEasel(string memory path) public {
      bytes memory values = vm.parseJson(file, path);
      string[] memory newColors = abi.decode(values, (string[]));
      IEasel(easel).addManyColorsToPalette(paletteIndex, newColors);
    }

    function run() public {
     addColorsToEasel("palette");
    }
}