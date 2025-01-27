import { Wallet } from "zksync-ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";
import { UpcadeVault } from "../typechain-types";

// load env file
import dotenv from "dotenv";
dotenv.config();

// ToDo : To verify which parts could be moved to some common parts

// load wallet private key from env file
const PRIVATE_KEY = process.env.PRIVATE_KEY || "";
const FEE_RECIPIENT = process.env.FEE_RECIPIENT;

if (!PRIVATE_KEY)
  throw "⛔️ Private key not detected! Add it to the .env file!";

// An example of a deploy script that will deploy and call a simple contract.
export default async function (hre: HardhatRuntimeEnvironment) {
  console.log(`Running deploy script for the UpcadeVault contract`);

  // Initialize the wallet.
  const wallet = new Wallet(PRIVATE_KEY);

  // Create deployer object and load the artifact of the contract you want to deploy.
  const deployer = new Deployer(hre, wallet);
  const artifact = await deployer.loadArtifact("UpcadeVault");

  // Deploy UpcadeGameData contract
  console.log("Deploying UpcadeVault implementation contract...");
  const upcadeVault = await deployer.deploy(artifact);
  const upcadeVaultAddress = await upcadeVault.getAddress();
  console.log(`UpcadeGameData implementation deployed to : ${upcadeVaultAddress}`);

  // Load ERC1967Proxy artifact
  const proxyArtifact = await deployer.loadArtifact("@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol:ERC1967Proxy");

// Encode the initializer function call (e.g., "initialize()")
const initializeData = upcadeVault.interface.encodeFunctionData(
    "initialize",
    [FEE_RECIPIENT]
);

  const proxy = await deployer.deploy(proxyArtifact, [upcadeVaultAddress, initializeData]);
  const proxyAddress = await proxy.getAddress();
  console.log(`UpcadeGameData Proxy deployed to: ${proxyAddress}`);
}
