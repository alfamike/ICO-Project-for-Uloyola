// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract MyToken is Initializable, ERC20Upgradeable, ERC20PermitUpgradeable {
    address private _owner;
    address[] private _authorizedAgents;
    address[] private _npoAddresses;
    address[] private _supermarketsAddresses;
    mapping(address => uint256) private _balancesSupermarkets;
    mapping(address => uint256) private _balancesNPOs;

    constructor() {
        _disableInitializers();
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Not authorized");
        _;
    }

    modifier onlyAuthorizedAgents() {
        require(isAuthorized(msg.sender), "Caller is not authorized");
        _;
    }

    modifier onlySupermarket() {
        require(isSupermarket(msg.sender), "Caller is not a registered supermarket");
        _;
    }

    function isAuthorized(address agent) internal view returns (bool) {
        for (uint256 i = 0; i < _authorizedAgents.length; i++) {
            if (_authorizedAgents[i] == agent) {
                return true;
            }
        }
        return false;
    }

    function isSupermarket(address supermarket) internal view returns (bool) {
        for (uint256 i = 0; i < _supermarketsAddresses.length; i++) {
            if (_supermarketsAddresses[i] == supermarket) {
                return true;
            }
        }
        return false;
    }

    function initialize() initializer public {
        __ERC20_init("MyToken", "MTK");
        __ERC20Permit_init("MyToken");
        _owner = msg.sender;
        _authorizedAgents.push(msg.sender);
        _mint(msg.sender, 1000000000 * 10 ** decimals());
    }

    function decimals() public pure override returns (uint8) {
        return 2;
    }

    function deposit() payable external onlySupermarket {
        _balancesSupermarkets[msg.sender] += msg.value;
    }

    function transferToNPO(address npo, uint256 value) public onlyAuthorizedAgents returns (bool) {
        _transfer(address(this), npo, value);
        _balancesNPOs[npo] += value;
        return true;
    }

    function addAuthorizedAgents(address newAuthorized) public onlyOwner {
        require(!_addressExists(newAuthorized, _authorizedAgents), "Address is already authorized");
        _authorizedAgents.push(newAuthorized);
    }

    function removeAuthorizedAgents(address oldAuthorized) public onlyOwner {
        _removeAddress(oldAuthorized, _authorizedAgents);
    }

    function addNPO(address npo, uint256 initialBalance) public onlyAuthorizedAgents {
        require(!_addressExists(npo, _npoAddresses), "NPO already exists");
        _balancesNPOs[npo] = initialBalance;
        _npoAddresses.push(npo);
    }

    function removeNPO(address npo) public onlyAuthorizedAgents {
        require(_balancesNPOs[npo] != 0 || _addressExists(npo, _npoAddresses), "NPO does not exist");
        delete _balancesNPOs[npo];
        _removeAddress(npo, _npoAddresses);
    }

    function addSupermarket(address supermarket) public onlyAuthorizedAgents {
        require(!_addressExists(supermarket, _supermarketsAddresses), "Supermarket already exists");
        _supermarketsAddresses.push(supermarket);
    }

    function removeSupermarket(address supermarket) public onlyAuthorizedAgents {
        _removeAddress(supermarket, _supermarketsAddresses);
        delete _balancesSupermarkets[supermarket];
    }

    function getNPOBalances() view public onlyAuthorizedAgents returns (address[] memory, uint256[] memory) {
        uint256 length = _npoAddresses.length;
        address[] memory addresses = new address[](length);
        uint256[] memory balances = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            addresses[i] = _npoAddresses[i];
            balances[i] = _balancesNPOs[addresses[i]];
        }

        return (addresses, balances);
    }

    function getSupermarketBalances() view public onlyAuthorizedAgents returns (address[] memory, uint256[] memory) {
        uint256 length = _supermarketsAddresses.length;
        address[] memory addresses = new address[](length);
        uint256[] memory balances = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            addresses[i] = _supermarketsAddresses[i];
            balances[i] = _balancesSupermarkets[addresses[i]];
        }

        return (addresses, balances);
    }

    function _addressExists(address addr, address[] storage addrList) internal view returns (bool) {
        for (uint256 i = 0; i < addrList.length; i++) {
            if (addrList[i] == addr) {
                return true;
            }
        }
        return false;
    }

    function _removeAddress(address addr, address[] storage addrList) internal {
        for (uint256 i = 0; i < addrList.length; i++) {
            if (addrList[i] == addr) {
                addrList[i] = addrList[addrList.length - 1];
                addrList.pop();
                break;
            }
        }
    }
}
