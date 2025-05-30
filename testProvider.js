// testProvider.js
require('dotenv').config();
const { JsonRpcProvider } = require('@ethersproject/providers');

async function main() {
  // force it to Polygon (chainId 137)
  const provider = new JsonRpcProvider(process.env.POLYGON_RPC_URL, 137);

  try {
    const block = await provider.getBlockNumber();
    console.log('📦 latest block #:', block);
  } catch (err) {
    console.error('❌ provider error:', err);
  }
}

main();