module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("VrfMint", {
    from: deployer,
    log: true,
    args: [
      '0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed',
      2526,
      [
        "https://bafybeiawwybjv2x5xj2bshewhwfgnq4zvyzokyzapok4io2hr33yv5tzty.ipfs.nftstorage.link/0.json",
        "https://bafybeiawwybjv2x5xj2bshewhwfgnq4zvyzokyzapok4io2hr33yv5tzty.ipfs.nftstorage.link/1.json",
        "https://bafybeiawwybjv2x5xj2bshewhwfgnq4zvyzokyzapok4io2hr33yv5tzty.ipfs.nftstorage.link/2.json",
        "https://bafybeiawwybjv2x5xj2bshewhwfgnq4zvyzokyzapok4io2hr33yv5tzty.ipfs.nftstorage.link/3.json",
        "https://bafybeiawwybjv2x5xj2bshewhwfgnq4zvyzokyzapok4io2hr33yv5tzty.ipfs.nftstorage.link/4.json",
        "https://bafybeiawwybjv2x5xj2bshewhwfgnq4zvyzokyzapok4io2hr33yv5tzty.ipfs.nftstorage.link/5.json",
        "https://bafybeiawwybjv2x5xj2bshewhwfgnq4zvyzokyzapok4io2hr33yv5tzty.ipfs.nftstorage.link/6.json",
        "https://bafybeiawwybjv2x5xj2bshewhwfgnq4zvyzokyzapok4io2hr33yv5tzty.ipfs.nftstorage.link/7.json",
        "https://bafybeiawwybjv2x5xj2bshewhwfgnq4zvyzokyzapok4io2hr33yv5tzty.ipfs.nftstorage.link/8.json",
        "https://bafybeiawwybjv2x5xj2bshewhwfgnq4zvyzokyzapok4io2hr33yv5tzty.ipfs.nftstorage.link/9.json",
        "https://bafybeiawwybjv2x5xj2bshewhwfgnq4zvyzokyzapok4io2hr33yv5tzty.ipfs.nftstorage.link/10.json",
        "https://bafybeiawwybjv2x5xj2bshewhwfgnq4zvyzokyzapok4io2hr33yv5tzty.ipfs.nftstorage.link/11.json",
        "https://bafybeiawwybjv2x5xj2bshewhwfgnq4zvyzokyzapok4io2hr33yv5tzty.ipfs.nftstorage.link/12.json",
        "https://bafybeiawwybjv2x5xj2bshewhwfgnq4zvyzokyzapok4io2hr33yv5tzty.ipfs.nftstorage.link/13.json",
        "https://bafybeiawwybjv2x5xj2bshewhwfgnq4zvyzokyzapok4io2hr33yv5tzty.ipfs.nftstorage.link/14.json",
        "https://bafybeiawwybjv2x5xj2bshewhwfgnq4zvyzokyzapok4io2hr33yv5tzty.ipfs.nftstorage.link/15.json",
        "https://bafybeiawwybjv2x5xj2bshewhwfgnq4zvyzokyzapok4io2hr33yv5tzty.ipfs.nftstorage.link/16.json",
        "https://bafybeiawwybjv2x5xj2bshewhwfgnq4zvyzokyzapok4io2hr33yv5tzty.ipfs.nftstorage.link/17.json",
        "https://bafybeiawwybjv2x5xj2bshewhwfgnq4zvyzokyzapok4io2hr33yv5tzty.ipfs.nftstorage.link/18.json",
        "https://bafybeiawwybjv2x5xj2bshewhwfgnq4zvyzokyzapok4io2hr33yv5tzty.ipfs.nftstorage.link/19.json"
      ]
    ],
  });
};

module.exports.tags = ["VrfMint"];
