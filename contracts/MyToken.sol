// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract MyToken is Initializable, ERC20Upgradeable, ERC20PermitUpgradeable {
    // Address for the contract owner
    address private _owner;
    // Fee percentage for charity fund
    uint8 public fee;
    // Address for authorized fund retriever
    address private _fundRetriver;
    //Address for delegated fund retriever
    address private _fundDelegatedRetriver;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        initialize();
        _disableInitializers();
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Not authorized");
        _;
    }

    function initialize() initializer public {
        __ERC20_init("MyToken", "MTK");
        __ERC20Permit_init("MyToken");
        _owner = msg.sender;
        _mint(msg.sender, 1000000000 * 10 ** decimals());
        fee = 5;
    }

    function setFee (uint8 newFee) public onlyOwner {
        fee = newFee;
    }

    function transfer(address to, uint256 value) public virtual override returns (bool) {
        address owner = _msgSender();

        // Value minus fee
        uint256 newValue = value - (value*fee/100);

        // Transfer with fee applied
        _transfer(owner, to, newValue);

        // Calculate the fee
        uint256 fee_aux = value*fee/100;

        // Transfer to the fund
        _transfer(owner, address(this), fee_aux);

        return true;
    }

    function fundRetrival (address destination) public virtual {
        require(msg.sender != _owner,"The contract owner can not retrive the charity fund");
        require(msg.sender == _fundRetriver || msg.sender == _fundDelegatedRetriver , "The charity fund can only be retrieved by the authorized person or the delegated person");
       
        _transfer(address(this), destination, address(this).balance);
    

    }

    function setDelegatedRetriever (address newDelegatedRetriver) public virtual {
        require(msg.sender == _fundRetriver, "Only the fund retriver can change the delegated fund retrever");
        require(msg.sender != _owner, "The delegated fund authorized person can not be the contract owner");
        _fundDelegatedRetriver = newDelegatedRetriver;
    }

    function setFundRetriever (address newRetriver) public virtual {
        require(msg.sender != _owner, "Only the contract owner can change the fund retriver");
        require(msg.sender != newRetriver, "The fund authorized person can not be the contract owner");
        _fundRetriver = newRetriver;
    }
}
