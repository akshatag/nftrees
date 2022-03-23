// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import { Base64 } from "./libraries/Base64.sol";
import { Utils } from "./libraries/Utils.sol";

contract Plant is ERC721URIStorage {

  uint256 gardenCreationTime;

  string constant treeSVG_0 = "<svg width='32px' height='32px' version='1.1' viewBox='0 0 32 32' xmlns='http://www.w3.org/2000/svg'><image width='32px' height='32px' href='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAV1JREFUWEftl7sNAjEMhrkGMQBrMAMtQhRQ0LAJE1CwBw0FFBS0iBFYgwEQzSFH8skJTmwnx0lIR0Fx+PHlt88O1YD5LE7Lmnve5rPL6lxBPPeVk3A6fns8t+fQzAcQ1f4+rznnMIEmuhWiVQBrcjxQVAEwyFEB/CiMFMMBUCfJIVWKUAVNLA8AHSAQdcbAXONxdhb1GoBcFSic1AecIh5AWD9N53NBLW9VMYAECYCxErpBlDOEpKT0d6kRiwBypmHoowaQThKqkpKd2ooAUmJp6KTeDIj91YSW+mptYxCdAaTK04kCKaWa+0Cs1uFY1squtXMAuJC0TqV22BPuPpC6EdHlZFkwmo3pXck4h9iEzCkVnBgThrmcAhYArfyhep0CaJO7ZfQLBegGjJ0c80YB0KBkW0rJkwpIfTE5vJzJYzNqTOHZ7ngVD+UtI21Tgd12PRP/MfUAvQJ/p8AHu3vdrcNeKZ4AAAAASUVORK5CYII='></image>";
  string constant treeSVG_1 = "</svg>";
  string constant appleSVG_0 = "<image x='";
  string constant appleSVG_1 = "' y='";
  string constant appleSVG_2 = "' width='3px' height='3px' href='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAMAAAADCAYAAABWKLW/AAAAAXNSR0IArs4c6QAAACBJREFUGFdjZGBgYPBZH/B/S+AGRsaXcsn/QQIggMIBAM0ICNbrt1VcAAAAAElFTkSuQmCC'></image>";

  string[] appleX = ["11", "22", "25", "20", "20", "5", "18", "22", "10", "14"];
  string[] appleY = ["12", "19", "25", "18", "9", "8", "8", "12", "21", "20"];

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  constructor() ERC721 ("PlantNFT", "PLANT") {
    console.log("Welcome to the garden!");
    gardenCreationTime = block.timestamp;
  }

  function mintPlantNFT() public {
    uint256 newItemId = _tokenIds.current();
    _safeMint(msg.sender, newItemId);
    _setTokenURI(newItemId, makeTokenURI(1));
    _tokenIds.increment();
  }
  
  function makeTokenURI(uint256 apples) internal view returns (string memory) {
    string memory finalSVG;
    string memory appleSVG;
    uint256 i;

    for (i = 0; i < apples; i++) {
      appleSVG = string(abi.encodePacked(appleSVG_0, appleX[i], appleSVG_1, appleY[i], appleSVG_2));
      finalSVG = string(abi.encodePacked(finalSVG, appleSVG));
    }    
    
    finalSVG = string(abi.encodePacked(treeSVG_0, finalSVG, treeSVG_1));

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


    return string(abi.encodePacked("data:application/json;base64,", encodedJson));
  
  }

}