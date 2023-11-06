// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IEasel {
    event PaletteSet(uint8 paletteIndex);

    struct NounArtStoragePage {
        uint16 imageCount;
        uint80 decompressedLength;
        address pointer;
    }

    struct Trait {
        NounArtStoragePage[] storagePages;
        uint256 storedImagesCount;
    }


    function addManyColorsToPalette(uint8 paletteIndex, string[] calldata newColors) external;
    function addColorToPalette(uint8 paletteIndex, string calldata newColor) external;
}