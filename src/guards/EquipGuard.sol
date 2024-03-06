// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import { IGuard } from "0xrails/guard/interface/IGuard.sol";
import { IEquippableExtension } from "../extensions/equippable/IEquippableExtension.sol";
import { IERC1155 } from "0xrails/cores/ERC1155/interface/IERC1155.sol";

/// @title EquipTransferGuard
/// @author frog @0xmcg
/// @notice Guard to protect against trasnferring equippable tokens that are currently equipped.
/// It is permissible to transfer an equipped token if the balance is greater than 1. This would be
/// transferring part of your stack of tokens, but as long as you have a single token left, we can
/// consider that remaining token the "equipped" token.
contract EquipTransferGuard is IGuard {
    function checkBefore(address, bytes calldata data) external view returns (bytes memory) {
      (,address from,,uint256[] memory ids,uint256[] memory amounts) = abi.decode(data, (address, address, address, uint256[], uint256[]));

      for (uint256 i = 0; i < ids.length; i++) {
        uint256 amount = amounts[i];
        uint256 balance = IERC1155(msg.sender).balanceOf(from, ids[i]);
        bool equipped = IEquippableExtension(msg.sender).ext_isTokenIdEquipped(from, ids[i]);
        require(balance - amount >= 1 || !equipped, "Cannot transfer equipped token.");
      }

      return bytes("");
    }

    function checkAfter(bytes calldata, bytes calldata) external view {}
}
