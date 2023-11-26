// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { IGuard } from "0xrails/guard/interface/IGuard.sol";
import { IEquippableExtension } from "../extensions/equippable/IEquippableExtension.sol";

/// @title EquipTransferGuard
/// @author frog @0xmcg
/// @notice Guard to protect against trasnferring equippable tokens that are currently equipped.
contract EquipTransferGuard is IGuard {
    function checkBefore(address, bytes calldata data) external view returns (bytes memory) {
      (,address from,, uint256[] memory ids,) = abi.decode(data, (address, address, address, uint256[], uint256[]));
      // not checking for batches -- need to improve this
      require(!IEquippableExtension(msg.sender).ext_isTokenIdEquipped(from, ids[0]), "Cannot transfer equipped token.");

      // not sure why we need to return bytes...
      return bytes("");
    }

    function checkAfter(bytes calldata, bytes calldata) external view {
    }
}