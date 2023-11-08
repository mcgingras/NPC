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
        selectors = new bytes4[](3);
        selectors[0] = this.ext_equipTokenId.selector;
        selectors[1] = this.ext_unequipTokenId.selector;
        selectors[2] = this.ext_getEquippedTokenIds.selector;
        return selectors;
    }

    /// @inheritdoc Extension
    function signatureOf(bytes4 selector) public pure override returns (string memory) {
        if (selector == this.ext_equipTokenId.selector) {
            return "ext_equipTokenId(uint256)";
        } else if (selector == this.ext_unequipTokenId.selector) {
            return "ext_unequipTokenId(uint256)";
        } else if (selector == this.ext_getEquippedTokenIds.selector) {
            return "ext_getEquippedTokenIds()";
        } else {
            return "";
        }
    }

    function ext_equipTokenId(uint256 tokenId) external view {
        return "TEMP_CONTRACT_URI";
    }

    function ext_unequipTokenId(uint256 tokenId) external view {
        return "TEMP_TOKEN_URI";
    }

    function ext_getEquippedTokenIds() external view {
        return "TEMP_TOKEN_URI";
    }

    // thoughts on adding batch?
}
