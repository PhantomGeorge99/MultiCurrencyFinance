// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {DataFeed} from "../oracles/DataFeed.sol";

contract MultiCurrencyTransfer {
    enum Currency {
        BNB,
        BTC,
        SOL
    }

    address private owner;
    mapping(address => mapping(Currency => uint256)) public balances;
    DataFeed private dataFeed;

    event Deposit(address indexed user, Currency currency, uint256 amount);
    event Withdraw(address indexed user, Currency currency, uint256 amount);

    constructor() {
        owner = msg.sender;
        dataFeed = new DataFeed();
    }

    function buyBNB() external payable {
        require(msg.value > 0, "Amount must be greater than zero");
        uint256 bnbPrice = uint256(dataFeed.getBnbEthPrice());
        uint256 bnbAmount = (msg.value * 1 ether) / bnbPrice;
        balances[msg.sender][Currency.BNB] += bnbAmount;
        emit Deposit(msg.sender, Currency.BNB, bnbAmount);
    }

    function buySOL() external payable {
        require(msg.value > 0, "Amount must be greater than zero");
        uint256 solEthPrice = uint256(dataFeed.getSolEthPrice());
        uint256 solAmount = (msg.value * 1 ether) / solEthPrice;
        balances[msg.sender][Currency.SOL] += solAmount;
        emit Deposit(msg.sender, Currency.SOL, solAmount);
    }

    function buyBTC() external payable {
        require(msg.value > 0, "Amount must be greater than zero");
        uint256 btcEthPrice = uint256(dataFeed.getBtcEthPrice());
        uint256 btcAmount = (msg.value * 1 ether) / btcEthPrice;
        balances[msg.sender][Currency.BTC] += btcAmount;
        emit Deposit(msg.sender, Currency.BTC, btcAmount);
    }

    function withdrawSOL(uint256 _solAmount) external {
        require(_solAmount > 0, "Amount must be greater than zero");
        require(balances[msg.sender][Currency.SOL] >= _solAmount, "Insufficient SOL balance");
        uint256 solEthPrice = uint256(dataFeed.getSolEthPrice());
        uint256 ethEquivalent = (_solAmount * solEthPrice) / 1 ether;
        require(address(this).balance >= ethEquivalent, "Insufficient contract balance");
        balances[msg.sender][Currency.SOL] -= _solAmount;
        (bool success,) = msg.sender.call{value: ethEquivalent}("");
        require(success, "ETH transfer failed");
        emit Withdraw(msg.sender, Currency.SOL, _solAmount);
    }

    function withdrawBTC(uint256 _btcAmount) external {
        require(_btcAmount > 0, "Amount must be greater than zero");
        require(balances[msg.sender][Currency.BTC] >= _btcAmount, "Insufficient BTC balance");
        uint256 btcEthPrice = uint256(dataFeed.getBtcEthPrice());
        uint256 ethEquivalent = (_btcAmount * btcEthPrice) / 1 ether;
        require(address(this).balance >= ethEquivalent, "Insufficient contract balance");
        balances[msg.sender][Currency.BTC] -= _btcAmount;
        (bool success,) = msg.sender.call{value: ethEquivalent}("");
        require(success, "ETH transfer failed");
        emit Withdraw(msg.sender, Currency.BTC, _btcAmount);
    }

    function withDrawBNB(uint256 _bnbAmount) external {
        require(_bnbAmount > 0, "Amount must be greater than zero");
        require(balances[msg.sender][Currency.BNB] >= _bnbAmount, "Insufficient BNB balance");
        uint256 bnbEthPrice = uint256(dataFeed.getBnbEthPrice());
        uint256 ethEquivalent = (_bnbAmount * bnbEthPrice) / 1 ether;
        balances[msg.sender][Currency.BNB] -= _bnbAmount;
        (bool success,) = msg.sender.call{value: _bnbAmount}("");
        require(success, "ETH transfer failed");
        emit Withdraw(msg.sender, Currency.ETH, _bnbAmount);
    }

    function getBalance(address _user, Currency _currency) external view returns (uint256) {
        return balances[_user][_currency];
    }

    function getBtcPrice() external view returns (uint256) {
        return dataFeed.getBtcUsdPrice();
    }

    function getBtcToEth() external view returns (uint256) {
        return dataFeed.getBtcUsdPrice();
    }

    function getEthPrice() external view returns (uint256) {
        return dataFeed.getEthUsdPrice();
    }

    function getSolPrice() external view returns (uint256) {
        return dataFeed.getSolUsdPrice();
    }

    function getSolToEth() external view returns (uint256) {
        return dataFeed.getSolToEth();
    }

    function getBnbPrice() external view returns (uint256) {
        return dataFeed.getBnbUsdPrice();
    }

    function getBnbEth() external view returns (uint256) {
        return dataFeed.getBtcUsdPrice();
    }
}
