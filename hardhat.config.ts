import * as dotenv from "dotenv";


import { HardhatUserConfig } from "hardhat/config";
import "@matterlabs/hardhat-zksync";
import "@nomicfoundation/hardhat-toolbox";
import '@typechain/hardhat';

dotenv.config();

const privateKey = process.env.PRIVATE_KEY!;

const config: HardhatUserConfig = {
  zksolc: {
    version: "1.5.7",
    settings: {
      // Note: This must be true to call NonceHolder & ContractDeployer system contracts
      enableEraVMExtensions: true,
    },
  },
  defaultNetwork: "abstractTestnet",
  networks: {
    abstractTestnet: {
      url: "https://api.testnet.abs.xyz",
      ethNetwork: "sepolia",
      zksync: true,
      verifyURL:
        "https://api-explorer-verify.testnet.abs.xyz/contract_verification",
      accounts: [privateKey]
    },
    abstractMainnet: {
        url: "https://api.mainnet.abs.xyz",
        ethNetwork: "mainnet",
        zksync: true,
        verifyURL: "https://api.abscan.org/api",
        accounts: [privateKey]
    }
  },
  solidity: {
    version: "0.8.28",
  },
  paths: {
    cache: "./cache-zk",
    artifacts: "./artifacts-zk"
  },
  etherscan: {
    apiKey: {
        abstractTestnet: "TACK2D1RGYX9U7MC31SZWWQ7FCWRYQ96AD",
        abstractMainnet: "IEYKU3EEM5XCD76N7Y7HF9HG7M9ARZ2H4A",
      },
      customChains: [
        {
          network: "abstractTestnet",
          chainId: 11124,
          urls: {
            apiURL: "https://api-sepolia.abscan.org/api",
            browserURL: "https://sepolia.abscan.org/",
          },
        },
        {
          network: "abstractMainnet",
          chainId: 2741,
          urls: {
            apiURL: "https://api.abscan.org/api",
            browserURL: "https://abscan.org/",
          },
        },
      ],
  }
};

export default config;
