// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC1155Rails} from "0xrails/cores/ERC1155/interface/IERC1155Rails.sol";
import {IPermissions} from "0xrails/access/permissions/interface/IPermissions.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {FeeController} from "./FeeController.sol";

/// @title NPC free mint controller
/// @author frog (@0xmcg)
/// @dev Module to handle minting NPCs for no charge aside from the base fee
contract FreeMintController is FeeController {
    /*============
        CONFIG
    ============*/

    /// @param _newOwner The owner of the FeeControllerV2, an address managed by Station Network
    /// @param _feeManager The FeeManager's address
    constructor(address _newOwner, address _feeManager, address[] memory __feeRecipients)
     FeeController(_newOwner, _feeManager, __feeRecipients) {}

    /*==========
        MINT
    ==========*/

    /// @dev Function to mint a single collection token to the caller, ie a user
    function mint(address collection, uint256 tokenId) external payable {
        _mint(collection, msg.sender, tokenId, 1);
    }

    /// @dev Function to mint a single collection token to a specified recipient
    function mintTo(address collection, address recipient, uint256 tokenId) external payable {
        _mint(collection, recipient, tokenId, 1);
    }

    /// @dev Function to mint collection tokens in batches to the caller, ie a user
    /// @notice returned tokenId range is inclusive
    function batchMint(address collection, uint256[] memory tokenIds, uint256[] memory amounts) external payable {
        _batchMint(collection, msg.sender, tokenIds, amounts);
    }

    /// @dev Function to mint collection tokens in batches to a specified recipient
    /// @notice returned tokenId range is inclusive
    function batchMintTo(address collection, address recipient, uint256[] memory tokenIds, uint256[] memory amounts) external payable {
        _batchMint(collection, recipient, tokenIds, amounts);
    }

    /*===============
        INTERNALS
    ===============*/


    function _mint(address collection, address recipient, uint256 tokenId, uint256 amount) internal {
       IERC1155Rails(collection).mintTo(recipient, tokenId, amount);
    }

    /// @dev Internal function to which all external user + client facing batchMint functions are routed.
    /// @param collection The token collection to mint from
    /// @param recipient The recipient of successfully minted tokens
    /// @param tokenIds An array of tokenIds to mint
    /// @param amounts An array of amounts to mint
    function _batchMint(address collection, address recipient, uint256[] memory tokenIds, uint256[] memory amounts) internal {
        // get total number of tokens to mint -- total is the sum of all amounts
        uint256 quantity;
        for (uint256 i; i < amounts.length; ++i) {
            quantity += amounts[i];
        }

        // calculate fee, require fee sent to this contract, transfer collection's revenue to payoutAddress
        // for free mints there is no payoutAddress && payment token is network token
        _collectFeeAndForwardCollectionRevenue(collection, recipient, quantity, 0);

        // Mint NFTs
        for (uint256 i; i < tokenIds.length; ++i) {
            IERC1155Rails(collection).mintTo(recipient, tokenIds[i], amounts[i]);
        }
    }
}
