// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MyToken.sol";

contract Supermarket {
    uint8 private _percentageFee;
    MyToken private _myToken;

    constructor(uint8 fee, address myTokenAddress) {
        _percentageFee = fee;
        _myToken = MyToken(myTokenAddress);
    }

    function payment(uint256 amount) public payable {
        // Ensure the payment amount is not zero
        require(amount > 0, "Payment amount must be greater than zero");

        // Calculate the fee amount based on 50% from the client and 50% from the supermarket
        uint256 feeAmount = (amount * _percentageFee) / 100;

        // Ensure the fee amount is not zero
        require(feeAmount > 0, "Fee amount must be greater than zero");

        // The total amount to deposit is the payment amount plus the fee amount
        uint256 totalAmountToDeposit = amount + 2 * feeAmount;

        // Ensure the total amount to deposit does not exceed the sent value
        require(totalAmountToDeposit <= msg.value, "Total amount to deposit exceeds sent value");

        // Deposit the total amount to the MyToken contract
        _myToken.deposit{value: totalAmountToDeposit}();
    }
}
