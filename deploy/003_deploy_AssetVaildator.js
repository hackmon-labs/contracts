module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("AssetVaildator", {
    from: deployer,
    log: true,
    args: [
      60
    ],
  });
};

module.exports.tags = ["AssetVaildator."];
