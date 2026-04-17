import "@xyrusworx/hardhat-solidity-json";
import "@nomicfoundation/hardhat-toolbox";
import { HardhatUserConfig } from "hardhat/config";
import "solidity-coverage";
import "@nomiclabs/hardhat-solhint";
import "@primitivefi/hardhat-dodoc";
import "hardhat-gas-reporter";

const accounts = process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [];

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    hardhat: {},
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL ?? "",
      accounts,
      chainId: 11155111,
    },
    polygon: {
      url: process.env.POLYGON_RPC_URL ?? "",
      accounts,
      chainId: 137,
    },
    mainnet: {
      url: process.env.MAINNET_RPC_URL ?? "",
      accounts,
      chainId: 1,
    },
  },
  etherscan: {
    apiKey: {
      mainnet: process.env.ETHERSCAN_API_KEY ?? "",
      sepolia: process.env.ETHERSCAN_API_KEY ?? "",
      polygon: process.env.POLYGONSCAN_API_KEY ?? "",
    },
  },
  dodoc: {
    runOnCompile: false,
    debugMode: false,
    outputDir: "./docgen",
    freshOutput: true,
    exclude: ["_testContracts"],
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
    excludeContracts: ["_testContracts/"],
    outputFile: process.env.CI ? "gas-report.txt" : undefined,
    noColors: !!process.env.CI,
    coinmarketcap: process.env.COINMARKETCAP_API_KEY,
  },
  mocha: {
    timeout: 60_000,
  },
};

export default config;
