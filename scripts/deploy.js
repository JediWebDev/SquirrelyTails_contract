const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with:", deployer.address);

  // Change this to the V2 contract name
const Token = await ethers.getContractFactory("SquirrelyTailsTokenV2");
const token = await Token.deploy();

  console.log("Token deployed at:", token.address);
}

main()
  .then(() => process.exit(0))
  .catch(err => {
    console.error(err);
    process.exit(1);
  });
