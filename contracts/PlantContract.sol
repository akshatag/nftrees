// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import { Base64 } from "./libraries/Base64.sol";
import { Utils } from "./libraries/Utils.sol";

contract CompostToken is ERC20 {
    constructor(uint256 initialSupply) ERC20 ("Compost", "CMPST") {
        _mint(msg.sender, initialSupply);
    }
}

contract PlantContract is ERC721URIStorage {

  /* Constants */ 
  string constant seedSVG = "<svg width='32px' height='32px' version='1.1' viewBox='0 0 32 32' xmlns='http://www.w3.org/2000/svg'> <image width='32px' height='32px' href='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAgCAYAAAAFQMh/AAAAAXNSR0IArs4c6QAAAQlJREFUWEftlT0SwiAQhZcqZ4m1nUWu45G8jr21HsITpMIhAiKw7BI2MuMkVX6AL+/x2FXQ6VKduLCDf+b8f1qtr4PGLNxEcQnofkQczIJOsxIBk7DHDDAO3nXVCkaBBhRfUuAvaA4kDa4Guh9oUeyhHIUGaGCZ/TWfWOFK9pIDdgot2AQqdJ8Er4KGau19FVgEWgteHaJMjVTndEuzVleHiOhpLLA0dEkwR/EC5qSW6tzjAHGg0FSLQO0xKkGTc6wvgPZPSmDcBKjxPlwsaFD24oUphcl490I/Txrut/fj4fgZ594VJNRC0ZJJ9leT1KgEUtaiimsnto4na3UrAJu/g7dyNlm3m9UvlHZwrafC/N8AAAAASUVORK5CYII='></image></svg>";
  string constant saplingSVG = "<svg width='32px' height='32px' version='1.1' viewBox='0 0 32 32' xmlns='http://www.w3.org/2000/svg'> <image width='32px' height='32px' href='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAJNJREFUWEdjZBhgwDjA9jOMOmA0BEZDYDQERkNgNARGQ2BohYDP+oD/oPbDlsANKA6HiWOTI9TeICkEkC2CWYZNjJClyPIUOQCbReihQ8gxJDkAZBi6j2EWkGoxTB/JDkD2Ecgx5Fo86gB4CFSGeoCzFjngchQHg+6yH+RohethHNIOoMjrUM0UhcCoA0ZDgBohAADQNjrJ+kyatgAAAABJRU5ErkJggg=='></image></svg>";
  string constant treeSVG_0 = "<svg width='32px' height='32px' version='1.1' viewBox='0 0 32 32' xmlns='http://www.w3.org/2000/svg'><image width='32px' height='32px' href='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAV1JREFUWEftl7sNAjEMhrkGMQBrMAMtQhRQ0LAJE1CwBw0FFBS0iBFYgwEQzSFH8skJTmwnx0lIR0Fx+PHlt88O1YD5LE7Lmnve5rPL6lxBPPeVk3A6fns8t+fQzAcQ1f4+rznnMIEmuhWiVQBrcjxQVAEwyFEB/CiMFMMBUCfJIVWKUAVNLA8AHSAQdcbAXONxdhb1GoBcFSic1AecIh5AWD9N53NBLW9VMYAECYCxErpBlDOEpKT0d6kRiwBypmHoowaQThKqkpKd2ooAUmJp6KTeDIj91YSW+mptYxCdAaTK04kCKaWa+0Cs1uFY1squtXMAuJC0TqV22BPuPpC6EdHlZFkwmo3pXck4h9iEzCkVnBgThrmcAhYArfyhep0CaJO7ZfQLBegGjJ0c80YB0KBkW0rJkwpIfTE5vJzJYzNqTOHZ7ngVD+UtI21Tgd12PRP/MfUAvQJ/p8AHu3vdrcNeKZ4AAAAASUVORK5CYII='></image><image id='apple' x='-3' y='-3' width='3px' height='3px' href='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAMAAAADCAYAAABWKLW/AAAAAXNSR0IArs4c6QAAACBJREFUGFdjZGBgYPBZH/B/S+AGRsaXcsn/QQIggMIBAM0ICNbrt1VcAAAAAElFTkSuQmCC'></image>";
  string constant treeSVG_1 = "</svg>";
  string constant appleSVG_0 = "<use href='#apple' x='";
  string constant appleSVG_1 = "' y='";
  string constant appleSVG_2 = "'/>";

  string[] appleX = ["11", "22", "25", "20", "20", "5", "18", "22", "10", "14"];
  string[] appleY = ["12", "19", "25", "18", "9", "8", "8", "12", "21", "20"];

  enum PlantStage {SEED, SAPLING, TREE}

  struct Plant {
    uint256 mintTime; 
    PlantStage stage; 
    uint256 apples;
    uint256 health;
    uint256 lastWaterTime;  
  }
  
  // the metadata for each Plant NFT
  mapping(uint256 => Plant) private plantData; 
  IERC20 private compostToken;

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  constructor() ERC721 ("PlantNFT", "PLANT") {
    console.log("Welcome to the garden!");
    compostToken = new CompostToken(100*(10**18));
  }

  function mintPlant() public {
    uint256 plantId = _tokenIds.current();
    _safeMint(msg.sender, plantId);
    _tokenIds.increment();

    plantData[plantId] = Plant(block.timestamp, PlantStage.SEED, 0, 0, block.timestamp);
    refreshTokenURI(plantId);
  }

  function water(uint256 tokenId) public {
    Plant storage p = plantData[tokenId];

    if(p.stage == PlantStage.SEED) {
      p.stage = PlantStage.SAPLING;
      p.health += 10;
      p.lastWaterTime = block.timestamp;
      refreshTokenURI(tokenId);
      return;
    }    
    
    if(p.stage == PlantStage.SAPLING) {
      p.stage = PlantStage.TREE;
      p.health += 10;
      p.lastWaterTime = block.timestamp;
      refreshTokenURI(tokenId);
      return;
    }

    if(p.stage == PlantStage.TREE) {
      p.lastWaterTime = block.timestamp;
      if(p.apples < 8) {
        p.apples += 1;
      }
      refreshTokenURI(tokenId);
      return;
    }

  }

  function harvest(uint256 tokenId) public {
    require(msg.sender == ownerOf(tokenId), "This plant doesn't belong to you.");
    require(plantData[tokenId].stage == PlantStage.TREE, "Your plant isn't ready to harvest yet!");
    require(plantData[tokenId].apples > 0, "No fruit to harvest!");

    plantData[tokenId].apples -= 1; 
    compostToken.transfer(msg.sender, (2*(10**18)));
    refreshTokenURI(tokenId);
  }

  function getCMPSTBalanceOf(address account) public view returns (uint256) {
    return compostToken.balanceOf(account);
  }

  
  /*
  * This function should be called anytime a plant's state is modified. This function will
  * update the corresponding token's URI.
  */
  function refreshTokenURI(uint256 tokenId) internal {
    PlantStage stage = plantData[tokenId].stage;    
    string memory finalSVG;

    if(stage == PlantStage.SEED) {
      finalSVG = seedSVG;
    } else if(stage == PlantStage.SAPLING) {
      finalSVG = saplingSVG;
    } else if(stage == PlantStage.TREE) {
      Plant memory p = plantData[tokenId];      
      string memory appleSVG;
      uint256 i;

      for (i = 0; i < p.apples; i++) {
        appleSVG = string(abi.encodePacked(appleSVG_0, appleX[i], appleSVG_1, appleY[i], appleSVG_2));
        finalSVG = string(abi.encodePacked(finalSVG, appleSVG));
      }    
      
      finalSVG = string(abi.encodePacked(treeSVG_0, finalSVG, treeSVG_1));
    } 
    
    string memory encodedJson = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            'Plant',
            '", "description": "Plant NFTs!", "image": "data:image/svg+xml;base64,',
            Base64.encode(bytes(finalSVG)),
            '"}'
          )
        )
      )
    );

    _setTokenURI(tokenId, string(abi.encodePacked("data:application/json;base64,", encodedJson)));
  }

}