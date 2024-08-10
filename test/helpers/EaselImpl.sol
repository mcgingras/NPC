// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { Easel } from "../../src/Easel.sol";
import { IEasel } from "../../src/interfaces/IEasel.sol";

/// @title EaselImpl
/// @author frog @0xmcg
/// @notice Creates a Easel
contract EaselImpl is Test {
    Easel public easel;
    string public file;
    uint8 paletteIndex = 0;

    constructor() {
      easel = new Easel();
      file = readInput("image-data-v1");
      addColorsToEasel(".palette");
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

    function getEasel() public view returns (Easel) {
      return easel;
    }
}
