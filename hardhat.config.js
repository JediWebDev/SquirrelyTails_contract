/** @type import('hardhat/config').HardhatUserConfig */

require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("@nomicfoundation/hardhat-ethers");
require("@nomicfoundation/hardhat-chai-matchers");

const networks = {
  hardhat: {
    // You can keep or remove forking if you don’t need a local fork
    forking: process.env.POLYGON_RPC_URL
      ? { url: process.env.POLYGON_RPC_URL }
      : undefined,
  },
};

if (process.env.POLYGON_RPC_URL && process.env.PRIVATE_KEY) {
  networks.polygon = {
    url: process.env.POLYGON_RPC_URL,
    accounts: [process.env.PRIVATE_KEY],
    chainId: 137,
  };
}

module.exports = {
  solidity: "0.8.28",
  networks,
  etherscan: {
    // Make sure you set POLYGONSCAN_API_KEY in your .env (not ETHERSCAN_API_KEY)
    apiKey: {
      polygon: process.env.POLYGONSCAN_API_KEY
    }
  },
};

