const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SquirrelyTailsToken", function () {
  let Token, token, owner, addr1, addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    Token = await ethers.getContractFactory("SquirrelyTailsToken");
    token = await Token.deploy();
    await token.waitForDeployment();
  });

  it("owner can mint tokens", async function () {
    const amount = ethers.parseEther("1000");
    await token.mint(addr1.address, amount);
    expect(await token.balanceOf(addr1.address)).to.equal(amount);
  });

  it("pause/unpause prevents transfers", async function () {
    const amount = ethers.parseEther("1");
    await token.pause();
    await expect(token.transfer(addr1.address, amount)).to.be.revertedWith("Pausable: paused");
    await token.unpause();
    await expect(token.transfer(addr1.address, amount)).to.not.be.reverted;
  });
});
