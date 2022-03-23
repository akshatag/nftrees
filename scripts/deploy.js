const main = async () => {
  
  // Deploy the Garden NFT Contract
  const nftContractFactory = await hre.ethers.getContractFactory('Plant');
  const nftContract = await nftContractFactory.deploy();
  await nftContract.deployed();
  console.log("Contract deployed to: ", nftContract.address)

  // Call the contract to mint an NFT
  let txn = await nftContract.mintPlantNFT();
  await txn.wait();
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