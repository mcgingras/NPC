// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library BaseMetadataExtensionData {
    bytes32 internal constant SLOT = keccak256(abi.encode(uint256(keccak256("0xrails.Extensions.BaseMetadataExtension")) - 1));

    struct Account {
      address traitContractAddress; // address of the trait contract to derive tokenURI from
      address implementation; // erc6551 account implementation
      uint256 chainId; // chainId for TBA
      bytes32 salt; // salt for TBA
    }

    struct Layout {
        address easel; // TODO: make this a mapping of address => "rendering contract"
        address erc6551Registry;
        mapping(address => Account) accountConfigs;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = SLOT;
        assembly {
            l.slot := slot
        }
    }
}
