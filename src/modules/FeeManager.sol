// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

/// @title Station Network Fee Manager Contract (NPC update 1.0)
/// @author 👦🏻👦🏻.eth, frog (@0xmcg)
/// @dev This contract stores state for all fees set on both default and per-collection basis
/// Handles fee calculations when called by modules inquiring about the total fees involved in a mint, including ERC20 support
/// This particular contract is a simplified version of the Station fee manager designed for ETH payments only.
contract FeeManager is Ownable {
    /// @dev Struct of fee data, including FeeSetting enum and both base and variable fees, all packed into 1 slot
    /// Since `type(uint120).max` ~= 1.3e36, it suffices for fees of up to 1.3e18 ETH or ERC20 tokens, far beyond realistic scenarios.
    /// @param exist boolean indicating whether the fee values exist
    /// @param baseFee The flat fee charged for all NPC mints
    /// Accounts for each item's cost and total amount of items
    struct Fees {
        bool exist;
        uint120 baseFee;
    }

    /*============
        ERRORS
    ============*/

    error FeesNotSet();

    /*============
        EVENTS
    ============*/

    event DefaultFeesUpdated(Fees fees);
    event CollectionFeesUpdated(address indexed collection, Fees fees);

    /*=============
        STORAGE
    =============*/

    /// @dev Baseline fee struct that serves as a stand in for all token addresses that have been registered
    Fees internal defaultFees;

    /// @dev Mapping that stores override fees associated with specific collections
     mapping(address => Fees) internal collectionFees;

    /*================
        FEEMANAGER
    ================*/

    /// @notice Constructor will be deprecated in favor of an initialize() UUPS proxy call once logic is finalized & approved
    /// @param _newOwner The initialization of the contract's owner address, managed by Station
    /// @param _defaultBaseFee The initialization of default baseFees for all token addresses that have not (yet) been given defaults
    constructor(
        address _newOwner,
        uint120 _defaultBaseFee
    ) {
        Fees memory _defaultFees = Fees(true, _defaultBaseFee);
        defaultFees = _defaultFees;
        emit DefaultFeesUpdated(_defaultFees);
        _transferOwnership(_newOwner);
    }

    /// @dev Function to set baseline fee all collections without specified defaults
    /// @dev Only callable by contract owner, an address managed by NPC
    /// @param baseFee The new baseFee to apply as default
    function setDefaultFees(uint120 baseFee) external onlyOwner {
        Fees memory fees = Fees(true, baseFee);
        defaultFees = fees;
        emit DefaultFeesUpdated(fees);
    }

    /// @dev Function to set override base and variable fees on a per-collection basis
    /// @param collection The collection for which to set override fees
    /// @param baseFee The new baseFee to apply to the collection and token
    function setCollectionFees(address collection, uint120 baseFee)
        external
        onlyOwner
    {
        Fees memory fees = Fees(true, baseFee);
        collectionFees[collection] = fees;
        emit CollectionFeesUpdated(collection, fees);
    }

    /// @dev Function to remove base and variable fees for a specific token
    /// @dev Only callable by contract owner, an address managed by Station
    /// @param collection The collection for which to remove fees
    function removeCollectionFees(address collection) external onlyOwner {
        Fees memory fees = Fees(false, 0);
        collectionFees[collection] = fees;
        emit CollectionFeesUpdated(collection, fees);
    }

    /*============
        VIEWS
    ============*/

    /// @dev Function to get collection fees
    /// @param collection The collection whose fees will be read, including checks for client-specific fee discounts
    /// @param /*recipient*/ The address to mint to. Included to support future discounts on a per user basis
    function getFeeTotals(
        address collection,
        address /*recipient*/
    ) external view returns (uint256 feeTotal) {
        // get existing fees, first checking for override fees or discounts if they have already been set
        Fees memory fees = getFees(collection);
        return fees.baseFee;
    }

    /// @dev Function to get baseline fees for all tokens
    function getDefaultFees() public view returns (Fees memory fees) {
        fees = defaultFees;
    }

    /// @dev Function to get override fees for a collection and token if they have been set
    /// @param collection The collection address to query against collectionFees mapping
    function getCollectionFees(address collection) public view returns (Fees memory fees) {
        fees = collectionFees[collection];
        if (!fees.exist) revert FeesNotSet();
    }

    /// @dev Function to evaluate whether override fees have been set for a specific collection
    /// otherwise, use the default fees
    function getFees(address _collection) public view returns (Fees memory fees) {
        // if collectionFees exist, return overrides
        Fees memory collectionOverrides = collectionFees[_collection];
        if (collectionOverrides.exist) {
            return collectionOverrides;
        }

        // no overrides set, return defaults
        return defaultFees;
    }
}
