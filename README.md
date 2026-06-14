# JN-19 AI Credit Market Starter

Hackathon demo: buy fake **JN19 AI credits** with fake **mUSDC** using ERC-20 tokens and smart-contract escrow.

## Important demo wording

This is **not** resale of real OpenAI / ChatGPT / Claude / Gemini credits.

For your pitch, say:

> JN-19 is a demo platform credit. Users can buy fake AI compute credits with fake USDC on a test network. After buying credits, the user can spend/burn them to simulate running an AI request.

Do **not** say:

> Users can buy someone else's real ChatGPT credits or API balance.

## What it includes

- `JN19Credit.sol` — fake ERC-20 AI credit token named JN-19.
- `MockUSDC.sol` — fake ERC-20 stablecoin for demo payments.
- `JN19Market.sol` — marketplace where sellers escrow JN19 and buyers pay mUSDC.
- `frontend/index.html` — simple MetaMask UI.
- Hardhat tests and deployment script.

## Quick start

```bash
npm install
npm test
```

## Run locally

Terminal 1:

```bash
npm run node
```

Terminal 2:

```bash
npm run deploy:localhost
```

The deploy script writes addresses to `frontend/addresses.json`.

Serve the frontend:

```bash
cd frontend
python3 -m http.server 3000
```

Open:

```text
http://localhost:3000
```

## MetaMask local demo

1. Add network:
   - RPC URL: `http://127.0.0.1:8545`
   - Chain ID: `31337`
   - Currency symbol: `ETH`
2. Import two Hardhat private keys from the terminal running `npm run node`.
3. Account 1 = seller/provider.
4. Account 2 = buyer/user.

## Demo flow

### Seller / provider

1. Connect wallet.
2. Claim 1,000 JN19.
3. Create listing: `100 JN19 for 20 mUSDC`.

### Buyer / user

1. Switch MetaMask to buyer.
2. Claim 1,000 mUSDC.
3. Buy the listing.
4. Click `Run Fake AI Request` to spend/burn 5 JN19.

## Judge pitch

> JN-19 is a testnet AI-credit marketplace. A provider can list platform compute credits, a user pays with fake stablecoin, and the credits are escrowed and transferred by a smart contract. The demo avoids real money and real provider-credit resale by using mock tokens and a simulated AI-credit burn step.
