
# Oracle Project

This project is an Ethereum Oracle that updates ETH price in USD, EUR, and BTC. It uses Solidity for the smart contract, Rust for the off-chain worker, Foundry for testing and deploying the contract, and ethers-rs for Ethereum wallet management and contract interaction.

## Prerequisites

- [Foundry](https://github.com/gakonst/foundry) for compiling and testing Solidity contracts.
- [Rust](https://www.rust-lang.org/tools/install) for running the off-chain worker.

## File Structure

- `contracts/`: Contains Foundry contracts.
- `oracle-node/`: Contains the Rust oracle that updates the contract with the latest prices.
- `oracle-node/abis/`: Folder for storing contract ABIs needed by the Rust code.

## Smart Contract

Start by testing the contract:

```bash
cd contracts/
```

```bash
forge test
```

Build the contract:

```bash
forge build
```

Deploy the contract using Foundry:

```bash
forge create --rpc-url <network_rpc_url> --private-key <wallet_private_key> src/Oracle.sol:Oracle
```

Remember to replace `<network_rpc_url>` with the RPC URL of the network you wish to deploy to, and `<wallet_private_key>` with the private key of the wallet that will be used for deployment and has enough balance to cover gas fees.

## Rust Oracle Node

After deploying the smart contract, you need to set up the Rust oracle node.

1. Copy the ABI from the `contracts/out/Oracle.sol/` directory to the `oracle-node/abis` directory.

2. Create a `.env` file in the `oracle-node` directory with the following environment variables:

```env
CONTRACT_ADDR=<deployed_contract_address>
PROVIDER_RPC=<network_rpc_url>
CHAIN_ID=<network_chain_id>
PRIVATE_KEY=<wallet_private_key>
```

Make sure to replace `<deployed_contract_address>`, `<network_rpc_url>`, `<network_chain_id>`, and `<wallet_private_key>` with their respective values.

Given the contents visible in the screenshot you provided and the context of the Oracle project, here's an expanded version of the README section pertaining to running the Oracle Node, which includes additional details that reflect the output and actions taken by the Rust application:

## Running the Oracle Node

### Setup

Before running the Oracle Node, make sure you have:

- Deployed the `Oracle` smart contract and have its address.
- Set up the `.env` file with the necessary environment variables as described in the previous sections of this README.

### Execution

Navigate to the `oracle-node` directory in your terminal and execute the following command:

```bash
cargo run
```

This will compile the Rust oracle-node (if not already compiled) and start the program.

### What to Expect

Upon running the oracle node, the following events will occur:

- The program will fetch the latest ETH prices from the CryptoCompare API every 5 seconds.
- These prices are printed in the console in the `LatestPrices` struct format for initial confirmation. For example: `LatestPrices { BTC: 0.05916, EUR: 2257.71, USD: 2455.55 }`.
- The node will attempt to send a transaction to the Ethereum network with the updated prices. You'll see a "Transaction sent" message with details of the `PendingTransaction`.
- After the transaction is mined, you should see an "Updated prices" message with the details of the `TransactionReceipt`.
- Finally, the updated prices are printed out in the terminal confirming that the smart contract's state variables (`eth_usd_price`, `eth_eur_price`, `eth_btc_price`) have been updated. For example, you might see:
  ```
  Updated USD price: Ok(245555)
  Updated EUR price: Ok(225771)
  Updated BTC price: Ok(5)
  ```

### Troubleshooting

- If the "Failed to update prices" message appears, check your `.env` file for correct environment variable settings and ensure your wallet has enough ETH for gas fees.
- Make sure the Ethereum node (RPC provider) you're connected to is fully synced and operational.
- If the prices aren't updating, verify that the contract address is correct and that the account used has oracle permissions in the smart contract.

For detailed logs and transaction receipts, refer to the console output. Each transaction will provide a comprehensive receipt once mined, including gas used and the effective gas price.

This README section now provides the user with a thorough understanding of what actions the Oracle Node performs, what output to expect in the console, and some basic troubleshooting steps.

## Notes

- Ensure that the Rust node has uninterrupted internet access and the Ethereum node it connects to remains synced.
- The Rust code provided will print out transaction receipts and updated prices for verification.
- The `.env` file must not be committed to version control for security reasons.

For further assistance or to contribute to the project, please refer to the contribution guidelines.