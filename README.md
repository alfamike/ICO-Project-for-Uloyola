# Set-up instructions

* Deploy the MyToken contract
* Deploy the Supermarket contract using MyToken contract address and the fee
* Initialize MyToken contract
* Add supermarket contract address to MyToken list of authorized contracts

# Payment process

* Client call MyToken Contract approve function to allow the supermarket to receive the tokens
* Client makes a call to Supermarket.payment function. This function will transfer
the amount to the supermarket and then the supermarket will calculate the fee and transfer the fee to
the My Token Contract after the automatic approval
