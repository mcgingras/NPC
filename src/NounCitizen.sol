// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { ERC721Rails } from "0xrails/cores/ERC721/ERC721Rails.sol";

/// @title NounCitizen
/// @author frog, @0xmcg on twitter.
/// @notice ERC721 designed to be used as a base contract for Noun Citizens.
/// @dev A TBA should be deployed alongside each token minted. All of the necessary logic is handled by rails.
/// Consult the 0xRails documentation for more information.
contract NounCitizen is ERC721Rails {
    constructor(string memory name, string memory symbol) ERC721Rails(name, symbol) {}
}

// Might it even be possible that we don't even need a contract and can instead just use the rails factory to
// deploy a new token?
