// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {DataFeed} from "../contracts/oracles/DataFeed.sol";

contract MultiCurrencyTransfer {
    enum Currency {
        BNB,
        BTC,
        SOL
    }

    address private owner;
    mapping(address => mapping(Currency => uint256)) private balances;
    uint256 private transactionFeeBalance;
    uint256 private constant TRANSACTION_FEE_PERCENT = 1;
    DataFeed private dataFeed;

    event Deposit(address indexed user, Currency currency, uint256 amount);
    event Withdraw(address indexed user, Currency currency, uint256 amount);
    event TransactionFeeCollected(uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
        dataFeed = new DataFeed();
    }

    function buyCurrency(Currency currency) external payable {
        require(msg.value > 0, "Amount must be greater than zero");
        uint256 transactionFee = (msg.value * TRANSACTION_FEE_PERCENT) / 100;
        uint256 netAmount = msg.value - transactionFee;
        uint256 tokenPriceInEth;
        if (currency == Currency.BNB) {
            tokenPriceInEth = dataFeed.getBnbEthPrice();
        } else if (currency == Currency.BTC) {
            tokenPriceInEth = dataFeed.getBtcEthPrice();
        } else if (currency == Currency.SOL) {
            tokenPriceInEth = dataFeed.getSolEthPrice();
        } else {
            revert("Unsupported currency");
        }

        uint256 tokenAmount = (netAmount * 1 ether) / tokenPriceInEth;
        balances[msg.sender][currency] += tokenAmount;
        transactionFeeBalance += transactionFee;

        emit Deposit(msg.sender, currency, tokenAmount);
        emit TransactionFeeCollected(transactionFee);
    }

    function withdrawCurrency(Currency currency, uint256 tokenAmount) external {
        require(tokenAmount > 0, "Amount must be greater than zero");
        require(balances[msg.sender][currency] >= tokenAmount, "Insufficient token balance");

        uint256 tokenPriceInEth;
        if (currency == Currency.BNB) {
            tokenPriceInEth = dataFeed.getBnbEthPrice();
        } else if (currency == Currency.BTC) {
            tokenPriceInEth = dataFeed.getBtcEthPrice();
        } else if (currency == Currency.SOL) {
            tokenPriceInEth = dataFeed.getSolEthPrice();
        } else {
            revert("Unsupported currency");
        }

        uint256 ethEquivalent = (tokenAmount * tokenPriceInEth) / 1 ether;
        balances[msg.sender][currency] -= tokenAmount;

        (bool success,) = msg.sender.call{value: ethEquivalent}("");
        require(success, "ETH transfer failed");

        emit Withdraw(msg.sender, currency, tokenAmount);
    }

    function withdrawTransactionFees() external onlyOwner {
        require(transactionFeeBalance > 0, "No transaction fees available");

        uint256 feeBalance = transactionFeeBalance;
        transactionFeeBalance = 0;

        (bool success,) = owner.call{value: feeBalance}("");
        require(success, "Fee transfer failed");
    }

    function getBalance(address user, Currency currency) external view returns (uint256) {
        return balances[user][currency];
    }
}
