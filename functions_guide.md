# Estructura del proyecto
# Estructura del proyecto AMM (MVP realista, nivel intermedio)

contracts/
│
├─ AMM.sol
│  ├─ getReserves()
│  ├─ getPrice()
│  ├─ addLiquidity(wethAmount, usdcAmount)
│  ├─ removeLiquidity(lpAmount)
│  ├─ swapWETHForUSDC(amountIn, minOut)
│  ├─ swapUSDCForWETH(amountIn, minOut)
│  ├─ getAmountOut(amountIn, reserveIn, reserveOut)
│  ├─ getLiquidityMinted(wethAmount, usdcAmount)
│  └─ (fee fijo 0.3% aplicado solo en swaps)
│
├─ LPToken.sol
│  ├─ mint(to, amount)
│  ├─ burn(from, amount)
│  ├─ totalSupply()
│  └─ balanceOf(user)
│
├─ interfaces/
│  ├─ IERC20.sol
│  └─ ILPToken.sol
│
├─ mocks/
│  ├─ MockWETH.sol
│  └─ MockUSDC.sol
│
test/
│
├─ AMM.t.sol
│  ├─ testAddLiquidity()
│  ├─ testRemoveLiquidity()
│  ├─ testSwapWETHForUSDC()
│  ├─ testSwapUSDCForWETH()
│  ├─ testFeesAccumulation()
│
└─ LPToken.t.sol
   ├─ testMint()
   └─ testBurn()


# Funciones del proyecto AMM - Nivel Intermedio Realista

## AMM.sol
- getReserves()
- getPrice()
- addLiquidity(wethAmount, usdcAmount)
- removeLiquidity(lpAmount)
- swapWETHForUSDC(amountIn, minOut)
- swapUSDCForWETH(amountIn, minOut)
- getAmountOut(amountIn, reserveIn, reserveOut)
- getLiquidityMinted(wethAmount, usdcAmount)

## LPToken.sol
- mint(to, amount)
- burn(from, amount)
- totalSupply()
- balanceOf(user)



# Flujo de cálculos en AMM - Nivel intermedio

## 1️⃣ addLiquidity(wethAmount, usdcAmount)
- Calcular cantidad de LP tokens a mintear:
  - Si es la **primera liquidez**:
    - `liquidityMinted = sqrt(wethAmount * usdcAmount)`
  - Si hay liquidez existente:
    - `liquidityMinted = min(
        (wethAmount * totalLiquidity) / reserveWETH,
        (usdcAmount * totalLiquidity) / reserveUSDC
      )`
- Actualizar reservas:
  - `reserveWETH += wethAmount`
  - `reserveUSDC += usdcAmount`
- Actualizar liquidez del usuario y total

---

## 2️⃣ swapWETHForUSDC(amountIn, minOut)
- Aplicar fórmula constante-producto:
  - `amountInWithFee = amountIn * (1 - fee%)`
  - `amountOut = (amountInWithFee * reserveUSDC) / (reserveWETH + amountInWithFee)`
- Verificar que `amountOut >= minOut`
- Actualizar reservas:
  - `reserveWETH += amountIn`
  - `reserveUSDC -= amountOut`

---

## 3️⃣ swapUSDCForWETH(amountIn, minOut)
- Simétrico al anterior:
  - `amountInWithFee = amountIn * (1 - fee%)`
  - `amountOut = (amountInWithFee * reserveWETH) / (reserveUSDC + amountInWithFee)`
- Verificar que `amountOut >= minOut`
- Actualizar reservas:
  - `reserveUSDC += amountIn`
  - `reserveWETH -= amountOut`

---

## 4️⃣ removeLiquidity(lpAmount)
- Calcular proporción del pool:
  - `amountWETH = (lpAmount * reserveWETH) / totalLiquidity`
  - `amountUSDC = (lpAmount * reserveUSDC) / totalLiquidity`
- Actualizar reservas:
  - `reserveWETH -= amountWETH`
  - `reserveUSDC -= amountUSDC`
- Actualizar liquidez del usuario y total
