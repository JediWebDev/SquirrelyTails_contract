const { ethers } = require("hardhat");
const { JsonRpcProvider } = require("@ethersproject/providers");
require("dotenv").config();

async function main() {
  const tokenAddress = "0x82500beC6470dd6CB6743c222E32e497a12402c3";

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