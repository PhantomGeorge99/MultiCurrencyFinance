// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {DataFeed} from "/Users/georgigeorgiev/Documents/Github/chainlink/contracts/src/v0.8/src/vrf/MockV3Aggregator.sol";
contract MultiCurrencyTransfer {
    enum Currency { ETH, BTC, SOL }
    address private owner;
    mapping(address => mapping(Currency => uint256)) public balances;
    DataFeed private dataFeed;

    event Deposit(address indexed user, Currency currency, uint256 amount);
    event Withdraw(address indexed user, Currency currency, uint256 amount);
    event Transfer(address indexed from, address indexed to, Currency currency, uint256 amount);

    constructor(address _dataFeedAddress) {
        owner = msg.sender;
        dataFeed = new DataFeed();
    }

    function depositETH() external payable {
        require(msg.value > 0, "Deposit must be greater than zero");
        balances[msg.sender][Currency.ETH] += msg.value;
        emit Deposit(msg.sender, Currency.ETH, msg.value);
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

        (bool success, ) = msg.sender.call{value: ethEquivalent}("");
        require(success, "ETH transfer failed");

        balances[msg.sender][Currency.SOL] -= _solAmount;

        emit Withdraw(msg.sender, Currency.SOL, _solAmount);
    }

    function withdrawBTC(uint256 _btcAmount) external {
        require(_btcAmount > 0, "Amount must be greater than zero");
        require(balances[msg.sender][Currency.BTC] >= _btcAmount, "Insufficient BTC balance");
        uint256 btcEthPrice = uint256(dataFeed.getBtcEthPrice());
        uint256 ethEquivalent = (_btcAmount * btcEthPrice) / 1 ether;
        require(address(this).balance >= ethEquivalent, "Insufficient contract balance");
        (bool success, ) = msg.sender.call{value: ethEquivalent}("");
        require(success, "ETH transfer failed");
        balances[msg.sender][Currency.BTC] -= _btcAmount;
        emit Withdraw(msg.sender, Currency.BTC, _btcAmount);
    }


    function getBalance(address _user, Currency _currency) external view returns (uint256) {
        return balances[_user][_currency];
    }
}
