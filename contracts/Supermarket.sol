// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.20;

import "./MyToken.sol";

contract Supermarket {
    uint8 private _percentageFee;
    MyToken private _myToken;

    constructor(uint8 fee, address myTokenAddress) {
        _percentageFee = fee;
        _myToken = MyToken(myTokenAddress);
    }

    function payment() public payable {
        // Calculate the fee amount based on 50% from the client and 50% from the supermarket
        uint256 feeAmount = (msg.value * _percentageFee) / 100;

        // Ensure the fee amount is not zero
        require(feeAmount > 0, "Fee amount must be greater than zero");

        // The amount to deposit is twice the calculated fee amount
        uint256 amountToDeposit = 2 * feeAmount;

        // Ensure the amount to deposit does not exceed the sent value
        require(amountToDeposit <= msg.value, "Calculated deposit exceeds sent value");

        // Deposit the fee amount to the MyToken contract
        _myToken.deposit{value: amountToDeposit}();
    }
}
