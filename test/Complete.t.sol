// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { ERC721Rails } from "0xrails/cores/ERC721/ERC721Rails.sol";
import { ERC1155Rails } from "0xrails/cores/ERC1155/ERC1155Rails.sol";
import { IERC1155Rails } from "0xrails/cores/ERC1155/interface/IERC1155Rails.sol";
import { IExtensions } from "0xrails/extension/interface/IExtensions.sol";
import { Multicall } from "openzeppelin-contracts/utils/Multicall.sol";
import { Easel } from "../src/Easel.sol";
import { ERC6551Registry } from "../src/ERC6551Registry.sol";
import { ERC6551Account } from "../src/ERC6551Account.sol";
import { TokenFactory } from "groupos/factory/TokenFactory.sol";
import { BaseMetadataExtension } from "../src/extensions/baseMetadata/BaseMetadataExtension.sol";
import { IBaseMetadataExtension } from "../src/extensions/baseMetadata/IBaseMetadataExtension.sol";
import { TraitMetadataExtension } from "../src/extensions/traitMetadata/TraitMetadataExtension.sol";
import { ITraitMetadataExtension } from "../src/extensions/traitMetadata/ITraitMetadataExtension.sol";
import { EquippableExtension } from "../src/extensions/equippable/EquippableExtension.sol";
import { IEquippableExtension } from "../src/extensions/equippable/IEquippableExtension.sol";
import { RegistryExtension } from "../src/extensions/registry/RegistryExtension.sol";
import { IRegistryExtension } from "../src/extensions/registry/IRegistryExtension.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { IEasel } from "../src/interfaces/IEasel.sol";

