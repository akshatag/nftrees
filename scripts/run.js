const { web3 } = require("hardhat");

const getGasCost = async (txn) => {
  let block = await hre.ethers.provider.getBlock(txn.blockNumber);
  return block.gasUsed.toNumber();
}

const main = async () => {
  
  // Deploy the Garden NFT Contract
  const nftContractFactory = await hre.ethers.getContractFactory('Plant');
  const nftContract = await nftContractFactory.deploy();
  await nftContract.deployed();
  
  console.log("Contract deployed to: ", nftContract.address)

  let rTxn;
  let wTxn;
  let gas;

  /* 1: Mint the Plant NFT */
  wTxn = await nftContract.mintPlant();
  await wTxn.wait();
  gas = await getGasCost(wTxn);

  console.log("Plant minted. You received a seed! Gas Cost: " + gas);

  rTxn = await nftContract.tokenURI(0);
  console.log(rTxn);
  
  /* 2: Sow the seed */
  wTxn = await nftContract.sow(0);
  await wTxn.wait();
  gas = await getGasCost(wTxn);

  console.log("Seed sowed. You received a sapling! Gas Cost: " + gas);

  rTxn = await nftContract.tokenURI(0);
  console.log(rTxn);

  /* 3: Water the sapling */
  wTxn = await nftContract.water(0);
  await wTxn.wait();
  gas = await getGasCost(wTxn);

  console.log("Sapling watered. It has grown into an apple tree! Gas Cost: " + gas);

  rTxn = await nftContract.tokenURI(0);
  console.log(rTxn);  

  /* Wait a few seconds */
  await new Promise(resolve => setTimeout(resolve, 5000));

  /* 4: Water the tree */
  wTxn = await nftContract.water(0);
  await wTxn.wait();
  gas = await getGasCost(wTxn);

  console.log("Tree watered. It has some fruit! Gas Cost: " + gas);

  rTxn = await nftContract.tokenURI(0);
  console.log(rTxn); 
  

  /* 5: Harvest an apple */
  wTxn = await nftContract.harvest(0);
  await wTxn.wait();
  gas = await getGasCost(wTxn);

  console.log("Tree harvested. You got an apple! Gas Cost: " + gas);

  rTxn = await nftContract.tokenURI(0);
  console.log(rTxn); 
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