# Pitchside Pot — On-Chain Fantasy Contests

> Draft a fantasy squad and stake an entry fee into a contest pot. Scores finalize on-chain and the pot splits to the leaderboards - no off-platform payouts, no bookkeeping spreadsheets.

## What it does

Draft a fantasy squad and stake an entry fee into a contest pot. Scores finalize on-chain and the pot splits to the leaderboards - no off-platform payouts, no bookkeeping spreadsheets. The entire lifecycle lives in one contract, every button in the UI calls a real function on it — there is no mock backend.

## Contract

| | |
|---|---|
| File | `contracts/FantasySports.sol` |
| Contract name | `FantasySports` (inherits `ReentrancyGuard, Ownable`) |
| Solidity | `^0.8.20` |
| State functions | 5 (of which 1 payable) |
| Deployed (mainnet 677) | not yet deployed — placeholder `0x000…000` |

### Function surface

| Function | Type | Returns |
|---|---|---|
| `owner` | view | address |
| `createContest` | write | uint256 |
| `joinContest` | payable | tx receipt |
| `resolveContest` | write | result / revert |
| `getContest` | view | address creator, string memory sport, string memory title, uint256 entryFee, uint256 maxParticipants, uint256 participantCount, uint256 prizePool, uint256 deadline, bool active, bool resolved, address winner |

### Events

| Event | Signature |
|---|---|
| `OwnershipTransferred` | (address indexed previousOwner, address indexed newOwner) |
| `ContestCreated` | (uint256 indexed cid, address indexed creator, string sport, string title, uint256 entryFee, uint256 maxParticipants) |
| `ContestJoined` | (uint256 indexed cid, address indexed participant, uint256 fee) |
| `ContestResolved` | (uint256 indexed cid, address indexed winner, uint256 prize) |

## Network

| | |
|---|---|
| Chain | BOT Chain Mainnet (chainId `677`) |
| RPC | `https://rpc.botchain.ai` |
| Explorer | `https://scan.botchain.ai` |
| Native currency | BOT (18 decimals) |
| Testnet | BOT Chain Testnet (chainId `968`) - `https://rpc.bohr.life` |

## Frontend

- **Wallet connection** - [Reown/AppKit](https://reown.com) (Web3Modal v2, inline modal, `subscribeAccount` / `subscribeNetwork`)
- **Web3 library** - ethers.js v6 (`BrowserProvider`, `Contract`, `parseEther`)
- **Animation** - GSAP 3 + ScrollTrigger (`expo.out` entrances, `prefers-reduced-motion` fallback renders content instantly)
- **Zero build step** - single `index.html`, CDN imports via ESM import map; no bundler, no framework runtime
- **Accessibility** - auto-generated `aria-label`s on all binary and form controls, focus-visible styles, button busy states

## Run it locally

```bash
git clone https://github.com/Henoch4/fantasy-sports.git
cd fantasy-sports
# open the frontend directly (no build step)
start frontend/index.html   # Windows
# or serve it if your browser blocks file:// modules:
npx serve frontend
```

> **Note** — contract addresses: the UI reads its deploy target from the `CA` constant at the top of the inline script. Until the contract is deployed to mainnet 677, the demo runs against the deterministic sample data built into the page; after deployment, set `CA['677']` to the real address and every button goes live.