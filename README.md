## Nouns Playable Citizens (NPC)

### Todo

- [] mint module
- [] fees + payment split (can we just use fee manager from rails this?)
- https://github.com/0xStation/groupos/blob/e94b09e63f422e14e066066424c2320be2b127c7/src/membership/modules/StablecoinPurchaseController.sol#L79 (fee)
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
