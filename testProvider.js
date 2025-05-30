// testProvider.js
require('dotenv').config();
const { JsonRpcProvider } = require('@ethersproject/providers');

async function main() {
  const provider = new JsonRpcProvider(process.env.POLYGON_RPC_URL);
  try {
    const block = await provider.getBlockNumber();
    console.log('📦 latest block #:', block);
  } catch (err) {
    console.error('❌ provider error:', err);
  }
}

main();