const { ethers } = require("hardhat");

async function main() {
  const tokenAddress = "YOUR_DEPLOYED_SQLY_TOKEN_ADDRESS";
  const [deployer] = await ethers.getSigners();

  const Vesting = await ethers.getContractFactory("SQLYVestingVault");
  const vesting = await Vesting.deploy(tokenAddress);
  await vesting.deployed();

  console.log("Vesting contract deployed to:", vesting.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
