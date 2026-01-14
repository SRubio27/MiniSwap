# 🦄 Simple AMM (WETH / USDC)

This project implements a decentralized **Automated Market Maker (AMM)** based on the Constant Product Formula ($x \cdot y = k$). It is built with **Solidity v0.8.28** using the **Foundry** development framework.

The protocol enables seamless swaps between **WETH** and **USDC** and allows users to participate as liquidity providers by minting **LP Tokens**.

## 📋 Key Features

* **Token Swaps:**
    * Swap `WETH` for `USDC`.
    * Swap `USDC` for `WETH`.
    * Built-in **Slippage Protection** via the `minOut` parameter.
* **Liquidity Management:**
    * **Add Liquidity:** Deposit token pairs and receive `LPToken` based on the geometric mean of the deposit for initial liquidity.
    * **Remove Liquidity:** Burn `LPToken` to withdraw the underlying assets plus accumulated fees.
* **Fee Structure:**
    * A **0.3%** trading fee (calculated as `997/1000`) is applied to every swap, rewarding liquidity providers by increasing the pool's reserves.
* **Security & Best Practices:**
    * Uses OpenZeppelin's `SafeERC20` for secure token transfers.
    * Inherits from `Ownable` for administrative control.
    * Strict validation of reserves and constant product $k$.

## 🧮 Mathematical Model

The AMM follows the Constant Product invariant:

$$(R_x + \Delta x_{in} \cdot (1 - \phi)) \cdot (R_y - \Delta y_{out}) = k$$

Where:
* $\phi$: Fee of 0.3% (0.003).
* $R_x, R_y$: Current reserves of WETH and USDC.

Core logic snippet from `AMM.sol`:

```solidity
uint256 amountInWithFee = (amountIn * 997) / 1000;
uint256 numerator = amountInWithFee * reserveOut;
uint256 denominator = reserveIn + amountInWithFee;
amountOut = numerator / denominator;
```

## 🛠️ Tech Stack

* **Smart Contract Language:** Solidity `^0.8.28`
* **Development Framework:** Foundry (Forge, Cast)
* **Libraries:** OpenZeppelin (ERC20, SafeERC20, Ownable, Math)

## 📂 Project Structure

```text
├── src/
│   ├── AMM.sol           # Core exchange logic
│   └── LPToken.sol       # Liquidity Provider Token (ERC20)
├── test/
│   ├── AMMTestBase.t.sol     # Shared test setup and helpers
│   ├── AddLiquidity.t.sol    # Liquidity provision tests
│   ├── RemoveLiquidity.t.sol # Liquidity withdrawal tests
│   ├── SwapWETHforUSDC.t.sol # WETH to USDC swap tests
│   ├── SwapUSDCforWETH.t.sol # USDC to WETH swap tests
│   └── mocks/                # Mock ERC20 tokens for local testing
└── lib/                  # External dependencies (OpenZeppelin)
```

## 🚀 Getting Started

### Prerequisites
Install [Foundry](https://book.getfoundry.sh/getting-started/installation).

### 1. Clone and Install
```bash
git clone <YOUR_REPOSITORY_URL>
cd <PROJECT_DIRECTORY>
forge install
```

### 2. Compile
```bash
forge build
```

## 🧪 Testing

The project includes a robust test suite covering success paths, edge cases, and expected reverts.

**Run all tests:**
```bash
forge test
```

**Run with detailed traces (Logging):**
```bash
forge test -vvvv
```

**Check Gas Snapshots:**
```bash
forge snapshot
```

**Generate Coverage Report:**
```bash
forge coverage
```

## 📜 License

This project is licensed under the **MIT License**.
