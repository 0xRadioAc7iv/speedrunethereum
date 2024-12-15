// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
	event Stake(address indexed user, uint256 indexed amount);

	ExampleExternalContract public exampleExternalContract;

	uint256 public constant threshold = 1 ether;
	uint256 public deadline = block.timestamp + 72 hours;
	bool public openForWithdraw = false;

	mapping(address => uint256) private s_balances;

	constructor(address exampleExternalContractAddress) {
		exampleExternalContract = ExampleExternalContract(
			exampleExternalContractAddress
		);
	}

	function stake() public payable {
		require(msg.value > 0, "ETH Staking Amount must be more than zero");
		require(block.timestamp < deadline, "Staking deadline has passed");

		s_balances[msg.sender] += msg.value;

		emit Stake(msg.sender, msg.value);
	}

	// After some `deadline` allow anyone to call an `execute()` function
	function execute() public {
		require(block.timestamp > deadline, "Staking deadline has not passed");

		uint256 contractBalance = address(this).balance;

		if (contractBalance >= threshold) {
			exampleExternalContract.complete{ value: address(this).balance }();
		} else {
			openForWithdraw = true;
		}
	}

	function withdraw() public {
		require(openForWithdraw, "Withdrawal window is not open");

		address payable withdrawerAddress = payable(msg.sender);
		uint256 withdrawalAmount = s_balances[withdrawerAddress];

		withdrawerAddress.transfer(withdrawalAmount);
	}

	// If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

	// If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance

	// Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

	function timeLeft() public view returns (uint256) {
		if (block.timestamp >= deadline) {
			return 0;
		}

		return deadline - block.timestamp;
	}

	function balances(address _userAddress) public view returns (uint256) {
		return s_balances[_userAddress];
	}

	receive() external payable {
		stake();
	}
}
