Set-up instructions

1- Deploy the MyToken contract
2- Deploy the Supermarket contract using MyToken contract address and the fee
3- Initialize MyToken contract
3- Add supermarket contract address to MyToken list of authorized contracts

Payment process

1- Client call MyToken Contract approve function to allow the supermarket to receive the tokens
2- Client makes a call to Supermarket.payment function. This function will transfer
the amount to the supermarket and then the supermarket will calculate the fee and transfer the fee to
the My Token Contract after the automatic approval
