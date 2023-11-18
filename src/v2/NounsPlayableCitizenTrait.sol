// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC1155Rails} from "0xrails/cores/ERC1155/ERC1155Rails.sol";
import {IEasel} from "../interfaces/IEasel.sol";

interface INounsPlayableCitizenTrait {
    event TraitRegistered(uint256 traitId);

    function registerTrait(bytes memory rleBytes, string memory name) external;
    function getImageDataForTrait(uint256 traitId) external view returns (bytes memory);
    function setEquippedTokenIds(address owner, uint256[] memory) external;
    function getEquippedTokenIds(address owner) external view returns (uint256[] memory);
}

contract NounsPlayableCitizenTrait is ERC1155Rails, INounsPlayableCitizenTrait {
    struct Trait {
        string name;
        bytes rleBytes;
    }

    // previously, this was 0 but I think it needs to be a non-zero value to be able to differentiate
    // from null, so max uint256 should be a clear other extreme that will never be practically used
    uint256 constant SENTINEL_TOKEN_ID = 2 ** 256 - 1;
    address easel;
    uint256 traitIdCount;
    // tokenId => trait metadata
    mapping(uint256 => Trait) traits;
    // tba => tokenId => index
    mapping(address => mapping(uint256 => uint256)) equippedTraits;
    // tba => number traits equipped
    mapping(address => uint256) totalEquipped;

    constructor(address _easel) ERC1155Rails() {
        require(_easel != address(0));
        easel = _easel;
    }

    /*==============
        METADATA
    ==============*/

    // if this is a proper extension then we would probably want to store this per address
    function contractURI() public view override returns (string memory) {
        string memory json =
            '{"name":"Noun Playable Citizens Trait","description":"Tokenbound Nouns traits.""image":"","external_link": ""}';
        return string.concat("data:application/json;utf8,", json);
    }

    // note that 1155 uses `uri` instead of `tokenURI` for some reason
    function uri(uint256 tokenId) public view override returns (string memory) {
        bytes[] memory parts = new bytes[](1);
        bytes memory data = getImageDataForTrait(tokenId);
        parts[0] = data;
        return IEasel(easel).generateSVGForParts(parts);
    }

    // might be worth combining trait registration here with also setting the controller
    // that will be used for minting it in one function call
    function registerTrait(bytes memory rleBytes, string memory name) public {
        traits[traitIdCount++] = Trait({name: name, rleBytes: rleBytes});
        emit TraitRegistered(traitIdCount);
    }

    function getImageDataForTrait(uint256 traitId) public view returns (bytes memory) {
        return traits[traitId].rleBytes;
    }

    /*===========
        EQUIP
    ===========*/

    // think it'd be useful to also have smaller insert/swap/remove functions for making
    // edits to the equipped array without resetting the entire storage

    // also would be good to add events?

    // this implementation has a weird side effect where previous values are not unset
    // if the length of new tokenIds is less than previously set tokenIds
    function setEquippedTokenIds(address owner, uint256[] memory _tokenIds) public {
        uint256 currentTokenId = SENTINEL_TOKEN_ID;

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 tokenId = _tokenIds[i];
            require(balanceOf(owner, tokenId) > 0, "Address must own token.");
            require(tokenId != SENTINEL_TOKEN_ID && currentTokenId != tokenId, "No cycles.");
            equippedTraits[owner][currentTokenId] = tokenId;
            currentTokenId = tokenId;
        }

        equippedTraits[owner][currentTokenId] = SENTINEL_TOKEN_ID;
        totalEquipped[owner] = _tokenIds.length;
    }

    function getEquippedTokenIds(address owner) public view returns (uint256[] memory) {
        uint256[] memory array = new uint256[](totalEquipped[owner]);

        uint256 index = 0;
        uint256 currentTokenId = equippedTraits[owner][SENTINEL_TOKEN_ID];
        while (currentTokenId != SENTINEL_TOKEN_ID) {
            array[index] = currentTokenId;
            currentTokenId = equippedTraits[owner][currentTokenId];
            index++;
        }

        return array;
    }

    /*============
        GUARDS
    ============*/

    function _beforeTokenTransfers(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        view
        override
        returns (address guard, bytes memory beforeCheckData)
    {
        for (uint256 i; i < ids.length; i++) {
            // this doesn't work when ids are not unset via the side effect mentioned in `setEquippedTokenIds`
            if (equippedTraits[from][ids[i]] != 0 && balanceOf(from, ids[i]) - values[i] == 0) {
                revert("Must have remaining balance >0 for equipped trait");
            }
        }
        return super._beforeTokenTransfers(from, to, ids, values);
    }
}
