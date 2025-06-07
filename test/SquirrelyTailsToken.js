const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SquirrelyTailsTokenV2", function () {
  let token, owner, addr1;

  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("SquirrelyTailsTokenV2");
    token = await Token.deploy();
    await token.waitForDeployment();
  });

  it("mints total supply to deployer", async function () {
    const total = 100_000_000n * 10n ** BigInt(await token.decimals());
    expect(await token.totalSupply()).to.equal(total);
    expect(await token.balanceOf(owner.address)).to.equal(total);
  });

  it("allows transfers", async function () {
    const amount = 1n * 10n ** BigInt(await token.decimals());
    await token.transfer(addr1.address, amount);
    expect(await token.balanceOf(addr1.address)).to.equal(amount);
  });
});
