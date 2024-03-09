# Blockchain Bridge (Just 2 Chains Swapping)🌉

Welcome to our open-source Blockchain Bridge repository! This project enables easy token transfers between two blockchains, like zkSync and Ethereum. It's designed for flexibility, supporting various tokens for seamless integration. 🚀

## Overview 📖

Our Blockchain Bridge is a versatile solution for token transfers across different blockchains. Ideal for any token, it operates through smart contracts on each chain, managing the locking and unlocking of tokens.

## Getting Started 🛠️

### Prerequisites

- A good grasp of blockchain technology and smart contract development.
- Access to blockchain networks (e.g., zkSync and Ethereum) for contract deployment.

### Step 1: Deploy Smart Contracts

1. **Deploy on Both Chains**: Start by deploying the smart contracts on both blockchains. These contracts will handle the token transfers, ensuring a 1:1 value swap between the chains.

2. **Note Contract Details**: After deployment, record the contract addresses and ABIs. They're crucial for the bridge's interaction with these contracts.

### Step 2: Configure the Bridge

1. **Update `abis.js`**: Insert the ABIs of the deployed contracts into the `abis.js` file. This is vital for the bridge to communicate with the smart contracts.

2. **Configure `.env` File**: Set up the `.env` file with the RPC URLs for both blockchains and the owner's private key. Refer to `.env.sample` for the format.

### Step 3: Run the Bridge

1. **Install Dependencies**: Execute `npm install` to get all necessary dependencies.

2. **Launch the Bridge**: Start the bridge with `node Bridge.js`. It will monitor events on both blockchains, facilitating token transfers as per the smart contracts' logic.

## Behind the Scenes

The bridge operates a backend JavaScript process (to be coded later). This process, known as a relayer, observes events on both blockchains. For example, if you transfer 1 $Orc to the smart contract on Ethereum, the relayer detects this event and triggers a corresponding transaction on the other chain, ensuring the $Orc tokens are transferred to the same address through the other chain's contract.

## Contributing 🤝

Want to make this bridge even better? We're open to contributions! Whether it's adding features, refining documentation, or squashing bugs, your input is valuable. Check out our contributing guidelines to start.

## Support 💬

Need help or have suggestions? Feel free to open an issue in this repository. We're committed to creating a robust, community-driven solution!

---

Let's connect blockchains and streamline the crypto ecosystem together! 🌐🔗💼
