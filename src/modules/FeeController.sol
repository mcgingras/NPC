// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {SafeERC20} from "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "0xrails/access/ownable/Ownable.sol";
import {FeeManager} from "./FeeManager.sol";

/// @title Station Network Fee Manager Contract (NPC update 1.0)
/// @author symmetry (@symmtry69), frog (@0xmcg), 👦🏻👦🏻.eth
/// @dev This contract enables payment by handling funds when charging base and variable fees on each Membership's mints
/// @notice The FeeController is intended to be inherited by all purchase modules to abstract all payment logic
/// and handle fees for every client's desired Membership implementation. This contract is a simplified version of the
/// Station fee controller designed for ETH payments only. I am also adding the ability to split the fee between many
/// addresses.
abstract contract FeeController is Ownable {
    /*============
        ERRORS
    ============*/

    error InvalidFee(uint256 expected, uint256 received);

    /*============
        EVENTS
    ============*/

    event FeePaid(
        address indexed collection,
        address indexed buyer,
        uint256 unitPrice,
        uint256 quantity,
        uint256 totalFee
    );
    event FeeWithdrawn(address indexed recipient, uint256 amount);
    event FeeManagerUpdated(address indexed oldFeeManager, address indexed newFeeManager);

    /*=============
        STORAGE
    =============*/

    /// @dev Address of the deployed FeeManager contract which stores state for all collections' fee information
    /// @dev The FeeManager serves a Singleton role as central fee ledger for modules to read from
    address internal feeManager;
    address[] internal feeRecipients;

    /*==============
        SETTINGS
    ==============*/

    /// @param _newOwner The initialization of the contract's owner address, managed by Station
    /// @param _feeManager This chain's address for the FeeManager, Station's central fee management ledger
    constructor(address _newOwner, address _feeManager, address[] memory _feeRecipients) {
        _transferOwnership(_newOwner);
        feeManager = _feeManager;
        feeRecipients = _feeRecipients;
    }


     /// @dev Function to get all recipients of fees
    function getFeeRecipients() external view returns (address[] memory) {
        return feeRecipients;
    }

     /// @dev Function to add new recipients of fees
    function addFeeRecipient(address _newRecipient) external onlyOwner {
        feeRecipients.push(_newRecipient);
    }

     /// @dev Function to remove a recipient of fees
    /// @param _recipient The address to remove
    function removeFeeRecipient(address _recipient) external onlyOwner {
        for (uint256 i = 0; i < feeRecipients.length; i++) {
            if (feeRecipients[i] == _recipient) {
                feeRecipients[i] = feeRecipients[feeRecipients.length - 1];
                feeRecipients.pop();
                break;
            }
        }
    }

    /// @dev Function to set a new FeeManager
    /// @param newFeeManager The new FeeManager address to write to storage
    function setNewFeeManager(address newFeeManager) external onlyOwner {
        require(newFeeManager != address(0) && newFeeManager != feeManager, "INVALID_FEE_MANAGER");
        emit FeeManagerUpdated(feeManager, newFeeManager);
        feeManager = newFeeManager;
    }

    /*==============
        WITHDRAW
    ==============*/

    /// @dev Function to withdraw the total balances of accrued base and variable eth fees collected from mints
    /// @dev Sends fees to the module's owner address, which is managed by Station Network
    /// @dev Access control enforced for tax implications
    function withdrawFees() external onlyOwner {
        address[] memory recipients = feeRecipients;
        uint256 totalAmountOfFees = address(this).balance;
        uint256 amountPerRecipient = totalAmountOfFees / recipients.length;
        for (uint256 i; i < recipients.length; ++i) {
            address recipient = recipients[i];
            (bool success,) = recipient.call{value: amountPerRecipient}("");
            require(success);
            emit FeeWithdrawn(recipient, amountPerRecipient);
        }
    }

    /*=============
        COLLECT
    =============*/

    /// @dev Function to collect fees for owner and collection
    /// @dev Called only by child contracts inheriting this one
    /// @param collection The token collection to mint from
    /// @param recipient The recipient of successfully minted tokens
    /// @param quantity The number of items being minted, used to calculate the total fee payment required
    /// @param unitPrice The price per token to mint
    function _collectFeeAndForwardCollectionRevenue(
        address collection,
        address recipient,
        uint256 quantity,
        uint256 unitPrice
    ) internal returns (uint256 paidFee) {
        // feeTotal is handled as ETH
        paidFee = FeeManager(feeManager).getFeeTotals(collection, recipient);
        uint256 total = quantity * unitPrice + paidFee;

        // collect fees- baseFee is still applied in FreeMintController context
        if (msg.value != total) revert InvalidFee(total, msg.value);

        if (unitPrice != 0) {
            // cost of token goes to contract... different than fee
            (bool success,) = address(this).call{value: quantity * unitPrice}("");
            require(success, "PAYMENT_FAIL");
        }

        // emit event for accounting
        emit FeePaid(collection, recipient, unitPrice, quantity, paidFee);
    }
}
