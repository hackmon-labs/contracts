import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";
require("dotenv").config();

const accounts = [process.env.PRIVATEKEY!];

const config: HardhatUserConfig = {
  solidity: "0.8.17",

  networks: {
    mumbai: {
      url: process.env.MUMBAI_URL,
      accounts: accounts,
    },
  },

  namedAccounts: {
    deployer: 0,
  },
};

export default config;
