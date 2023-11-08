// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { ERC721Rails } from "0xrails/cores/ERC721/ERC721Rails.sol";

interface ITokenFactory {
  function createERC721(
    address payable implementation,
    address owner,
    string memory name,
    string memory symbol,
    bytes calldata initData
  ) external returns (address payable token);
}

/// @title NounCitizenTest
/// @author frog @0xmcg
/// @notice Tests the 0xRails factory + custom metadata extensions for Noun Citizens.
contract NounCitizenTest is Test {
    // FORK
    uint256 public goerliFork;
    string GOERLI_RPC_URL = vm.envString("$GOERLI_RPC_URL");
    address public caller = address(1);

    // CONSTANTS
    address tokenFactory = 0x66B28Cc146A1a2cDF1073C2875D070733C7d01Af;
    address payable erc721Rails = payable(0x3F4f3680c80DBa28ae43FbE160420d4Ad8ca50E4);

    function setUp() public {
      goerliFork = vm.createFork(GOERLI_RPC_URL);
      vm.selectFork(goerliFork);
    }

    function test_CreateTokenWithFactory() public {
      vm.startPrank(caller);
      address payable token = ITokenFactory(tokenFactory).createERC721(
        erc721Rails,
        caller,
        "Noun Citizens",
        "NPC",
        ""
      );

      assertEq(ERC721Rails(token).name(), "Noun Citizens");
      vm.stopPrank();

    }

}
