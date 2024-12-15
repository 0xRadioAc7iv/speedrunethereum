pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

// import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract Vendor is Ownable {
	event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
	event SellTokens(
		address seller,
		uint256 amountOfTokens,
		uint256 amountOfETH
	);

	YourToken public yourToken;

	uint256 public constant tokensPerEth = 100;

	constructor(address tokenAddress) {
		yourToken = YourToken(tokenAddress);
	}

	// ToDo: create a payable buyTokens() function:
	function buyTokens() public payable {
		require(msg.value > 0, "Must send more than 0 ETH");

		uint256 tokensBought = msg.value * tokensPerEth;
		yourToken.transfer(msg.sender, tokensBought);

		emit BuyTokens(msg.sender, msg.value, tokensBought);
	}

	// ToDo: create a withdraw() function that lets the owner withdraw ETH
	function withdraw() public onlyOwner {
		uint256 amount = address(this).balance;
		require(amount > 0, "Nothing to withdraw; contract balance empty");

		address payable _owner = payable(owner());
		_owner.transfer(amount);
	}

	// ToDo: create a sellTokens(uint256 _amount) function:
	function sellTokens(uint256 _amount) public {
		yourToken.transferFrom(msg.sender, address(this), _amount);

		address payable user = payable(msg.sender);
		uint256 ethToSend = _amount / 100;

		user.transfer(ethToSend);

		emit SellTokens(msg.sender, _amount, ethToSend);
	}
}
