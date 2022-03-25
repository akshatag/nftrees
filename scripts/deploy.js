const main = async () => {
  
  // Deploy the Garden NFT Contract
  const nftContractFactory = await hre.ethers.getContractFactory('PlantContract');
  const nftContract = await nftContractFactory.deploy();
  await nftContract.deployed();
  console.log("Contract deployed to: ", nftContract.address)
}

const runMain = async() => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();