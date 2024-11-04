// Connect to MetaMask
async function connectMetaMask() {
    if (typeof window.ethereum !== 'undefined') {
        await ethereum.request({ method: 'eth_requestAccounts' });
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        return { provider, signer };
    } else {
        alert("MetaMask not found! Please install it.");
    }
}

// Contract ABI and Address
const contractABI = [ /*... ABI from the deployed contract ...*/ ];
const contractAddress = '0xd041338ec9b9dbe5e0d490f49ee8daa71087df09cf9805a1af1c5268cbfbd18e';

async function getContract() {
    const { provider, signer } = await connectMetaMask();
    return new ethers.Contract(contractAddress, contractABI, signer);
}

// Buy Currency Function
async function buyCurrency() {
    const currency = document.getElementById("currencyInput").value;
    const ethAmount = document.getElementById("ethAmountInput").value;
    
    try {
        const contract = await getContract();
        const transaction = await contract.buyCurrency(currency, {
            value: ethers.utils.parseEther(ethAmount)
        });
        await transaction.wait();
        alert("Currency bought successfully!");
    } catch (error) {
        console.error("Error buying currency:", error);
        alert("Failed to buy currency. Check console for details.");
    }
}

// Withdraw All Funds Function
async function withdrawAllFunds() {
    try {
        const contract = await getContract();
        const transaction = await contract.withdrawAllFunds();
        await transaction.wait();
        alert("Funds withdrawn successfully!");
    } catch (error) {
        console.error("Error withdrawing funds:", error);
        alert("Failed to withdraw funds. Check console for details.");
    }
}

// Withdraw Transaction Fees (Owner Only)
async function withdrawTransactionFees() {
    try {
        const contract = await getContract();
        const transaction = await contract.withdrawTransactionFees();
        await transaction.wait();
        alert("Transaction fees withdrawn successfully!");
    } catch (error) {
        console.error("Error withdrawing transaction fees:", error);
        alert("Failed to withdraw transaction fees. Check console for details.");
    }
}

// Connect MetaMask on page load
window.onload = connectMetaMask;
