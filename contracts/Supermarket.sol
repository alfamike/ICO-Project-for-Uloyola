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

    function payment(uint256 amount) public {
        // Ensure the payment amount is not zero
        require(amount > 0, "Payment amount must be greater than zero");

        // Calculate the fee amount based on 50% from the client and 50% from the supermarket
        uint256 feeAmount = (2 * amount * _percentageFee) / 100;

        // Transfer tokens from the caller to this contract
        _myToken.transferFrom(msg.sender, address(this), amount);

        // Approve the MyToken contract to spend feeAmount
        _myToken.approve(address(_myToken), feeAmount);

        // Transfer tokens to MyToken contract
        _myToken.receiveDeposit(feeAmount);
    }
}
