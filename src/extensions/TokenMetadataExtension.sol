// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Extension} from "0xrails/extension/Extension.sol";

// should we make this UUPS or something so we can upgrade the renderer if we want?
// Or would the move in rails be unregistering this extension and swapping out for a new one?
// How does extension system deal with collisions?
contract TokenMetadataRouterExtension is Extension {
    /*=======================
        CONTRACT METADATA
    =======================*/

    constructor(address router) Extension() {}

    // what is the point of this function?
    function _contractRoute() internal pure returns (string memory route) {
        return "extension";
    }

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
}
