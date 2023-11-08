// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Multicall} from "../lib/openzeppelin-contracts/contracts/utils/Multicall.sol";
import {Permissions} from "0xrails/access/permissions/Permissions.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {IExtensions} from "0xrails/extension/interface/IExtensions.sol";


interface ITokenFactory {
  function createERC721(
    address payable implementation,
    address owner,
    string memory name,
    string memory symbol,
    bytes calldata initData
  ) external returns (address payable token);
}

contract DeployCitizen is Script {
    /*============
        CONFIG
    ============*/

    address public owner = address(1);
    address public frog = address(2);
    string public name = "Noun Citizens";
    string public symbol = "NPC";

    /// @notice GOERLI: v1.0.0
    address tokenFactory = 0x66B28Cc146A1a2cDF1073C2875D070733C7d01Af;
    address coreImpl = 0x3F4f3680c80DBa28ae43FbE160420d4Ad8ca50E4;
    // address public coreImpl = 0x...

    function run() public {
        vm.startBroadcast();

        // // EXTENSIONS
        // bytes memory addTokenURIExtension = abi.encodeWithSelector(
        //     IExtensions.setExtension.selector, INFTMetadata.ext_tokenURI.selector, address(NFTMetadataRouterExtension)
        // );
        // bytes memory addContractURIExtension = abi.encodeWithSelector(
        //     IExtensions.setExtension.selector,
        //     INFTMetadata.ext_contractURI.selector,
        //     address(NFTMetadataRouterExtension)
        // );

        // // PERMISSIONS
        // // replace with new module
        // // bytes memory permitModuleMint =
        // //     abi.encodeWithSelector(Permissions.addPermission.selector, Operations.MINT, mintModule);
        // bytes memory permitFrogAdmin =
        //     abi.encodeWithSelector(Permissions.addPermission.selector, Operations.ADMIN, frog);

        // // INIT
        // bytes[] memory initCalls = new bytes[](3);
        // initCalls[0] = addTokenURIExtension;
        // initCalls[1] = addContractURIExtension;
        // initCalls[2] = permitFrogAdmin;
        // // initCalls[3] = permitModuleMint;


        // bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, initCalls);

        // ITokenFactory(tokenFactory).createERC721(payable(coreImpl), owner, name, symbol, initData);

        vm.stopBroadcast();
    }
}
