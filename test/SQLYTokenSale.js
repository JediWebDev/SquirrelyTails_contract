const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SQLYTokenSale", function () {
  let sqly, usdc, sale, owner, buyer, wallet;

  beforeEach(async function () {
    [owner, buyer, wallet] = await ethers.getSigners();

    const SQLY = await ethers.getContractFactory("SquirrelyTailsTokenV2");
    sqly = await SQLY.deploy();
    await sqly.waitForDeployment();

    const USDC = await ethers.getContractFactory("USDCMock");
    usdc = await USDC.deploy();
    await usdc.waitForDeployment();

    const Sale = await ethers.getContractFactory("SQLYTokenSale");
    // 1 USDC -> 1 SQLY
    const tokensPerUsdc = 1n * 10n ** BigInt(await sqly.decimals());
    sale = await Sale.deploy(sqly, usdc, wallet.address, tokensPerUsdc);
    await sale.waitForDeployment();

    // fund sale with tokens
    await sqly.transfer(sale.target, 1000n * 10n ** BigInt(await sqly.decimals()));

    // give buyer USDC
    await usdc.transfer(buyer.address, 1000n * 10n ** 6n);
  });

  it("allows user to buy SQLY with USDC", async function () {
    const amount = 100n * 10n ** 6n; // 100 USDC
    await usdc.connect(buyer).approve(sale.target, amount);
    await sale.connect(buyer).buy(amount);

    expect(await sqly.balanceOf(buyer.address)).to.equal(
      100n * 10n ** BigInt(await sqly.decimals())
    );
    expect(await usdc.balanceOf(wallet.address)).to.equal(amount);
  });
});
