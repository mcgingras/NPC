## Nouns Playable Citizens (NPC)

### Todo

- [] totally free mint module for base (can we have no module and remove permissions for mint?)
- [] time based mint
- [] capped supply mint
- [] update ext_contractURI for tokenMetadataExtension + metadataExtension
- [] traits as "trait" of NPC (tokenURI details... make it so the traits owned by an NPC show up as traits of the the NPC...)
- [] make sure equippable extension is easy to use (might need to improve equipping multiple at once, or what happens with multicall)
- [] make it easy to mint base NFT + deploy 6551 account + possibly mint traits all in one tx? (onboarding UX)

## First time local setup

### 1. Install geth

`geth` is the official implementation of an Ethereum node in Golang. Follow installation instructions [here](https://geth.ethereum.org/docs/install-and-build/installing-geth). We primarily use geth for its wallet functionality to store private keys locally to use in dapptools/foundry.

### 2. Create/Import Private Key

You can use `geth account new` to generate a new private key & public address to use for development, or you can copy a private key from one of your personal wallets and use `geth account import`.

Use `geth account list` to view your list of hosted private keys.

### 3. Env Variables

```
ETH_FROM=
ETH_KEYSTORE=
KEYSTORE_PASSWORD=
ALCHEMY_API_KEY=
SEPOLIA_RPC_URL=https://eth-goerli.alchemyapi.io/v2/$ALCHEMY_API_KEY
MAINNET_RPC_URL=https://eth-mainnet.alchemyapi.io/v2/$ALCHEMY_API_KEY
```

**3a. Account Setup**

After creating or importing a wallet, use `geth account list` to view the "keystore" files on your computer. Choose the wallet you'd like to use for development by saving environment variables for the public address as `ETH_FROM` and the keystore file path as `ETH_KEYSTORE`. For example: `ETH_FROM=0x7ff6363cd3a4e7f9ece98d78dd3c862bace2163d` and `ETH_KEYSTORE=/Users/demo-user/Library/Ethereum/keystore/UTC--2021-11-16T09-41-57.123259000Z--7ff6363cd3a4e7f9ece98d78dd3c862bace2163d`.

Additionally, save the local password you made for this keystore as `KEYSTORE_PASSWORD`.

**3b. RPC Setup**

Next, get an `ALCHEMY_API_KEY` from the Alchemy dashboard. Infura works too, but you'll have to update .env file.

### 4. Install Foundry

- [Foundry](https://github.com/foundry-rs/foundry#installation) -> provides the `forge`, `cast`, and `anvil` CLIs.

### Installation

1. `forge i`
2. `forge c`

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

Guards protect certain types of transactions. For example, we can add a tranfer guard to add extra logic to occur before or after a transfer.

### Modules

Modules can be enabled with certain permissions. For example, we can have a minting module which has mint permission on a given token contract. The module has permission to mint, so we can add logic to the module such that people can mint through the module (conditional on the logic applying to them). Modules are flexible and can be added / removed. Examples of modules might be requiring a certain amount of ETH payment before minting. Or only allowing minting during a certain time frame.
