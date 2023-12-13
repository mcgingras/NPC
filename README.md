## Nouns Playable Citizens (NPC)

### Todo

- [] possibly add the more elaborate "mint module per tokenId" controller?
- [] traits as "trait" of NPC (tokenURI details)

### Manual deployments steps

1. Run through scripts 0-5 in `/script` to deploy (skip if already deployed)
2. Create a 721
3. Initialize the tba for the tokenId of the 721 (can use helper/createAccount)
4. Mint a new trait to the tba
5. "Equip" the trait via the 1155 (can use helper/mintAndEquipTrait for steps 4 + 5)

### Extensions

Extensions extend the capabilities of a core standard. In our case, we extend ERC721 and ERC1155 with metadata rendering logic. Staking might be another example.
OxRails core contracts inherit `extension` which offers us a way to register extensions to the contract.

### Guards

### Modules
