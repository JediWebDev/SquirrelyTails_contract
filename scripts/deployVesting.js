const { ethers } = require("hardhat");
const { JsonRpcProvider } = require("@ethersproject/providers");
require("dotenv").config();

async function main() {
  const tokenAddress = "0x2d7465Ab69B15162996005eeb0DF4c74fe8196C8";

  const provider = new JsonRpcProvider(process.env.POLYGON_RPC_URL);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

  console.log("Deploying contract with account:", wallet.address);

  const Vesting = await ethers.getContractFactory("SQLYVestingVault", wallet);
  const vesting = await Vesting.deploy(tokenAddress);

  await vesting.deployed();

  console.log("SQLYVestingVault deployed to:", vesting.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});