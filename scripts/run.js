const { web3, ethers } = require("hardhat");

const getGasCost = async (txn) => {
  let block = await hre.ethers.provider.getBlock(txn.blockNumber);
  return block.gasUsed.toNumber();
}

const main = async () => {
  
  // Deploy the Garden NFT Contract
  const nftContractFactory = await hre.ethers.getContractFactory('PlantContract');
  const nftContract = await nftContractFactory.deploy();
  await nftContract.deployed();

  const [owner] = await ethers.getSigners();
  
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

  /* 2: Water the seed */
  wTxn = await nftContract.water(0);
  await wTxn.wait();
  gas = await getGasCost(wTxn);

  console.log("Seed watered. It has grown into a sapling! Gas Cost: " + gas);

  rTxn = await nftContract.tokenURI(0);
  console.log(rTxn);  

  /* 3: Water the sapling */
  wTxn = await nftContract.water(0);
  await wTxn.wait();
  gas = await getGasCost(wTxn);

  console.log("Sapling watered. It has grown into a tree! Gas Cost: " + gas);

  rTxn = await nftContract.tokenURI(0);
  console.log(rTxn);  


  /* 4: Water the tree */
  wTxn = await nftContract.water(0);
  await wTxn.wait();
  gas = await getGasCost(wTxn);

  console.log("Tree watered. It has some fruit! Gas Cost: " + gas);

  rTxn = await nftContract.tokenURI(0);
  console.log(rTxn); 


  /* 5: Harvest the tree */
  wTxn = await nftContract.harvest(0);
  await wTxn.wait();
  gas = await getGasCost(wTxn);

  console.log("You got fruit!" + gas);

  rTxn = await nftContract.tokenURI(0);
  console.log(rTxn); 

  console.log("You got compost!")

  rTxn = await nftContract.getCMPSTBalanceOf(owner.address);
  console.log(rTxn.toNumber());
  
  
  /* Wait a few seconds */
  await new Promise(resolve => setTimeout(resolve, 10000));

    /* 4: Water the tree */
    wTxn = await nftContract.water(0);
    await wTxn.wait();
    gas = await getGasCost(wTxn);
  
    console.log("It died :( " + gas);
  
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