// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import { MultiPartRLEToSVG } from "./lib/MultiPartRLEToSVG.sol";
import {IEasel} from './interfaces/IEasel.sol';

// new renderer?
// https://github.com/nounsDAO/nouns-monorepo/blob/master/packages/nouns-contracts/contracts/SVGRenderer.sol
contract Easel is IEasel {
    mapping(uint8 => string[]) public palettes;

    /**
     * @notice Add colors to a color palette.
     * @dev This function can only be called by the owner.
     */
    function addManyColorsToPalette(uint8 paletteIndex, string[] calldata newColors) external {
        require(palettes[paletteIndex].length + newColors.length <= 256, 'Palettes can only hold 256 colors');
        console2.log("length", newColors.length);
        for (uint256 i = 0; i < newColors.length; i++) {
            _addColorToPalette(paletteIndex, newColors[i]);
        }
    }

    /**
     * @notice Add a single color to a color palette.
     * @dev This function can only be called by the owner.
     */
    function addColorToPalette(uint8 _paletteIndex, string calldata _color) external {
        require(palettes[_paletteIndex].length <= 255, 'Palettes can only hold 256 colors');
        _addColorToPalette(_paletteIndex, _color);
    }

    /**
     * @notice Add a single color to a color palette.
     */
    function _addColorToPalette(uint8 _paletteIndex, string calldata _color) internal {
        palettes[_paletteIndex].push(_color);
    }

    /**
     * @notice Generate an SVG from a set of parts.
     */
    function generateSVGForParts(bytes[] memory parts) public view returns (string memory) {
      MultiPartRLEToSVG.SVGParams memory params = MultiPartRLEToSVG.SVGParams(parts, "d5d7e1"); // background color...
      return MultiPartRLEToSVG.generateSVG(params, palettes);
    }
}