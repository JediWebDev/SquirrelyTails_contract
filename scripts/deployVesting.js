const { ethers } = require("hardhat");

async function main() {
  const tokenAddress = "YOUR_DEPLOYED_SQLY_TOKEN_ADDRESS"; // Replace with actual deployed token address

  // Safe signer fetch (does NOT use ENS)
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contract with account:", deployer.address);

  const Vesting = await ethers.getContractFactory("SQLYVestingVault");
  const vesting = await Vesting.deploy(tokenAddress);

  await vesting.deployed();

  console.log("SQLYVestingVault deployed to:", vesting.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});