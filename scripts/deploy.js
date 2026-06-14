const fs = require("fs");
const path = require("path");
const hre = require("hardhat");

async function main() {
  const { ethers } = hre;
  const [deployer] = await ethers.getSigners();

  console.log("Deploying with:", deployer.address);

  const JN19Credit = await ethers.getContractFactory("JN19Credit");
  const jn19 = await JN19Credit.deploy(deployer.address);
  await jn19.waitForDeployment();

  const MockUSDC = await ethers.getContractFactory("MockUSDC");
  const usdc = await MockUSDC.deploy(deployer.address);
  await usdc.waitForDeployment();

  const JN19Market = await ethers.getContractFactory("JN19Market");
  const market = await JN19Market.deploy(await jn19.getAddress(), await usdc.getAddress());
  await market.waitForDeployment();

  const addresses = {
    JN19: await jn19.getAddress(),
    mUSDC: await usdc.getAddress(),
    JN19Market: await market.getAddress()
  };

  console.log("JN19:", addresses.JN19);
  console.log("mUSDC:", addresses.mUSDC);
  console.log("JN19Market:", addresses.JN19Market);

  const outPath = path.join(__dirname, "..", "frontend", "addresses.json");
  fs.writeFileSync(outPath, JSON.stringify(addresses, null, 2));
  console.log("Wrote frontend/addresses.json");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
