const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("JN19Market", function () {
  async function deployFixture() {
    const [seller, buyer] = await ethers.getSigners();

    const JN19Credit = await ethers.getContractFactory("JN19Credit");
    const jn19 = await JN19Credit.deploy(seller.address);
    await jn19.waitForDeployment();

    const MockUSDC = await ethers.getContractFactory("MockUSDC");
    const usdc = await MockUSDC.deploy(seller.address);
    await usdc.waitForDeployment();

    const JN19Market = await ethers.getContractFactory("JN19Market");
    const market = await JN19Market.deploy(await jn19.getAddress(), await usdc.getAddress());
    await market.waitForDeployment();

    await jn19.connect(buyer).claim();
    await usdc.connect(buyer).claim();

    return { seller, buyer, jn19, usdc, market };
  }

  it("lets a buyer purchase a JN19 listing with mock USDC", async function () {
    const { seller, buyer, jn19, usdc, market } = await deployFixture();

    const creditAmount = ethers.parseUnits("100", 18);
    const paymentAmount = ethers.parseUnits("20", 18);

    await jn19.connect(seller).approve(await market.getAddress(), creditAmount);
    await market.connect(seller).createListing(creditAmount, paymentAmount);

    await usdc.connect(buyer).approve(await market.getAddress(), paymentAmount);

    await expect(market.connect(buyer).buyListing(0))
      .to.emit(market, "ListingBought")
      .withArgs(0, buyer.address);

    expect(await jn19.balanceOf(buyer.address)).to.equal(ethers.parseUnits("1100", 18));
    expect(await usdc.balanceOf(seller.address)).to.equal(ethers.parseUnits("1000020", 18));

    const listing = await market.getListing(0);
    expect(listing.status).to.equal(2); // Sold
  });

  it("lets the seller cancel and receive escrowed JN19 back", async function () {
    const { seller, jn19, market } = await deployFixture();

    const creditAmount = ethers.parseUnits("50", 18);
    const paymentAmount = ethers.parseUnits("10", 18);
    const before = await jn19.balanceOf(seller.address);

    await jn19.connect(seller).approve(await market.getAddress(), creditAmount);
    await market.connect(seller).createListing(creditAmount, paymentAmount);
    await market.connect(seller).cancelListing(0);

    expect(await jn19.balanceOf(seller.address)).to.equal(before);
    const listing = await market.getListing(0);
    expect(listing.status).to.equal(3); // Cancelled
  });

  it("burns JN19 credits for fake AI usage", async function () {
    const { buyer, jn19 } = await deployFixture();

    const burnAmount = ethers.parseUnits("5", 18);
    await jn19.connect(buyer).burnForAiUsage(burnAmount);
    expect(await jn19.balanceOf(buyer.address)).to.equal(ethers.parseUnits("995", 18));
  });
});
