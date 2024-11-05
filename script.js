
let signer, provider;

// Replace with your actual contract ABI
const contractABI = [
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "user",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "currency",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "Deposit",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "TransactionFeeCollected",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "user",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "currency",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "Withdraw",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "currency",
				"type": "string"
			}
		],
		"name": "buyCurrency",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "currency",
				"type": "string"
			}
		],
		"name": "getBalance",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "withdrawAllFunds",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "withdrawTransactionFees",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	}
];

// Replace with your actual contract address
const contractAddress = '0x0BBF4aEA1c484daDDAFB32F855e0ED97Cbf68606';

// Check if MetaMask is installed and connect
async function connectMetaMask() {
    // Check if MetaMask (Ethereum provider) is available
    if (typeof window.ethereum !== 'undefined' && window.ethereum.isMetaMask) {
        try {
            // Request account access
            await window.ethereum.request({ method: 'eth_requestAccounts' });
            provider = new ethers.providers.Web3Provider(window.ethereum);
            signer = provider.getSigner();
            console.log('MetaMask connected');
            alert('MetaMask connected successfully!');
        } catch (error) {
            console.error('User denied account access or other error:', error);
            alert('Failed to connect MetaMask. Please try again.');
        }
    } else {
        alert('MetaMask not found! Please install it.');
    }
}

// Initialize contract with provider and signer
function getContract() {
    if (!signer || !provider) {
        alert("Please connect to MetaMask first.");
        return null;
    }
    return new ethers.Contract(contractAddress, contractABI, signer);
}

// Buy Currency Function
async function buyCurrency() {
    const currency = document.getElementById('currencyInput').value;
    const ethAmount = document.getElementById('ethAmountInput').value;

    const contract = getContract();
    if (!contract) return;

    try {
        const transaction = await contract.buyCurrency(currency, {
            value: ethers.utils.parseEther(ethAmount)
        });
        await transaction.wait();
        alert('Currency bought successfully!');
    } catch (error) {
        console.error('Error buying currency:', error);
        alert('Failed to buy currency. Check console for details.');
    }
}

// Withdraw All Funds Function
async function withdrawAllFunds() {
    const contract = getContract();
    if (!contract) return;

    try {
        const transaction = await contract.withdrawAllFunds();
        await transaction.wait();
        alert('Funds withdrawn successfully!');
    } catch (error) {
        console.error('Error withdrawing funds:', error);
        alert('Failed to withdraw funds. Check console for details.');
    }
}

// Withdraw Transaction Fees (Owner Only)
async function withdrawTransactionFees() {
    const contract = getContract();
    if (!contract) return;

    try {
        const transaction = await contract.withdrawTransactionFees();
        await transaction.wait();
        alert('Transaction fees withdrawn successfully!');
    } catch (error) {
        console.error('Error withdrawing transaction fees:', error);
        alert('Failed to withdraw transaction fees. Check console for details.');
    }
}

// Get Live Price Data
async function getLivePrice(currency, unit) {
    const contract = getContract();
    if (!contract) return;

    try {
        let price;
        // Determine which currency and unit to use based on input
        if (currency === 'BTC' && unit === 'USD') {
            price = await contract.getBtcUsdPrice();
        } else if (currency === 'BTC' && unit === 'ETH') {
            price = await contract.getBtcEthPrice();
        } else if (currency === 'SOL' && unit === 'USD') {
            price = await contract.getSolUsdPrice();
        } else if (currency === 'SOL' && unit === 'ETH') {
            price = await contract.getSolEthPrice();
        } else if (currency === 'BNB' && unit === 'USD') {
            price = await contract.getBnbUsdPrice();
        } else if (currency === 'BNB' && unit === 'ETH') {
            price = await contract.getBnbEthPrice();
        } else {
            alert('Unsupported currency or unit');
            return;
        }
        
        document.getElementById('priceDisplay').innerText = `The price of ${currency} in ${unit} is ${price.toString()}`;
    } catch (error) {
        console.error('Error getting live price:', error);
        alert('Failed to get live price. Check console for details.');
    }
}

// Connect MetaMask on page load
window.addEventListener('load', async () => {
    await connectMetaMask();
});
