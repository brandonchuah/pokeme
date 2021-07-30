const { sleep } = require("@gelatonetwork/core");

module.exports = async (hre) => {
  if (
    hre.network.name === "mainnet" ||
    hre.network.name === "rinkeby" ||
    hre.network.name === "ropsten"
  ) {
    console.log(
      `Deploying PokeMe to ${hre.network.name}. Hit ctrl + c to abort`
    );
    await sleep(10000);
  }

  const { deployments } = hre;
  const { deploy } = deployments;
  const { deployer } = await hre.getNamedAccounts();

  await deploy("PokeMe", {
    from: deployer,
    args: [
      hre.network.config.GELATO,
      (await hre.ethers.getContract("TaskTreasury")).address,
    ],
  });
};

module.exports.skip = async (hre) => {
  const skip =
    hre.network.name === "mainnet" ||
    hre.network.name === "rinkeby" ||
    hre.network.name === "hardhat"; // skip local deployment here for tests to run
  return skip ? true : false;
};

module.exports.tags = ["PokeMe"];
module.exports.dependencies = ["TaskTreasury"];
