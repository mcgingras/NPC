// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// Note: kind of annoying fault is that this will let you add the same trait twice.
/// What we are rolling with for now is that the base 1155 will only call these after
/// cehcking the precondition that the trait is not already owned.
contract ERC1155Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) private _ownedTokens;

    // Mapping from token ID to index in the owner's list of tokens
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Mapping from owner to number of owned tokens
    mapping(address => uint256) private _ownedTokensCount;


    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) internal {
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
        _ownedTokensCount[to] += 1;
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) internal {
        // To remove a token, we swap it with the last one in the array and then delete the last one
        // this avoids creating gaps and keeps the array compact.

        // Get the last token ID and its index
        uint256 lastTokenIndex = _ownedTokens[from].length - 1;
        uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

        // Get the token to remove's index
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // Move the last token to the slot of the to-be-removed token
        _ownedTokens[from][tokenIndex] = lastTokenId;
        _ownedTokensIndex[lastTokenId] = tokenIndex;

        // Remove the last token's data and update the count
        _ownedTokens[from].pop();
        _ownedTokensCount[from] -= 1;

        // Clean up the removed token's data
        delete _ownedTokensIndex[tokenId];
    }


    // A public function to list all token IDs owned by an address
    function tokensOfOwner(address owner) external view returns(uint256[] memory) {
        return _ownedTokens[owner];
    }
}
