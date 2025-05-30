const { ethers } = require("hardhat");

async function main() {
  const [signer] = await ethers.getSigners();
  const tx = await signer.sendTransaction({
    to: signer.address,
    value: ethers.utils.parseEther("0.001"), // send to yourself
  });

  console.log("Test TX hash:", tx.hash);
  await tx.wait();
  console.log("Test TX confirmed");
}

main().catch(console.error);