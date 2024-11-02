// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract DataFeed {
    // Function to get the simulated ETH/USD price
    function getEthUsdPrice() external pure returns (uint256) {
        return 2700 * 10**18; // Simulate ETH/USD at $2700
    }

    // Function to get the simulated BTC/USD price
    function getBtcUsdPrice() external pure returns (uint256) {
        return 70590 * 10**18; // Simulate BTC/USD at $70,590
    }

    // Function to get the simulated BTC/ETH price
    function getBtcEthPrice() external pure returns (uint256) {
        return 27.67 * 10**18; // Simulate BTC/ETH at 27.67 ETH per BTC
    }

    // Function to get the simulated SOL/USD price
    function getSolUsdPrice() external pure returns (uint256) {
        return 170 * 10**18; // Simulate SOL/USD at $170
    }

    // Function to get the simulated SOL/ETH price
    function getSolEthPrice() external pure returns (uint256) {
        return 0.067 * 10**18; // Simulate SOL/ETH at 0.067 ETH per SOL
    }
}

