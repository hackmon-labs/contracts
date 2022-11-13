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
        "https://ipfs.filebase.io/ipfs/QmeZ3Xndo1DTruEGCbenzR381FyaLL8JgwGRKc1nfE3riU/1.json",
        "https://ipfs.filebase.io/ipfs/QmeZ3Xndo1DTruEGCbenzR381FyaLL8JgwGRKc1nfE3riU/2.json",
        "https://ipfs.filebase.io/ipfs/QmeZ3Xndo1DTruEGCbenzR381FyaLL8JgwGRKc1nfE3riU/3.json",
        "https://ipfs.filebase.io/ipfs/QmeZ3Xndo1DTruEGCbenzR381FyaLL8JgwGRKc1nfE3riU/4.json",
        "https://ipfs.filebase.io/ipfs/QmeZ3Xndo1DTruEGCbenzR381FyaLL8JgwGRKc1nfE3riU/5.json",
        "https://ipfs.filebase.io/ipfs/QmeZ3Xndo1DTruEGCbenzR381FyaLL8JgwGRKc1nfE3riU/6.json",
        "https://ipfs.filebase.io/ipfs/QmeZ3Xndo1DTruEGCbenzR381FyaLL8JgwGRKc1nfE3riU/7.json",
        "https://ipfs.filebase.io/ipfs/QmeZ3Xndo1DTruEGCbenzR381FyaLL8JgwGRKc1nfE3riU/8.json",
        "https://ipfs.filebase.io/ipfs/QmeZ3Xndo1DTruEGCbenzR381FyaLL8JgwGRKc1nfE3riU/9.json",
        "https://ipfs.filebase.io/ipfs/QmeZ3Xndo1DTruEGCbenzR381FyaLL8JgwGRKc1nfE3riU/10.json"
      ]
    ],
  });
};

module.exports.tags = ["vrfMint"];
