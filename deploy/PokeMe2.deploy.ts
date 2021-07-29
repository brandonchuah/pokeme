const { deployments, getNamedAccounts } = require("hardhat");

const sleep = async (ms, hideLog = false) => {
  return new Promise((resolve) => {
    if (!hideLog) console.log(`\n\tSleeping for ${ms / 1000} seconds\n`);
    setTimeout(resolve, ms);
  });
};

const gelatoAddress = {
  ropsten: "0xCc4CcD69D31F9FfDBD3BFfDe49c6aA886DaB98d9",
  mainnet: "0x3caca7b48d0573d793d3b0279b5f0029180e83b6",
};

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const func = async (hre) => {
  if (hre.network.name === "mainnet" || hre.network.name === "ropsten") {
    console.log(
      `Deploying PokeMe2 to ${hre.network.name} with gelato address ${
        gelatoAddress[hre.network.name]
      }. Hit ctrl + c to abort`
    );
    await sleep(10000);
  }

  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("PokeMe2", {
    from: deployer,
    args: [gelatoAddress[hre.network.name]],
    log: hre.network.name !== "hardhat" ? true : false,
  });
};

module.exports = func;

func.skip = async (hre) => {
  const shouldSkip =
    hre.network.name === "mainnet" || hre.network.name === "ropsten";
  console.log("Skipping deployment...");
  return shouldSkip;
};

func.tags = ["PokeMe2"];
