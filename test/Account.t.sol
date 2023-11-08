// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { ERC6551Registry } from "../src/ERC6551Registry.sol";
import { ERC6551Account } from "../src/ERC6551Account.sol";

// the NFT for the TBA
contract DemoNFT is ERC721 {
  constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

  function mint(address to, uint256 tokenId) public {
    _mint(to, tokenId);
  }
}

// NFT to put inside TBA
contract JunkNFT is ERC721 {
  constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

  function mint(address to, uint256 tokenId) public {
    _mint(to, tokenId);
  }
}



/// @title AccountTest
/// @author frog @0xmcg
/// @notice Tests for 6551 TBA contract and exploring various methods of creating account implementations.
contract AccountTest is Test {
    DemoNFT public demoNFT;
    JunkNFT public junkNFT;
    ERC6551Registry public registry;
    ERC6551Account public simpleAccountImplementation;
    address public caller = address(1);
    address public receiver = address(2);
    bytes32 public salt = bytes32(0);

    function setUp() public {
      vm.startPrank(caller);
      demoNFT = new DemoNFT("DemoNFT", "DNFT");
      junkNFT = new JunkNFT("JunkNFT", "JNFT");
      registry = new ERC6551Registry();
      simpleAccountImplementation = new ERC6551Account();

      demoNFT.mint(caller, 1);
      vm.stopPrank();
    }

    /// @notice tests thr 6551 reference "simple" account.
    /// Tests the following:
    /// - createAccount: registry creates a new account via the simple account implementation.
    /// - account: registry returns the correct account address for a given token.
    function test_CreateAccountSimpleAccount() public {
       vm.startPrank(caller);
      uint256 tokenId = 1;
      uint256 chainId = block.chainid;

      address payable tbaAddress = payable(registry.createAccount(address(simpleAccountImplementation), salt, chainId, address(demoNFT), tokenId));
      ERC6551Account tba = ERC6551Account(tbaAddress);
      assertEq(tbaAddress, registry.account(address(simpleAccountImplementation), salt, chainId, address(demoNFT), tokenId));

      // mints a new junk token into the TBA.
      junkNFT.mint(tbaAddress, 1);
      assertEq(junkNFT.ownerOf(1), tbaAddress);


      // transfers the junk token from the TBA to the receiver.
      bytes memory data = abi.encodeWithSignature("transferFrom(address,address,uint256)", tbaAddress, receiver, 1);
      uint256 value = 0;
      uint8 operation = 0;
      tba.execute(address(junkNFT), value, data, operation);
      assertEq(junkNFT.ownerOf(1), receiver);
      vm.stopPrank();
    }
}
