// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract DataFeed {

    function getEthUsdPrice() external pure returns (uint256) {
        return 2700 * 10**18; // Simulate ETH/USD at $2700
    }

    function getBtcUsdPrice() external pure returns (uint256) {
        return 70590 * 10**18; // Simulate BTC/USD at $70,590
    }

    function getBtcEthPrice() external pure returns (uint256) {
        return 27.67 * 10**18; // Simulate BTC/ETH at 27.67 ETH 
    }

    function getSolUsdPrice() external pure returns (uint256) {
        return 170 * 10**18; // Simulate SOL/USD at $170
    }

    function getSolEthPrice() external pure returns (uint256) {
        return 0.067 * 10**18; // Simulate SOL/ETH at 0.067 ETH
    }

    function getBnbUsdPrice() external pure returns (uint256) {
        return 564 * 10**18; // Simulate BNB/USD at $564
    }
    function getBnbEthPrice() external pure returns (uint256) {
    return 0.23 * 10**18; // Simulate BNB/ETH at 0.23 ETH
}
}