/// @title CompleteTest
/// @author frog @0xmcg
/// @notice E2E test.
/// forge t --mc CompleteTest -vvv
contract CompleteTest is Test {
    address public caller = address(1);
    address public fake = address(2);
    ERC6551Registry public registry;
    ERC6551Account public accountImpl;
    Easel public easel;
    BaseMetadataExtension public baseMetadataExtension;
    TraitMetadataExtension public traitMetadataExtension;
    TokenFactory public tokenFactoryImpl;
    TokenFactory public tokenFactoryProxy;
    ERC721Rails public erc721Rails;
    ERC1155Rails public erc1155Rails;
    EquippableExtension public equippableExtension;
    RegistryExtension public registryExtension;
    address payable erc1155tokenContract;
    address payable erc721tokenContract;
    bytes32 salt = 0x00000000;
    string public file;
    uint8 paletteIndex = 0;

    struct Trait {
      bytes rleBytes;
      string filename;
    }

    string glassesSVG = 'data:application/json;base64,eyJuYW1lIjogIk5QQyBUcmFpdCAjMSIsICJkZXNjcmlwdGlvbiI6ICJUcmFpdCB0byBlcXVpcCB0byBOUEMuIiwgImltYWdlIjogImRhdGE6aW1hZ2Uvc3ZnK3htbDtiYXNlNjQsUEhOMlp5QjNhV1IwYUQwaU16SXdJaUJvWldsbmFIUTlJak15TUNJZ2RtbGxkMEp2ZUQwaU1DQXdJRE15TUNBek1qQWlJSGh0Ykc1elBTSm9kSFJ3T2k4dmQzZDNMbmN6TG05eVp5OHlNREF3TDNOMlp5SWdjMmhoY0dVdGNtVnVaR1Z5YVc1blBTSmpjbWx6Y0VWa1oyVnpJajQ4Y21WamRDQjNhV1IwYUQwaU1UQXdKU0lnYUdWcFoyaDBQU0l4TURBbElpQm1hV3hzUFNJalpEVmtOMlV4SWlBdlBqeHlaV04wSUhkcFpIUm9QU0l4TkRBaUlHaGxhV2RvZEQwaU1UQWlJSGc5SWprd0lpQjVQU0l5TVRBaUlHWnBiR3c5SWlOak5XSTVZVEVpSUM4K1BISmxZM1FnZDJsa2RHZzlJakUwTUNJZ2FHVnBaMmgwUFNJeE1DSWdlRDBpT1RBaUlIazlJakl5TUNJZ1ptbHNiRDBpSTJNMVlqbGhNU0lnTHo0OGNtVmpkQ0IzYVdSMGFEMGlNVFF3SWlCb1pXbG5hSFE5SWpFd0lpQjRQU0k1TUNJZ2VUMGlNak13SWlCbWFXeHNQU0lqWXpWaU9XRXhJaUF2UGp4eVpXTjBJSGRwWkhSb1BTSXhOREFpSUdobGFXZG9kRDBpTVRBaUlIZzlJamt3SWlCNVBTSXlOREFpSUdacGJHdzlJaU5qTldJNVlURWlJQzgrUEhKbFkzUWdkMmxrZEdnOUlqSXdJaUJvWldsbmFIUTlJakV3SWlCNFBTSTVNQ0lnZVQwaU1qVXdJaUJtYVd4c1BTSWpZelZpT1dFeElpQXZQanh5WldOMElIZHBaSFJvUFNJeE1UQWlJR2hsYVdkb2REMGlNVEFpSUhnOUlqRXlNQ0lnZVQwaU1qVXdJaUJtYVd4c1BTSWpZelZpT1dFeElpQXZQanh5WldOMElIZHBaSFJvUFNJeU1DSWdhR1ZwWjJoMFBTSXhNQ0lnZUQwaU9UQWlJSGs5SWpJMk1DSWdabWxzYkQwaUkyTTFZamxoTVNJZ0x6NDhjbVZqZENCM2FXUjBhRDBpTVRFd0lpQm9aV2xuYUhROUlqRXdJaUI0UFNJeE1qQWlJSGs5SWpJMk1DSWdabWxzYkQwaUkyTTFZamxoTVNJZ0x6NDhjbVZqZENCM2FXUjBhRDBpTWpBaUlHaGxhV2RvZEQwaU1UQWlJSGc5SWprd0lpQjVQU0l5TnpBaUlHWnBiR3c5SWlOak5XSTVZVEVpSUM4K1BISmxZM1FnZDJsa2RHZzlJakV4TUNJZ2FHVnBaMmgwUFNJeE1DSWdlRDBpTVRJd0lpQjVQU0l5TnpBaUlHWnBiR3c5SWlOak5XSTVZVEVpSUM4K1BISmxZM1FnZDJsa2RHZzlJakl3SWlCb1pXbG5hSFE5SWpFd0lpQjRQU0k1TUNJZ2VUMGlNamd3SWlCbWFXeHNQU0lqWXpWaU9XRXhJaUF2UGp4eVpXTjBJSGRwWkhSb1BTSXhNVEFpSUdobGFXZG9kRDBpTVRBaUlIZzlJakV5TUNJZ2VUMGlNamd3SWlCbWFXeHNQU0lqWXpWaU9XRXhJaUF2UGp4eVpXTjBJSGRwWkhSb1BTSXlNQ0lnYUdWcFoyaDBQU0l4TUNJZ2VEMGlPVEFpSUhrOUlqSTVNQ0lnWm1sc2JEMGlJMk0xWWpsaE1TSWdMejQ4Y21WamRDQjNhV1IwYUQwaU1URXdJaUJvWldsbmFIUTlJakV3SWlCNFBTSXhNakFpSUhrOUlqSTVNQ0lnWm1sc2JEMGlJMk0xWWpsaE1TSWdMejQ4Y21WamRDQjNhV1IwYUQwaU1qQWlJR2hsYVdkb2REMGlNVEFpSUhnOUlqa3dJaUI1UFNJek1EQWlJR1pwYkd3OUlpTmpOV0k1WVRFaUlDOCtQSEpsWTNRZ2QybGtkR2c5SWpFeE1DSWdhR1ZwWjJoMFBTSXhNQ0lnZUQwaU1USXdJaUI1UFNJek1EQWlJR1pwYkd3OUlpTmpOV0k1WVRFaUlDOCtQSEpsWTNRZ2QybGtkR2c5SWpJd0lpQm9aV2xuYUhROUlqRXdJaUI0UFNJNU1DSWdlVDBpTXpFd0lpQm1hV3hzUFNJall6VmlPV0V4SWlBdlBqeHlaV04wSUhkcFpIUm9QU0l4TVRBaUlHaGxhV2RvZEQwaU1UQWlJSGc5SWpFeU1DSWdlVDBpTXpFd0lpQm1hV3hzUFNJall6VmlPV0V4SWlBdlBqd3ZjM1puUGc9PSJ9';
    string headGlassesSVG = 'data:application/json;base64,eyJuYW1lIjogIk5QQyAjMCIsICJkZXNjcmlwdGlvbiI6ICJOb3VuIFBsYXlhYmxlIENoYXJhY3RlciIsICJpbWFnZSI6ICJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUIzYVdSMGFEMGlNekl3SWlCb1pXbG5hSFE5SWpNeU1DSWdkbWxsZDBKdmVEMGlNQ0F3SURNeU1DQXpNakFpSUhodGJHNXpQU0pvZEhSd09pOHZkM2QzTG5jekxtOXlaeTh5TURBd0wzTjJaeUlnYzJoaGNHVXRjbVZ1WkdWeWFXNW5QU0pqY21semNFVmtaMlZ6SWo0OGNtVmpkQ0IzYVdSMGFEMGlNVEF3SlNJZ2FHVnBaMmgwUFNJeE1EQWxJaUJtYVd4c1BTSWpaRFZrTjJVeElpQXZQanh5WldOMElIZHBaSFJvUFNJeE5EQWlJR2hsYVdkb2REMGlNVEFpSUhnOUlqa3dJaUI1UFNJeU1UQWlJR1pwYkd3OUlpTmpOV0k1WVRFaUlDOCtQSEpsWTNRZ2QybGtkR2c5SWpFME1DSWdhR1ZwWjJoMFBTSXhNQ0lnZUQwaU9UQWlJSGs5SWpJeU1DSWdabWxzYkQwaUkyTTFZamxoTVNJZ0x6NDhjbVZqZENCM2FXUjBhRDBpTVRRd0lpQm9aV2xuYUhROUlqRXdJaUI0UFNJNU1DSWdlVDBpTWpNd0lpQm1hV3hzUFNJall6VmlPV0V4SWlBdlBqeHlaV04wSUhkcFpIUm9QU0l4TkRBaUlHaGxhV2RvZEQwaU1UQWlJSGc5SWprd0lpQjVQU0l5TkRBaUlHWnBiR3c5SWlOak5XSTVZVEVpSUM4K1BISmxZM1FnZDJsa2RHZzlJakl3SWlCb1pXbG5hSFE5SWpFd0lpQjRQU0k1TUNJZ2VUMGlNalV3SWlCbWFXeHNQU0lqWXpWaU9XRXhJaUF2UGp4eVpXTjBJSGRwWkhSb1BTSXhNVEFpSUdobGFXZG9kRDBpTVRBaUlIZzlJakV5TUNJZ2VUMGlNalV3SWlCbWFXeHNQU0lqWXpWaU9XRXhJaUF2UGp4eVpXTjBJSGRwWkhSb1BTSXlNQ0lnYUdWcFoyaDBQU0l4TUNJZ2VEMGlPVEFpSUhrOUlqSTJNQ0lnWm1sc2JEMGlJMk0xWWpsaE1TSWdMejQ4Y21WamRDQjNhV1IwYUQwaU1URXdJaUJvWldsbmFIUTlJakV3SWlCNFBTSXhNakFpSUhrOUlqSTJNQ0lnWm1sc2JEMGlJMk0xWWpsaE1TSWdMejQ4Y21WamRDQjNhV1IwYUQwaU1qQWlJR2hsYVdkb2REMGlNVEFpSUhnOUlqa3dJaUI1UFNJeU56QWlJR1pwYkd3OUlpTmpOV0k1WVRFaUlDOCtQSEpsWTNRZ2QybGtkR2c5SWpFeE1DSWdhR1ZwWjJoMFBTSXhNQ0lnZUQwaU1USXdJaUI1UFNJeU56QWlJR1pwYkd3OUlpTmpOV0k1WVRFaUlDOCtQSEpsWTNRZ2QybGtkR2c5SWpJd0lpQm9aV2xuYUhROUlqRXdJaUI0UFNJNU1DSWdlVDBpTWpnd0lpQm1hV3hzUFNJall6VmlPV0V4SWlBdlBqeHlaV04wSUhkcFpIUm9QU0l4TVRBaUlHaGxhV2RvZEQwaU1UQWlJSGc5SWpFeU1DSWdlVDBpTWpnd0lpQm1hV3hzUFNJall6VmlPV0V4SWlBdlBqeHlaV04wSUhkcFpIUm9QU0l5TUNJZ2FHVnBaMmgwUFNJeE1DSWdlRDBpT1RBaUlIazlJakk1TUNJZ1ptbHNiRDBpSTJNMVlqbGhNU0lnTHo0OGNtVmpkQ0IzYVdSMGFEMGlNVEV3SWlCb1pXbG5hSFE5SWpFd0lpQjRQU0l4TWpBaUlIazlJakk1TUNJZ1ptbHNiRDBpSTJNMVlqbGhNU0lnTHo0OGNtVmpkQ0IzYVdSMGFEMGlNakFpSUdobGFXZG9kRDBpTVRBaUlIZzlJamt3SWlCNVBTSXpNREFpSUdacGJHdzlJaU5qTldJNVlURWlJQzgrUEhKbFkzUWdkMmxrZEdnOUlqRXhNQ0lnYUdWcFoyaDBQU0l4TUNJZ2VEMGlNVEl3SWlCNVBTSXpNREFpSUdacGJHdzlJaU5qTldJNVlURWlJQzgrUEhKbFkzUWdkMmxrZEdnOUlqSXdJaUJvWldsbmFIUTlJakV3SWlCNFBTSTVNQ0lnZVQwaU16RXdJaUJtYVd4c1BTSWpZelZpT1dFeElpQXZQanh5WldOMElIZHBaSFJvUFNJeE1UQWlJR2hsYVdkb2REMGlNVEFpSUhnOUlqRXlNQ0lnZVQwaU16RXdJaUJtYVd4c1BTSWpZelZpT1dFeElpQXZQand2YzNablBnPT0ifQ==';

    function setUp() public {
      registry = new ERC6551Registry();
      accountImpl = new ERC6551Account();
      easel = new Easel();
      erc721Rails = new ERC721Rails();
      erc1155Rails = new ERC1155Rails();
      equippableExtension = new EquippableExtension();
      registryExtension = new RegistryExtension();
      baseMetadataExtension = new BaseMetadataExtension(address(easel), address(registry));
      traitMetadataExtension = new TraitMetadataExtension(address(easel));

      tokenFactoryImpl = new TokenFactory();
      tokenFactoryProxy = TokenFactory(address(new ERC1967Proxy(address(tokenFactoryImpl), '')));
      tokenFactoryProxy.initialize(caller, fake, address(erc721Rails), address(erc1155Rails));

      erc1155tokenContract = this.deployTraitContract();
      erc721tokenContract = this.deployCitizenContract();

      IBaseMetadataExtension(erc721tokenContract).ext_setup(
        address(registry),
        address(easel),
        erc1155tokenContract,
        address(accountImpl),
        block.chainid,
        bytes32(0)
      );

      ITraitMetadataExtension(erc1155tokenContract).ext_setup(address(easel));

      file = readInput("image-data-v1");
      addColorsToEasel(".palette");
      addTraitsToRegistry(".images.bodies");
    }

    function deployCitizenContract() public returns (address payable) {
      vm.startPrank(caller);
      bytes memory addSetupMetadata = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IBaseMetadataExtension.ext_setup.selector, address(baseMetadataExtension));

      bytes memory addTokenURIExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IBaseMetadataExtension.ext_tokenURI.selector, address(baseMetadataExtension));

      bytes memory addContractURIExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector,
        IBaseMetadataExtension.ext_contractURI.selector,
        address(baseMetadataExtension));

      bytes[] memory initCalls = new bytes[](3);
      initCalls[0] = addSetupMetadata;
      initCalls[1] = addTokenURIExtension;
      initCalls[2] = addContractURIExtension;

      bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, initCalls);

      address payable tokenContract = tokenFactoryProxy.createERC721(
        payable(erc721Rails),
        salt,
        caller,
        "Noun Citizens",
        "NPC",
        initData
      );
      vm.stopPrank();

      return tokenContract;
    }

    function deployTraitContract() public returns (address payable) {
      vm.startPrank(caller);

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

      bytes memory addSetupMetadata = abi.encodeWithSelector(
        IExtensions.setExtension.selector, ITraitMetadataExtension.ext_setup.selector, address(traitMetadataExtension));

      bytes memory addTokenURIExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, ITraitMetadataExtension.ext_tokenURI.selector, address(traitMetadataExtension));

      bytes memory addContractURIExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector,
        ITraitMetadataExtension.ext_contractURI.selector,
        address(traitMetadataExtension));

      bytes[] memory initCalls = new bytes[](9);
      initCalls[0] = addAddTokenIdExtension;
      initCalls[1] = addRemoveTokenIdExtension;
      initCalls[2] = addGetAllExtension;
      initCalls[3] = addIsTokenIdEquippedExtension;
      initCalls[4] = addRegisterTraitExtension;
      initCalls[5] = addGetImageDataExtension;
      initCalls[6] = addSetupMetadata;
      initCalls[7] = addTokenURIExtension;
      initCalls[8] = addContractURIExtension;

      bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, initCalls);

      address payable tokenContract = tokenFactoryProxy.createERC1155(
        payable(erc1155Rails),
        salt,
        caller,
        "NPC Trait",
        "NPCT",
        initData
      );
      vm.stopPrank();

      return tokenContract;
    }

    function readInput(string memory input) view internal returns (string memory) {
      string memory inputDir = string.concat(vm.projectRoot(), "/script/input/");
      string memory filePath = string.concat(input, ".json");
      return vm.readFile(string.concat(inputDir, filePath));
    }

    function addColorsToEasel(string memory path) public {
      bytes memory values = vm.parseJson(file, path);
      string[] memory newColors = abi.decode(values, (string[]));
      IEasel(easel).addManyColorsToPalette(paletteIndex, newColors);
    }

    function decodeImageType(string memory path) view internal returns (Trait[] memory) {
      bytes memory values = vm.parseJson(file, path);
      Trait[] memory decode = abi.decode(values, (Trait[]));
      return decode;
    }

    function addTraitsToRegistry(string memory path) public {
      Trait[] memory decode = decodeImageType(path);
      for (uint256 i = 0; i < decode.length; i++) {
        Trait memory trait = decode[i];
        IRegistryExtension(erc1155tokenContract).ext_registerTrait(trait.rleBytes, trait.filename);
      }
    }

    function test_Complete() public {
      vm.startPrank(caller);
      uint256 tokenId = 0;
      address tbaAddress = registry.account(address(accountImpl), bytes32(0), block.chainid, address(erc721tokenContract), tokenId);
      IERC1155Rails(address(erc1155tokenContract)).mintTo(tbaAddress, 1, 1);

      IEquippableExtension(address(erc1155tokenContract)).ext_addTokenId(tbaAddress, 1, 0);
      assertEq(ERC721Rails(erc721tokenContract).name(), "Noun Citizens");
      assertEq(ERC721Rails(erc721tokenContract).tokenURI(tokenId), headGlassesSVG);
      // assertEq(ERC721Rails(erc721tokenContract).contractURI(), "TEMP_CONTRACT_URI");

      // 1155 NFT rendering
      assertEq(ERC1155Rails(erc1155tokenContract).uri(1), glassesSVG);
      vm.stopPrank();
    }
}
