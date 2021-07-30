const { sleep } = require("@gelatonetwork/core");

module.exports = async (hre) => {
  if (
    hre.network.name === "mainnet" ||
    hre.network.name === "rinkeby" ||
    hre.network.name === "ropsten"
  ) {
    console.log(
      `Deploying Counter to ${hre.network.name}. Hit ctrl + c to abort`
    );
    await sleep(10000);
  }

  const { deployments } = hre;
  const { deploy } = deployments;
  const { deployer } = await hre.getNamedAccounts();

  await deploy("Counter", {
    from: deployer,
    args: [],
  });
};

module.exports.skip = async (hre) => {
  const skip =
    hre.network.name === "mainnet" ||
    hre.network.name === "rinkeby" ||
    hre.network.name === "hardhat"; // skip local deployment here for tests to run
  return skip ? true : false;
};

module.exports.tags = ["Counter"];
