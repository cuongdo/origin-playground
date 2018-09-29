const Web3 = require('web3')
const OriginTokenContract = require('./OriginToken.json')

// Instructions for offline transactions are here:
// https://kb.myetherwallet.com/offline/making-offline-transaction-on-myetherwallet.html

const web3 = new Web3()

const abi = OriginTokenContract.abi
// Get the ABI for the function we want to call.
const transferAbi = abi.filter(f => f.name == 'transfer')[0]
// Create the data for the offline transaction
const txnData = web3.eth.abi.encodeFunctionCall(transferAbi, [
  // parameter 1 (to address)
  '0x99753a4661Bd929Dce85D60721C8eaf4E84f3037',
  // parameter 2 (value, needs to be multiplied by 10**18)
  '1000000000000000000'
])
console.log(`paste the following into the "data" field in step 2: generate transaction (offline computer):\n${txnData}`)
