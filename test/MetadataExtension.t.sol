// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { ERC1155Rails } from "0xrails/cores/ERC1155/ERC1155Rails.sol";
import { IERC1155Rails } from "0xrails/cores/ERC1155/interface/IERC1155Rails.sol";
import {IExtensions} from "0xrails/extension/interface/IExtensions.sol";
import {Multicall} from "openzeppelin-contracts/utils/Multicall.sol";
import { Easel } from "../src/Easel.sol";
import { TokenFactory } from "groupos/factory/TokenFactory.sol";
import { MetadataExtension } from "../src/extensions/metadata/MetadataExtension.sol";
import { IMetadataExtension } from "../src/extensions/metadata/IMetadataExtension.sol";
import { RegistryExtension } from "../src/extensions/registry/RegistryExtension.sol";
import { IRegistryExtension } from "../src/extensions/registry/IRegistryExtension.sol";


/// @title MetadataTest
/// @author frog @0xmcg
/// @notice Test for metadata -- which is the tokenURI for an individual trait (not the nested trait for a TBA)
/// maybe should call the other contract "TBAMetadataExtension" or something
contract MetadataTest is Test {
    address public caller = address(1);
    Easel public easel;
    MetadataExtension public metadataExtension;
    TokenFactory public tokenFactory;
    ERC1155Rails public erc1155Rails;
    RegistryExtension public registryExtension;
    address payable erc1155tokenContract;
    address payable erc721tokenContract;

    function setUp() public {
      easel = new Easel();
      tokenFactory = new TokenFactory();
      erc1155Rails = new ERC1155Rails();
      registryExtension = new RegistryExtension();
      metadataExtension = new MetadataExtension(address(easel));

      erc1155tokenContract = this.deployTraitContract();

      _registerTraits();
      _addColorsToPalette();

      IMetadataExtension(erc1155tokenContract).ext_setup(address(easel));
    }


    function deployTraitContract() public returns (address payable) {
      vm.startPrank(caller);
      bytes memory addRegisterTraitExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IRegistryExtension.ext_registerTrait.selector, address(registryExtension)
      );

      bytes memory addGetImageDataExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IRegistryExtension.ext_getImageDataForTrait.selector, address(registryExtension)
      );

      bytes memory addSetupMetadata = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IMetadataExtension.ext_setup.selector, address(metadataExtension));

      bytes memory addTokenURIExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IMetadataExtension.ext_tokenURI.selector, address(metadataExtension));

      bytes memory addContractURIExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector,
        IMetadataExtension.ext_contractURI.selector,
        address(metadataExtension));

      bytes[] memory initCalls = new bytes[](5);
      initCalls[0] = addRegisterTraitExtension;
      initCalls[1] = addGetImageDataExtension;
      initCalls[2] = addSetupMetadata;
      initCalls[3] = addTokenURIExtension;
      initCalls[4] = addContractURIExtension;

      bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, initCalls);

      address payable tokenContract = tokenFactory.createERC1155(
        payable(erc1155Rails),
        caller,
        "NPC Trait",
        "NPCT",
        initData
      );
      vm.stopPrank();

      return tokenContract;
    }

    function _registerTraits() internal {
      vm.startPrank(caller);
      bytes memory body =  hex"0015171f090e190e190e190e19021901000b19021901000b19021901000b19021901000b19021901000b19021901000b19021901000b19";
      bytes memory glasses = hex"000b17100703000609010006090300010902010223010901000109020102230109040902010223030902010223010901090200010902010223010901000109020102230109010902000109020102230109010001090201022301090300060901000609";

      IRegistryExtension(address(erc1155tokenContract)).ext_registerTrait(body, "body");
      IRegistryExtension(address(erc1155tokenContract)).ext_registerTrait(glasses, "glasses");
      vm.stopPrank();
    }

    function _addColorsToPalette() internal {
      uint8 _paletteIndex = 0;
      string[] memory newColors = new string[](239);
      newColors[0] = "c5b9a1";
      newColors[1] = "ffffff";
      newColors[2] = "cfc2ab";
      newColors[3] = "63a0f9";
      newColors[4] = "807f7e";
      newColors[5] = "caeff9";
      newColors[6] = "5648ed";
      newColors[7] = "5a423f";
      newColors[8] = "b9185c";
      newColors[9] = "cbc1bc";
      newColors[10] = "b87b11";
      newColors[11] = "fffdf2";
      newColors[12] = "4b4949";
      newColors[13] = "343235";
      newColors[14] = "1f1d29";
      newColors[15] = "068940";
      newColors[16] = "867c1d";
      newColors[17] = "ae3208";
      newColors[18] = "9f21a0";
      newColors[19] = "f98f30";
      newColors[20] = "fe500c";
      newColors[21] = "d26451";
      newColors[22] = "fd8b5b";
      newColors[23] = "5a65fa";
      newColors[24] = "d22209";
      newColors[25] = "e9265c";
      newColors[26] = "c54e38";
      newColors[27] = "80a72d";
      newColors[28] = "4bea69";
      newColors[29] = "34ac80";
      newColors[30] = "eed811";
      newColors[31] = "62616d";
      newColors[32] = "ff638d";
      newColors[33] = "8bc0c5";
      newColors[34] = "c4da53";
      newColors[35] = "000000";
      newColors[36] = "f3322c";
      newColors[37] = "ffae1a";
      newColors[38] = "ffc110";
      newColors[39] = "505a5c";
      newColors[40] = "ffef16";
      newColors[41] = "fff671";
      newColors[42] = "fff449";
      newColors[43] = "db8323";
      newColors[44] = "df2c39";
      newColors[45] = "f938d8";
      newColors[46] = "5c25fb";
      newColors[47] = "2a86fd";
      newColors[48] = "45faff";
      newColors[49] = "38dd56";
      newColors[50] = "ff3a0e";
      newColors[51] = "d32a09";
      newColors[52] = "903707";
      newColors[53] = "6e3206";
      newColors[54] = "552e05";
      newColors[55] = "e8705b";
      newColors[56] = "f38b7c";
      newColors[57] = "e4a499";
      newColors[58] = "667af9";
      newColors[60] = "648df9";
      newColors[61] = "7cc4f2";
      newColors[62] = "97f2fb";
      newColors[63] = "a3efd0";
      newColors[64] = "87e4d9";
      newColors[65] = "71bde4";
      newColors[66] = "ff1a0b";
      newColors[67] = "f78a18";
      newColors[68] = "2b83f6";
      newColors[69] = "d62149";
      newColors[70] = "834398";
      newColors[71] = "ffc925";
      newColors[72] = "d9391f";
      newColors[73] = "bd2d24";
      newColors[74] = "ff7216";
      newColors[75] = "254efb";
      newColors[76] = "e5e5de";
      newColors[77] = "00a556";
      newColors[78] = "c5030e";
      newColors[79] = "abf131";
      newColors[80] = "fb4694";
      newColors[81] = "e7a32c";
      newColors[82] = "fff0ee";
      newColors[83] = "009c59";
      newColors[84] = "0385eb";
      newColors[85] = "00499c";
      newColors[86] = "e11833";
      newColors[87] = "26b1f3";
      newColors[88] = "fff0be";
      newColors[89] = "d8dadf";
      newColors[90] = "d7d3cd";
      newColors[91] = "1929f4";
      newColors[92] = "eab118";
      newColors[93] = "0b5027";
      newColors[94] = "f9f5cb";
      newColors[95] = "cfc9b8";
      newColors[96] = "feb9d5";
      newColors[97] = "f8d689";
      newColors[98] = "5d6061";
      newColors[99] = "76858b";
      newColors[100] = "757576";
      newColors[101] = "ff0e0e";
      newColors[102] = "0adc4d";
      newColors[103] = "fdf8ff";
      newColors[104] = "70e890";
      newColors[105] = "f7913d";
      newColors[106] = "ff1ad2";
      newColors[107] = "ff82ad";
      newColors[108] = "535a15";
      newColors[109] = "fa6fe2";
      newColors[110] = "ffe939";
      newColors[111] = "ab36be";
      newColors[112] = "adc8cc";
      newColors[113] = "604666";
      newColors[114] = "f20422";
      newColors[115] = "abaaa8";
      newColors[116] = "4b65f7";
      newColors[117] = "a19c9a";
      newColors[118] = "58565c";
      newColors[119] = "da42cb";
      newColors[120] = "027c92";
      newColors[121] = "cec189";
      newColors[122] = "909b0e";
      newColors[123] = "74580d";
      newColors[124] = "027ee6";
      newColors[125] = "b2958d";
      newColors[126] = "efad81";
      newColors[127] = "7d635e";
      newColors[128] = "eff2fa";
      newColors[129] = "6f597a";
      newColors[130] = "d4b7b2";
      newColors[131] = "d18687";
      newColors[132] = "cd916d";
      newColors[133] = "6b3f39";
      newColors[134] = "4d271b";
      newColors[135] = "85634f";
      newColors[136] = "f9f4e6";
      newColors[137] = "f8ddb0";
      newColors[138] = "b92b3c";
      newColors[139] = "d08b11";
      newColors[140] = "257ced";
      newColors[141] = "a3baed";
      newColors[142] = "5fd4fb";
      newColors[143] = "c16710";
      newColors[144] = "a28ef4";
      newColors[145] = "3a085b";
      newColors[146] = "67b1e3";
      newColors[147] = "1e3445";
      newColors[148] = "ffd067";
      newColors[149] = "962236";
      newColors[150] = "769ca9";
      newColors[151] = "5a6b7b";
      newColors[152] = "7e5243";
      newColors[153] = "a86f60";
      newColors[154] = "8f785e";
      newColors[155] = "cc0595";
      newColors[156] = "42ffb0";
      newColors[157] = "d56333";
      newColors[158] = "b8ced2";
      newColors[159] = "f39713";
      newColors[160] = "e8e8e2";
      newColors[161] = "ec5b43";
      newColors[162] = "235476";
      newColors[163] = "b2a8a5";
      newColors[164] = "d6c3be";
      newColors[165] = "49b38b";
      newColors[166] = "fccf25";
      newColors[167] = "f59b34";
      newColors[168] = "375dfc";
      newColors[169] = "99e6de";
      newColors[170] = "27a463";
      newColors[171] = "554543";
      newColors[172] = "b19e00";
      newColors[173] = "d4a015";
      newColors[174] = "9f4b27";
      newColors[175] = "f9e8dd";
      newColors[176] = "6b7212";
      newColors[177] = "9d8e6e";
      newColors[178] = "4243f8";
      newColors[179] = "fa5e20";
      newColors[180] = "f82905";
      newColors[181] = "555353";
      newColors[182] = "876f69";
      newColors[183] = "410d66";
      newColors[184] = "552d1d";
      newColors[185] = "f71248";
      newColors[186] = "fee3f3";
      newColors[187] = "c16923";
      newColors[188] = "2b2834";
      newColors[189] = "0079fc";
      newColors[190] = "d31e14";
      newColors[191] = "f83001";
      newColors[192] = "8dd122";
      newColors[193] = "fffdf4";
      newColors[194] = "ffa21e";
      newColors[195] = "e4afa3";
      newColors[196] = "fbc311";
      newColors[197] = "aa940c";
      newColors[198] = "eedc00";
      newColors[199] = "fff006";
      newColors[200] = "9cb4b8";
      newColors[201] = "a38654";
      newColors[202] = "ae6c0a";
      newColors[203] = "2bb26b";
      newColors[204] = "e2c8c0";
      newColors[205] = "f89865";
      newColors[206] = "f86100";
      newColors[207] = "dcd8d3";
      newColors[208] = "049d43";
      newColors[209] = "d0aea9";
      newColors[210] = "f39d44";
      newColors[211] = "eeb78c";
      newColors[212] = "f9f5e9";
      newColors[213] = "5d3500";
      newColors[214] = "c3a199";
      newColors[215] = "aaa6a4";
      newColors[216] = "caa26a";
      newColors[217] = "fde7f5";
      newColors[218] = "fdf008";
      newColors[219] = "fdcef2";
      newColors[220] = "f681e6";
      newColors[221] = "018146";
      newColors[222] = "d19a54";
      newColors[223] = "9eb5e1";
      newColors[224] = "f5fcff";
      newColors[225] = "3f9323";
      newColors[226] = "00fcff";
      newColors[227] = "4a5358";
      newColors[228] = "fbc800";
      newColors[229] = "d596a6";
      newColors[230] = "ffb913";
      newColors[231] = "e9ba12";
      newColors[232] = "767c0e";
      newColors[233] = "f9f6d1";
      newColors[234] = "d29607";
      newColors[235] = "f8ce47";
      newColors[236] = "395ed1";
      newColors[237] = "ffc5f0";
      newColors[238] = "d4cfc0";
      easel.addManyColorsToPalette(_paletteIndex, newColors);
    }

    function test_Complete() public {
      vm.startPrank(caller);
      uint256 tokenId1 = 1;
      uint256 tokenId2 = 2;

      assertEq(ERC1155Rails(erc1155tokenContract).uri(tokenId1), "");
      // assertEq(ERC721Rails(erc1155tokenContract).contractURI(), "TEMP_CONTRACT_URI");
      vm.stopPrank();
    }
}
