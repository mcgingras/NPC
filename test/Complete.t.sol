// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { ERC721Rails } from "0xrails/cores/ERC721/ERC721Rails.sol";
import { ERC1155Rails } from "0xrails/cores/ERC1155/ERC1155Rails.sol";
import { IERC1155Rails } from "0xrails/cores/ERC1155/interface/IERC1155Rails.sol";
import {IExtensions} from "0xrails/extension/interface/IExtensions.sol";
import {Multicall} from "openzeppelin-contracts/utils/Multicall.sol";
import { Easel } from "../src/Easel.sol";
import { ERC6551Registry } from "../src/ERC6551Registry.sol";
import { ERC6551Account } from "../src/ERC6551Account.sol";
import { TokenFactory } from "groupos/factory/TokenFactory.sol";
import { TokenMetadataExtension } from "../src/extensions/tokenMetadata/tokenMetadataExtension.sol";
import { ITokenMetadataExtension } from "../src/extensions/tokenMetadata/ITokenMetadataExtension.sol";
import { EquippableExtension } from "../src/extensions/equippable/EquippableExtension.sol";
import { IEquippableExtension } from "../src/extensions/equippable/IEquippableExtension.sol";
import { RegistryExtension } from "../src/extensions/registry/RegistryExtension.sol";
import { IRegistryExtension } from "../src/extensions/registry/IRegistryExtension.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { IEasel } from "../src/interfaces/IEasel.sol";



/// @title CompleteTest
/// @author frog @0xmcg
/// @notice E2E test.
contract CompleteTest is Test {
    address public caller = address(1);
    address public fake = address(2);
    ERC6551Registry public registry;
    ERC6551Account public accountImpl;
    Easel public easel;
    TokenMetadataExtension public tokenMetadataExtension;
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

    string headGlassesSVG = '<svg width="320" height="320" viewBox="0 0 320 320" xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges"><rect width="100%" height="100%" fill="#d5d7e1" /><rect width="140" height="10" x="90" y="210" fill="#c5b9a1" /><rect width="140" height="10" x="90" y="220" fill="#c5b9a1" /><rect width="140" height="10" x="90" y="230" fill="#c5b9a1" /><rect width="140" height="10" x="90" y="240" fill="#c5b9a1" /><rect width="20" height="10" x="90" y="250" fill="#c5b9a1" /><rect width="110" height="10" x="120" y="250" fill="#c5b9a1" /><rect width="20" height="10" x="90" y="260" fill="#c5b9a1" /><rect width="110" height="10" x="120" y="260" fill="#c5b9a1" /><rect width="20" height="10" x="90" y="270" fill="#c5b9a1" /><rect width="110" height="10" x="120" y="270" fill="#c5b9a1" /><rect width="20" height="10" x="90" y="280" fill="#c5b9a1" /><rect width="110" height="10" x="120" y="280" fill="#c5b9a1" /><rect width="20" height="10" x="90" y="290" fill="#c5b9a1" /><rect width="110" height="10" x="120" y="290" fill="#c5b9a1" /><rect width="20" height="10" x="90" y="300" fill="#c5b9a1" /><rect width="110" height="10" x="120" y="300" fill="#c5b9a1" /><rect width="20" height="10" x="90" y="310" fill="#c5b9a1" /><rect width="110" height="10" x="120" y="310" fill="#c5b9a1" /></svg>';

    function setUp() public {
      registry = new ERC6551Registry();
      accountImpl = new ERC6551Account();
      easel = new Easel();
      erc721Rails = new ERC721Rails();
      erc1155Rails = new ERC1155Rails();
      equippableExtension = new EquippableExtension();
      registryExtension = new RegistryExtension();
      tokenMetadataExtension = new TokenMetadataExtension(address(easel), address(registry));

      tokenFactoryImpl = new TokenFactory();
      tokenFactoryProxy = TokenFactory(address(new ERC1967Proxy(address(tokenFactoryImpl), '')));
      tokenFactoryProxy.initialize(caller, fake, address(erc721Rails), address(erc1155Rails));

      erc1155tokenContract = this.deployTraitContract();
      erc721tokenContract = this.deployCitizenContract();
      ITokenMetadataExtension(
        erc721tokenContract).ext_setup(address(registry),
        address(easel),
        erc1155tokenContract,
        address(accountImpl),
        block.chainid,
        bytes32(0)
      );

      file = readInput("image-data-v1");
      addColorsToEasel(".palette");
      addTraitsToRegistry(".images.bodies");
    }

    function deployCitizenContract() public returns (address payable) {
      vm.startPrank(caller);
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

      bytes[] memory initCalls = new bytes[](6);
      initCalls[0] = addAddTokenIdExtension;
      initCalls[1] = addRemoveTokenIdExtension;
      initCalls[2] = addGetAllExtension;
      initCalls[3] = addIsTokenIdEquippedExtension;
      initCalls[4] = addRegisterTraitExtension;
      initCalls[5] = addGetImageDataExtension;

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
      vm.stopPrank();
    }
}
