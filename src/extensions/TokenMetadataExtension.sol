// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Extension} from "0xrails/extension/Extension.sol";

// How does extension system deal with collisions?
contract TokenMetadataExtension is Extension {
    constructor() Extension() {}

    /*===============
        EXTENSION
    ===============*/

    /// @inheritdoc Extension
    function getAllSelectors() public pure override returns (bytes4[] memory selectors) {
        selectors = new bytes4[](2);
        selectors[0] = this.ext_contractURI.selector;
        selectors[1] = this.ext_tokenURI.selector;
        return selectors;
    }

    /// @inheritdoc Extension
    function signatureOf(bytes4 selector) public pure override returns (string memory) {
        if (selector == this.ext_contractURI.selector) {
            return "ext_contractURI()";
        } else if (selector == this.ext_tokenURI.selector) {
            return "ext_tokenURI(uint256)";
        } else {
            return "";
        }
    }

    function ext_contractURI() external view returns (string memory uri) {
        return "TEMP_CONTRACT_URI";
    }

    function ext_tokenURI(uint256 tokenId) external view returns (string memory uri) {
        return "TEMP_TOKEN_URI";
    }
}
