pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract JuiceToken is ERC20 {
    
    constructor(uint256 initialSupply) ERC20 ("Juice", "JUICE") {
        _mint(msg.sender, initialSupply);
    }
}