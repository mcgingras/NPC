// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// I guess the reason this doesn't feel like a perfect fit for an extension is that this extension is extremely purpose built
// to the nouns citizens contract. No other contracts would really be interested in extending this here...
// But one nice property is that it's easy to upgrade.
contract TokenMetadata {
    constructor() {}

    /*===========
        VIEWS
    ===========*/

    function ext_contractURI() external view returns (string memory uri) {
        return "";
    }

    function ext_tokenURI(uint256 tokenId) external view returns (string memory uri) {
        return "";
    }
}