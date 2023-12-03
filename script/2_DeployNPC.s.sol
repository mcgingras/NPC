// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Multicall} from "../lib/openzeppelin-contracts/contracts/utils/Multicall.sol";
import {Permissions} from "0xrails/access/permissions/Permissions.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import { Test, console2 } from "forge-std/Test.sol";
import { ERC721Rails } from "0xrails/cores/ERC721/ERC721Rails.sol";
import { ERC1155Rails } from "0xrails/cores/ERC1155/ERC1155Rails.sol";
import { IERC1155Rails } from "0xrails/cores/ERC1155/interface/IERC1155Rails.sol";
import {IExtensions} from "0xrails/extension/interface/IExtensions.sol";
import {Multicall} from "openzeppelin-contracts/utils/Multicall.sol";
import { TokenFactory } from "groupos/factory/TokenFactory.sol";
import { ERC6551Registry } from "../src/ERC6551Registry.sol";
import { ERC6551Account } from "../src/ERC6551Account.sol";
import { TokenMetadataExtension } from "../src/extensions/tokenMetadata/tokenMetadataExtension.sol";
import { ITokenMetadataExtension } from "../src/extensions/tokenMetadata/ITokenMetadataExtension.sol";
import { EquippableExtension } from "../src/extensions/equippable/EquippableExtension.sol";
import { IEquippableExtension } from "../src/extensions/equippable/IEquippableExtension.sol";
import { RegistryExtension } from "../src/extensions/registry/RegistryExtension.sol";
import { IRegistryExtension } from "../src/extensions/registry/IRegistryExtension.sol";
import { MetadataExtension } from "../src/extensions/metadata/MetadataExtension.sol";
import { IMetadataExtension } from "../src/extensions/metadata/IMetadataExtension.sol";

/// -----------------
/// SCRIPTS
/// -----------------
// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $GOERLI_RPC_URL script/2_DeployNPC.s.sol:Deploy
// forge verify-contract --chain 5 --etherscan-api-key $ETHERSCAN_API_KEY 0xb7539fbfcbe9e64e85ea865980cd47e0962aae6d src/Character.sol:Character


/// -----------------
/// FINAL CONTRACT ADDRESSES
/// -----------------
/// NPC (721) = 0x28aAF781E430E5Ab48DDb44aEF0D621c0d0f0342
/// Traits (1155) = 0x3f32E454D10dE67E8dc602bd7e2E4b670a509e20

interface ITokenFactory {
  function createERC721(
    address payable implementation,
    bytes32 inputSalt,
    address owner,
    string memory name,
    string memory symbol,
    bytes calldata initData
  ) external returns (address payable token);

  function createERC1155(
    address payable implementation,
    bytes32 inputSalt,
    address owner,
    string memory name,
    string memory symbol,
    bytes calldata initData
  ) external returns (address payable token);
}

contract Deploy is Script {
    /*============
        CONFIG
    ============*/
    address public deployer = 0xE7affDB964178261Df49B86BFdBA78E9d768Db6D;
    string public name = "Noun Citizens";
    string public symbol = "NPC";

    /// @notice GOERLI: v1.0.0
    /// @notice Tokenbound v0.3.1
    address tokenFactory = 0x2C333bd1316cE1aF9EBF017a595D6f8AB5f6BD1A;
    address erc6551Registry = 0x000000006551c19487814612e58FE06813775758;
    address erc6551AccountProxy = 0x55266d75D1a14E4572138116aF39863Ed6596E7F;
    address erc6551AccountImpl = 0x41C8f39463A868d3A88af00cd0fe7102F30E44eC;
    address erc721Rails = 0xB5764bd3AD21A58f723DB04Aeb97a428c7bdDE2a;
    address erc1155Rails = 0x053809DFdd2443616d324c93e1DFC6a2076F976B;
    address registryExtension = 0x33b34094E8349eC7514b4ECF757A0768566da133;
    address equippableExtension = 0x4893a84658f3eB0846547896816EA9623670e68f;
    address tokenMetadataExtension = 0xc9E847E3Cc5572Da9BB4f077811cB44323e99b2C;
    address metadataExtension = 0x3EF1dAd6D56Bc83748E9139bc532c231d39D9E2f;
    bytes32 salt = 0x00000000;

    function deployCitizen721Contract() public returns (address payable) {
      /*============
        TokenMetadataExtension
        This extension adds the ability to call custom tokenURI and contractURI functions.
        `ext_setup` is necessary to call before using the extension, as it sets the proper addresses.
      ============*/
      bytes memory addSetupMetadata = abi.encodeWithSelector(
        IExtensions.setExtension.selector, ITokenMetadataExtension.ext_setup.selector, address(tokenMetadataExtension));

      bytes memory addTokenURIExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, ITokenMetadataExtension.ext_tokenURI.selector, address(tokenMetadataExtension));

      bytes memory addContractURIExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector,
        ITokenMetadataExtension.ext_contractURI.selector,
        address(tokenMetadataExtension));

      bytes[] memory initCalls = new bytes[](3);
      initCalls[0] = addSetupMetadata;
      initCalls[1] = addTokenURIExtension;
      initCalls[2] = addContractURIExtension;

      bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, initCalls);

      address payable tokenContract = ITokenFactory(tokenFactory).createERC721(
        payable(erc721Rails),
        salt,
        deployer,
        "Noun Citizens",
        "NPC",
        initData
      );

      return tokenContract;
    }

    function deployTrait1155Contract() public returns (address payable) {
      bytes memory addAddTokenIdExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IEquippableExtension.ext_addTokenId.selector, address(equippableExtension)
      );

      bytes memory addRemoveTokenIdExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IEquippableExtension.ext_removeTokenId.selector, address(equippableExtension)
      );

      bytes memory addGetAllExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IEquippableExtension.ext_getEquippedTokenIds.selector, address(equippableExtension)
      );

      bytes memory addIsTokenIdEquippedExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IEquippableExtension.ext_isTokenIdEquipped.selector, address(equippableExtension)
      );

      bytes memory addRegisterTraitExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IRegistryExtension.ext_registerTrait.selector, address(registryExtension)
      );

      bytes memory addGetImageDataExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IRegistryExtension.ext_getImageDataForTrait.selector, address(registryExtension)
      );

      bytes memory addSetupMetadataExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IMetadataExtension.ext_setup.selector, address(metadataExtension));

      bytes memory addTokenURIExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IMetadataExtension.ext_tokenURI.selector, address(metadataExtension));

      bytes[] memory initCalls = new bytes[](8);
      initCalls[0] = addAddTokenIdExtension;
      initCalls[1] = addRemoveTokenIdExtension;
      initCalls[2] = addGetAllExtension;
      initCalls[3] = addIsTokenIdEquippedExtension;
      initCalls[4] = addRegisterTraitExtension;
      initCalls[5] = addGetImageDataExtension;
      initCalls[6] = addSetupMetadataExtension;
      initCalls[7] = addTokenURIExtension;

      bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, initCalls);

      address payable tokenContract = ITokenFactory(tokenFactory).createERC1155(
        payable(erc1155Rails),
        salt,
        deployer,
        "NPC Trait",
        "NPCT",
        initData
      );

      return tokenContract;
    }

    function run() public {
        vm.startBroadcast();
        address payable citizenContract = deployCitizen721Contract();
        address payable traitContract = deployTrait1155Contract();
        vm.stopBroadcast();
    }
}
