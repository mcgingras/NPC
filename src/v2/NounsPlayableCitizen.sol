// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC721Rails} from "0xrails/cores/ERC721/ERC721Rails.sol";
import {IEasel} from "../interfaces/IEasel.sol";
import {INounsPlayableCitizenTrait} from "./NounsPlayableCitizenTrait.sol";
import {IERC6551Registry} from "../ERC6551Registry.sol";

contract NounsPlayableCitizen is ERC721Rails {
    address traits;
    address easel;
    address erc6551Registry;
    address erc6551Implementation;
    bytes32 erc6551Salt;

    constructor(
        address _traits,
        address _easel,
        address _erc6551Registry,
        address _erc6551Implementation,
        bytes32 _erc6551Salt
    ) ERC721Rails() {
        _nonZero(_traits);
        _nonZero(_easel);
        _nonZero(_erc6551Registry);
        _nonZero(_erc6551Implementation);
        traits = _traits;
        easel = _easel;
        erc6551Registry = _erc6551Registry;
        erc6551Implementation = _erc6551Implementation;
        erc6551Salt = _erc6551Salt;
    }

    function _nonZero(address a) internal {
        require(a != address(0));
    }

    /*==============
        METADATA
    ==============*/

    // if this is a proper extension then we would probably want to store this per address
    function contractURI() public view override returns (string memory) {
        string memory json =
            '{"name":"Noun Playable Citizens","description":"Tokenbound Nouns.""image":"","external_link": ""}';
        return string.concat("data:application/json;utf8,", json);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        address tba = IERC6551Registry(erc6551Registry).account(
            erc6551Implementation, erc6551Salt, block.chainid, address(this), tokenId
        );

        // think that this can be simplified by the traits contract exposing one function to wrap
        // all of this in one function: `return INounsPlayableCitizenTrait(traits).getSVG(tba)`
        // this would also remove the need for defining `easel` in this contract

        uint256[] memory tokens = INounsPlayableCitizenTrait(traits).getEquippedTokenIds(tba);

        bytes[] memory traitParts = new bytes[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 traitId = tokens[i];
            traitParts[i] = INounsPlayableCitizenTrait(traits).getImageDataForTrait(traitId);
        }

        return IEasel(easel).generateSVGForParts(traitParts);
    }
}
