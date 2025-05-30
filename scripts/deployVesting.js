const { ethers } = require("hardhat");
const { JsonRpcProvider } = require("@ethersproject/providers");
require("dotenv").config();

async function main() {
  const tokenAddress = "0xec3E1f1EdB0fe6673956f8a4e8039F95368b3991";

  const provider = new JsonRpcProvider(process.env.POLYGON_RPC_URL);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

  console.log("Deploying contract with account:", wallet.address);

  const Vesting = await ethers.getContractFactory("SQLYVestingVault", wallet);
  const vesting = await Vesting.deploy(tokenAddress);
  console.log("Deployment tx hash:", vesting.deployTransaction.hash);

  await vesting.deployed();

  console.log("SQLYVestingVault deployed to:", vesting.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});