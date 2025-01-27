import { Provider } from "zksync-ethers";
import * as ethers from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import * as ABI from "../artifacts-zk/contracts/UpcadeVault.sol/UpcadeVault.json";
import { HttpNetworkConfig } from "hardhat/types/config";

// load env file
import dotenv from "dotenv";
import { requiredEnv } from "../utils/env";
dotenv.config();

// ToDo : To verify which parts could be moved to some common parts

// load wallet private key from env file
const PRIVATE_KEY = process.env.WALLET_PRIVATE_KEY || "";
    
if (!PRIVATE_KEY)
  throw "⛔️ Private key not detected! Add it to the .env file!";

// An example of a deploy script that will deploy and call a simple contract.
export default async function (hre: HardhatRuntimeEnvironment) {
  console.log(`Running deploy script for the UpCadeVaultNative 'grantRole' function.`);

  const vaultContractAddress = requiredEnv("VAULT").toLowerCase();
  const manager = requiredEnv("MANAGER").toLowerCase();

  const networkConfig: HttpNetworkConfig = hre.config.networks?.abstractTestnet as HttpNetworkConfig;

  // Initialize the wallet
  const provider = new Provider(networkConfig.url);
  const signer = new ethers.Wallet(PRIVATE_KEY, provider);

  console.log(`UpcadeVault contract address : ${vaultContractAddress}}`);

  const contract = new ethers.Contract(vaultContractAddress, ABI.abi, signer);

  const managerRole = await contract.MANAGER_ROLE();
  const tx = await contract.grantRole(managerRole, manager);

  await tx.wait();

  console.log(`Vault contract : ${vaultContractAddress}`);
  console.log(`Transaction tx : ${tx.hash}`);
}
