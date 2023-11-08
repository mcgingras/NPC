// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


// TODO: you should have to be the owner of a token in order to equip it.
contract Equippable {
    uint256 internal constant SENTINEL_TOKEN_ID = 0;
    mapping(address => mapping(uint256 => uint256)) internal _equippedByOwner;
    mapping(address => uint256) internal _counts;

    constructor() {}


    // maybe expose these through their own function so it's a bit more testable and isolated?
    // similar to how metadata router works.
    function setupEquipped(address owner, uint256[] memory _tokenIds) external {
        uint256 currentTokenId = SENTINEL_TOKEN_ID;
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 tokenId = _tokenIds[i];
            require(tokenId != SENTINEL_TOKEN_ID && currentTokenId != tokenId, "No cycles.");
            _equippedByOwner[owner][currentTokenId] = tokenId;
            currentTokenId = tokenId;
        }
        _equippedByOwner[owner][currentTokenId] = SENTINEL_TOKEN_ID;
        _counts[owner] = _tokenIds.length;
    }

    // tempted to leave this blank and just rely on passing in full new array to update to setup
    // sort of like redux -- always pure, always new, no mutation.
    // what is gas overhead of doing this?
    function equipTokenId(address owner, uint256 tokenId) external view {
        //
    }

    // tempted to leave this blank and just rely on passing in full new array to update to setup
    // sort of like redux -- always pure, always new, no mutation.
    // what is gas overhead of doing this?
    function unequipTokenId(address owner, uint256 tokenId) external view {
       //
    }

    function getEquippedTokenIds(address owner) external view returns (uint256[] memory) {
        uint256[] memory array = new uint256[](_counts[owner]);

        uint256 index = 0;
        uint256 currentTokenId = _equippedByOwner[owner][SENTINEL_TOKEN_ID];
        while (currentTokenId != SENTINEL_TOKEN_ID) {
            array[index] = currentTokenId;
            currentTokenId = _equippedByOwner[owner][currentTokenId];
            index++;
        }
        return array;
    }

    // thoughts on adding batch?
}
