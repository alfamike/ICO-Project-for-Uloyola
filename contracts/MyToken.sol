// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

contract MyToken is Initializable, ERC20Upgradeable, ERC20PermitUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    // Agents from the contract owner company
    EnumerableSetUpgradeable.AddressSet private _authorizedAgents;
    // NPO Addresses
    EnumerableSetUpgradeable.AddressSet private _npoAddresses;
    // Supermarkets addresses
    EnumerableSetUpgradeable.AddressSet private _supermarketsAddresses;
    // Balance of tokens received from supermarkets
    mapping(address => uint256) private _balancesSupermarkets;
    // Balance of tokens sent to NPOs
    mapping(address => uint256) private _balancesNPOs;

    function initialize() initializer external {
        __ERC20_init("MyToken", "MTK");
        __ERC20Permit_init("MyToken");
        __Ownable_init(msg.sender); // Initialize owner with the deployer address
        __ReentrancyGuard_init(); // Reentrancy Guard
        _authorizedAgents.add(msg.sender); // Add owner as first authorized agent
        _mint(msg.sender, 1000000000 * 10 ** decimals());
    }

    modifier onlyAuthorizedAgents() {
        require(_authorizedAgents.contains(msg.sender), "Caller is not authorized");
        _;
    }

    modifier onlySupermarket() {
        require(_supermarketsAddresses.contains(msg.sender), "Caller is not a registered supermarket");
        _;
    }

    function decimals() public pure override returns (uint8) {
        return 2;
    }

    function receiveDeposit(uint256 amount) external onlySupermarket nonReentrant {
        _transfer(msg.sender, address(this), amount);
        _balancesSupermarkets[msg.sender] += amount;
    }

    function transferToNPO(address npo, uint256 value) public onlyAuthorizedAgents nonReentrant returns (bool) {
        _transfer(address(this), npo, value);
        _balancesNPOs[npo] += value;
        return true;
    }

    function addAuthorizedAgents(address newAuthorized) public onlyOwner {
        require(_authorizedAgents.add(newAuthorized), "Address is already authorized");
    }

    function removeAuthorizedAgents(address oldAuthorized) public onlyOwner {
        require(_authorizedAgents.remove(oldAuthorized), "Address not found");
    }

    function addNPO(address npo, uint256 initialBalance) public onlyAuthorizedAgents {
        require(_npoAddresses.add(npo), "NPO already exists");
        _balancesNPOs[npo] = initialBalance;
    }

    function removeNPO(address npo) public onlyAuthorizedAgents {
        require(_npoAddresses.remove(npo), "NPO does not exist");
        delete _balancesNPOs[npo];
    }

    function addSupermarket(address supermarket) public onlyAuthorizedAgents {
        require(_supermarketsAddresses.add(supermarket), "Supermarket already exists");
    }

    function removeSupermarket(address supermarket) public onlyAuthorizedAgents {
        require(_supermarketsAddresses.remove(supermarket), "Supermarket not found");
        delete _balancesSupermarkets[supermarket];
    }

    function getNPOBalances() view public onlyAuthorizedAgents returns (address[] memory, uint256[] memory) {
        uint256 length = _npoAddresses.length();
        address[] memory addresses = new address[](length);
        uint256[] memory balances = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            addresses[i] = _npoAddresses.at(i);
            balances[i] = _balancesNPOs[addresses[i]];
        }

        return (addresses, balances);
    }

    function getSupermarketBalances() view public onlyAuthorizedAgents returns (address[] memory, uint256[] memory) {
        uint256 length = _supermarketsAddresses.length();
        address[] memory addresses = new address[](length);
        uint256[] memory balances = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            addresses[i] = _supermarketsAddresses.at(i);
            balances[i] = _balancesSupermarkets[addresses[i]];
        }

        return (addresses, balances);
    }
}
