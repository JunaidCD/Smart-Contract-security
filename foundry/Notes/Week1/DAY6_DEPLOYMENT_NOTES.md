# Day 6 - Deploy and Verify FinBridge on Sepolia

## Objective

Deploy the FinBridgeLending contract to Sepolia using Foundry and verify the source code on Etherscan.

## Steps I Followed

1. Created a deployment script using Script.sol.
2. Used vm.startBroadcast() and vm.stopBroadcast() to send real transactions.
3. Configured the Sepolia RPC URL in the .env file.
4. Added a wallet private key funded with Sepolia ETH.
5. Built the project using forge build.
6. Ran the deployment script using forge script with --broadcast.
7. Received the deployed contract address.
8. Submitted source code verification using forge verify-contract.
9. Received a verification GUID from Etherscan.
10. Checked verification status using forge verify-check.

## Commands Used

forge build

forge script script/DeployFinBridge.s.sol:DeployFinBridge --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast

forge verify-contract <CONTRACT_ADDRESS> src/FinBridgeLending.sol:FinBridgeLending --chain sepolia --etherscan-api-key <API_KEY>

forge verify-check <GUID> --chain sepolia --etherscan-api-key <API_KEY>

## Things I Learned

* Script.sol is used for deployment scripts.
* vm.startBroadcast() starts sending real blockchain transactions.
* vm.stopBroadcast() stops sending transactions.
* A deployment script is different from a test contract.
* Verification publishes source code so anyone can inspect the deployed contract.
* Testnets allow deployment without spending real ETH.

## Problems I Faced

* .env was being tracked by Git.
* I had issues loading environment variables.
* I initially used incorrect PowerShell syntax.
* Verification required the GUID returned by Etherscan.

## Final Result

FinBridgeLending was successfully deployed to Sepolia and submitted for verification.
