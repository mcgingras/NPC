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
import { BaseMetadataExtension } from "../src/extensions/baseMetadata/BaseMetadataExtension.sol";
import { IBaseMetadataExtension } from "../src/extensions/baseMetadata/IBaseMetadataExtension.sol";
import { EquippableExtension } from "../src/extensions/equippable/EquippableExtension.sol";
import { IEquippableExtension } from "../src/extensions/equippable/IEquippableExtension.sol";
import { RegistryExtension } from "../src/extensions/registry/RegistryExtension.sol";
import { IRegistryExtension } from "../src/extensions/registry/IRegistryExtension.sol";
import { TraitMetadataExtension } from "../src/extensions/traitMetadata/TraitMetadataExtension.sol";
import { ITraitMetadataExtension } from "../src/extensions/traitMetadata/ITraitMetadataExtension.sol";

/// -----------------
/// SCRIPTS
/// -----------------
// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $SEPOLIA_RPC_URL script/2_DeployNPC.s.sol:Deploy
// forge verify-contract --chain 5 --etherscan-api-key $ETHERSCAN_API_KEY 0xb7539fbfcbe9e64e85ea865980cd47e0962aae6d src/Character.sol:Character


/// -----------------
/// FINAL CONTRACT ADDRESSES
/// -----------------
/// NPC (721) = 0xF1eFc9e4C5238C5bCf3d30774480325893435a2A
/// Traits (1155) = 0x9A349CF5F69c12423111b729564D43022eC875F1

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
    address public deployer = 0xfC29eDCe481c4D7D2CDa4c0Ad6bF6C5Fcf128704;
    string public name = "Noun Citizens";
    string public symbol = "NPC";

    /// @notice SEPOLIA: v1.0.0
    /// @notice Tokenbound v0.3.1
    address tokenFactory = 0x2C333bd1316cE1aF9EBF017a595D6f8AB5f6BD1A;
    address erc6551Registry = 0x000000006551c19487814612e58FE06813775758;
    address erc6551AccountProxy = 0x55266d75D1a14E4572138116aF39863Ed6596E7F;
    address erc6551AccountImpl = 0x41C8f39463A868d3A88af00cd0fe7102F30E44eC;
    address erc721Rails = 0xB5764bd3AD21A58f723DB04Aeb97a428c7bdDE2a;
    address erc1155Rails = 0x053809DFdd2443616d324c93e1DFC6a2076F976B;
    address registryExtension = 0x65b6e79D72bB53969a58Ac28Aaa32BA2cF6A6Ae2;
    address equippableExtension = 0x4E42265D34CE4B0d49014C480D0d38485154375b;
    address baseMetadataExtension = 0x45438bA80530B6feeB3A6fd426b8E344D00B604E;
    address traitMetadataExtension = 0x7ee95388ABc3B500667D7fEB70d70C9728014598;
    address frog = 0x65A3870F48B5237f27f674Ec42eA1E017E111D63;
    address martin = 0x55045DA52be49461aF91a235E4303D4a9B2312AE;
    bytes32 salt = 0x00000000;

    function deployCitizen721Contract() public returns (address payable) {
      /*============
        TokenMetadataExtension
        This extension adds the ability to call custom tokenURI and contractURI functions.
        `ext_setup` is necessary to call before using the extension, as it sets the proper addresses.
      ============*/
      bytes memory addSetupMetadata = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IBaseMetadataExtension.ext_setup.selector, address(baseMetadataExtension));

      bytes memory addTokenURIExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IBaseMetadataExtension.ext_tokenURI.selector, address(baseMetadataExtension));

      bytes memory addContractURIExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector,
        IBaseMetadataExtension.ext_contractURI.selector,
        address(baseMetadataExtension));

      bytes memory permitFrogAdmin =
        abi.encodeWithSelector(Permissions.addPermission.selector, Operations.ADMIN, frog);

      bytes memory permitMartinAdmin =
        abi.encodeWithSelector(Permissions.addPermission.selector, Operations.ADMIN, martin);

      bytes[] memory initCalls = new bytes[](5);
      initCalls[0] = addSetupMetadata;
      initCalls[1] = addTokenURIExtension;
      initCalls[2] = addContractURIExtension;
      initCalls[3] = permitFrogAdmin;
      initCalls[4] = permitMartinAdmin;

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
        IExtensions.setExtension.selector, ITraitMetadataExtension.ext_setup.selector, address(traitMetadataExtension));

      bytes memory addContractURIExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, ITraitMetadataExtension.ext_contractURI.selector, address(traitMetadataExtension));

      bytes memory addTokenURIExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, ITraitMetadataExtension.ext_tokenURI.selector, address(traitMetadataExtension));

      bytes memory permitFrogAdmin =
        abi.encodeWithSelector(Permissions.addPermission.selector, Operations.ADMIN, frog);

      bytes memory permitMartinAdmin =
        abi.encodeWithSelector(Permissions.addPermission.selector, Operations.ADMIN, martin);

      bytes[] memory initCalls = new bytes[](11);
      initCalls[0] = addAddTokenIdExtension;
      initCalls[1] = addRemoveTokenIdExtension;
      initCalls[2] = addGetAllExtension;
      initCalls[3] = addIsTokenIdEquippedExtension;
      initCalls[4] = addRegisterTraitExtension;
      initCalls[5] = addGetImageDataExtension;
      initCalls[6] = addSetupMetadataExtension;
      initCalls[7] = addContractURIExtension;
      initCalls[8] = addTokenURIExtension;
      initCalls[9] = permitFrogAdmin;
      initCalls[10] = permitMartinAdmin;

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
