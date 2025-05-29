const { ethers } = require("hardhat");

async function main() {
  const tokenAddress = "0xec3E1f1EdB0fe6673956f8a4e8039F95368b3991";
  const owner        = "0x2d7465Ab69B15162996005eeb0DF4c74fe8196C8";

  const token = await ethers.getContractAt("SquirrelyTailsToken", tokenAddress);

  // Mint 45 000 000 SQLY to your wallet
  const amount = ethers.utils.parseUnits("45000000", 18);
  const tx = await token.mint(owner, amount);
  await tx.wait();

  console.log("Minted 45 M SQLY to", owner);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
