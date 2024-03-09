// Load environment variables for secure configuration management.
require('dotenv').config();

const Web3 = require('web3');

// Updated ABIs to match the new contract structures
const { EthereumBridgeEntryABI, ZkSyncBridgeABI } = require('./abis');

const zkSyncRpcUrl = process.env.ZKSYNC_RPC_URL;
const ethereumRpcUrl = process.env.ETHEREUM_RPC_URL;
const zkSyncBridgeAddress = process.env.ZKSYNC_BRIDGE_CONTRACT_ADDRESS;
const ethereumBridgeAddress = process.env.ETHEREUM_BRIDGE_CONTRACT_ADDRESS;

const zkSyncWeb3 = new Web3(zkSyncRpcUrl);
const ethereumWeb3 = new Web3(ethereumRpcUrl);

zkSyncWeb3.eth.accounts.wallet.add(process.env.OWNER_PRIVATE_KEY);
ethereumWeb3.eth.accounts.wallet.add(process.env.OWNER_PRIVATE_KEY);

const zkSyncBridgeContract = new zkSyncWeb3.eth.Contract(ZkSyncBridgeABI, zkSyncBridgeAddress);
const ethereumBridgeContract = new ethereumWeb3.eth.Contract(EthereumBridgeEntryABI, ethereumBridgeAddress);

function handleError(error) {
    console.error(error);
}

// Define a common function for sending transactions.
// This function encapsulates the steps required to estimate gas, sign, and send transactions, thereby reducing code redundancy.
async function sendTransaction(web3Instance, txObject, privateKey) {
    try {
        const gas = await web3Instance.eth.estimateGas(txObject);
        const gasPrice = await web3Instance.eth.getGasPrice();
        const tx = {
            ...txObject,
            gas,
            gasPrice
        };
        const signedTx = await web3Instance.eth.accounts.signTransaction(tx, privateKey);
        await web3Instance.eth.sendSignedTransaction(signedTx.rawTransaction);
    } catch (error) {
        handleError(error);
    }
}

// Update function names and logic to match the new contract methods
async function handleUnlockOnEthereum(recipient, amount) {
    const unlockData = ethereumBridgeContract.methods.unlockTokens(recipient, amount).encodeABI();
    const txObject = { to: ethereumBridgeAddress, data: unlockData };
    await sendTransaction(ethereumWeb3, txObject, process.env.OWNER_PRIVATE_KEY);
}

async function handleUnlockOnZkSync(recipient, amount) {
    const unlockData = zkSyncBridgeContract.methods.unlockTokens(recipient, amount).encodeABI();
    const txObject = { to: zkSyncBridgeAddress, data: unlockData };
    await sendTransaction(zkSyncWeb3, txObject, process.env.OWNER_PRIVATE_KEY);
}

// Define a function for polling new events.
// This function is essential for the Relayer to detect when tokens are locked on one chain and need to be unlocked on the other.
async function pollForNewEvents() {
    try {
        // Implement the logic to check for new events, such as locked tokens, since the last block.
    } catch (error) {
        handleError(error);
    }
}

// Define the main loop of the application.
// This loop is the heart of the Relayer, constantly monitoring for events and handling them appropriately.
async function main() {
    try {
        while (true) {
            await pollForNewEvents();
            await new Promise(resolve => setTimeout(resolve, 5000)); // 5-second delay
        }
    } catch (error) {
        handleError(error);
        main(); // Restart main loop after an error
    }
}

// Start the application.
// This is the entry point of the script, kicking off the Relayer's operations.
main();
