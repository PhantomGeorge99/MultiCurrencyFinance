// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {DataFeed} from "../contracts/oracles/DataFeed.sol";

contract MultiCurrencyTransfer {
    address private owner;
    mapping(address => mapping(string => uint256)) private balances;
    uint256 private transactionFeeBalance;
    uint256 private constant TRANSACTION_FEE_PERCENT = 1;
    DataFeed private dataFeed;

    event Deposit(address indexed user, string currency, uint256 amount);
    event Withdraw(address indexed user, string currency, uint256 amount);
    event TransactionFeeCollected(uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
        dataFeed = new DataFeed();
    }

    function buyCurrency(string memory currency) external payable {
        require(msg.value > 0, "Amount must be greater than zero");
        uint256 transactionFee = (msg.value * TRANSACTION_FEE_PERCENT) / 100;
        uint256 netAmount = msg.value - transactionFee;
        uint256 tokenPriceInEth;

        if (keccak256(bytes(currency)) == keccak256(bytes("BNB"))) {
            tokenPriceInEth = dataFeed.getBnbEthPrice();
        } else if (keccak256(bytes(currency)) == keccak256(bytes("BTC"))) {
            tokenPriceInEth = dataFeed.getBtcEthPrice();
        } else if (keccak256(bytes(currency)) == keccak256(bytes("SOL"))) {
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

    function withdrawAllFunds() external {
        uint256 totalEthEquivalent = 0;

        string[3] memory currencies = ["BNB", "BTC", "SOL"];

        for (uint256 i = 0; i < currencies.length; i++) {
            string memory currency = currencies[i];
            uint256 tokenAmount = balances[msg.sender][currency];
            if (tokenAmount > 0) {
                uint256 tokenPriceInEth;

                if (keccak256(bytes(currency)) == keccak256(bytes("BNB"))) {
                    tokenPriceInEth = dataFeed.getBnbEthPrice();
                } else if (keccak256(bytes(currency)) == keccak256(bytes("BTC"))) {
                    tokenPriceInEth = dataFeed.getBtcEthPrice();
                } else if (keccak256(bytes(currency)) == keccak256(bytes("SOL"))) {
                    tokenPriceInEth = dataFeed.getSolEthPrice();
                }

                uint256 ethEquivalent = (tokenAmount * tokenPriceInEth) / 1 ether;
                totalEthEquivalent += ethEquivalent;

                balances[msg.sender][currency] = 0;

                emit Withdraw(msg.sender, currency, tokenAmount);
            }
        }

        require(totalEthEquivalent > 0, "No funds available for withdrawal");
        require(address(this).balance >= totalEthEquivalent, "Insufficient contract balance");

        (bool success,) = msg.sender.call{value: totalEthEquivalent}("");
        require(success, "ETH transfer failed");
    }

    function withdrawTransactionFees() external onlyOwner {
        require(transactionFeeBalance > 0, "No transaction fees available");

        uint256 feeBalance = transactionFeeBalance;
        transactionFeeBalance = 0;

        (bool success,) = owner.call{value: feeBalance}("");
        require(success, "Fee transfer failed");
    }

    function getBalance(string memory currency) external view returns (uint256) {
        return balances[msg.sender][currency];
    }
}
