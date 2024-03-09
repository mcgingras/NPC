// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC721Rails} from "0xrails/cores/ERC721/interface/IERC721Rails.sol";
import { ERC6551Registry } from "../ERC6551Registry.sol";

/// @title NPC free mint controller
/// @author frog (@0xmcg)
/// @dev Module for minting 6551 NFTs and auto initializing the account following mint
contract InitializerMintController {
    /*============
        CONFIG
    ============*/

    struct MintParams {
        address collection;
        address recipient;
        address registry;
        address accountProxy;
        bytes32 salt;
    }

    constructor() {}

    function mintAndCreateAccount(MintParams calldata mintParams)
        external
        returns (address account, uint256 newTokenId)
    {
        newTokenId = IERC721Rails(mintParams.collection).mintTo(mintParams.recipient, 1);

        account = payable(ERC6551Registry(mintParams.registry).createAccount(
          mintParams.accountProxy,
          mintParams.salt,
          block.chainid,
          mintParams.collection,
          newTokenId
        ));

        // possible accept initialization code to pass in something to execute upon first mint
    }
}
