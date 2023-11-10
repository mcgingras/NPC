// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IERC1155Rails } from "0xrails/cores/ERC1155/interface/IERC1155Rails.sol";
import { IPermissions } from "0xrails/access/permissions/interface/IPermissions.sol";
import { Operations } from "0xrails/lib/Operations.sol";

/// @title PerTokenMintController Contract
/// @author frog (@0xmcg)
/// @dev currently specced for ERC 1155 tokens.
contract PerTokenMintController {

    /*=============
        STORAGE
    =============*/

    /// @dev collection => tokenId => module
    mapping(address => mapping(uint256 => address)) internal _mintModules;

    /*============
        EVENTS
    ============*/

    /// @dev Events share names but differ in parameters to differentiate them between controllers
    event SetUp(address indexed collection, bool indexed enablePermits);

    /*============
        CONFIG
    ============*/

    /// @param _metadataRouter The GroupOS MetadataRouter's address
    constructor(address _metadataRouter) {}

    /// @dev Function to set up and configure a new collection's purchase prices
    /// @param collection The new collection to configure
    /// @param enablePermits A boolean to represent whether this collection will repeal or support grant functionality
    // function setUpPermits(address collection, bool enablePermits) public {
    //     if (_disablePermits[collection] != !enablePermits) {
    //         _disablePermits[collection] = !enablePermits;
    //     }
    //     emit SetUp(collection, enablePermits);
    // }



    /*==========
        MINT
    ==========*/

    /// @dev Function to mint ERC20 collection tokens to a specified recipient
    /// @notice Can only be called successfully with data signed by a key explicitly granted permission
    function mint(address collection, uint256 tokenId, address recipient, uint256 amount) external payable {
        require(amount > 0, "ZERO_AMOUNT");
        address mintModule = _mintModules[collection][tokenId];
        require(mintModule != address(0), "NO_MINT_MODULE");
        // should call mint on mint module
        // do we need some standard interface for mint modules now then?
        // or maybe we pass in calldata to this function and it just forwards it to the mint module
        IERC1155Rails(collection).mintTo(recipient, tokenId, amount);
    }
}