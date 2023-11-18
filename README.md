## Nouns Playable Citizens (NPC)

### Todo

- [] permissions (onlyOwner etc) access... is this handled by rails?
- [] figure out account related business
- [] equip + transfer guard
- [] mint module
- [] deploy scripts
- [] fees + payment split (can we just use fee manager from rails this?)
- https://github.com/0xStation/groupos/blob/e94b09e63f422e14e066066424c2320be2b127c7/src/membership/modules/StablecoinPurchaseController.sol#L79 (fee)
- [] traits as "trait" of NPC

### Extensions

Extensions extend the capabilities of a core standard. In our case, we extend ERC721 and ERC1155 with metadata rendering logic. Staking might be another example.
OxRails core contracts inherit `extension` which offers us a way to register extensions to the contract.

### Guards

### Modules
