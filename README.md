## Self Slashing AVS

This is a simple "Meta-AVS" that allows Operators and AVSs to test out slashing functionality. `SelfSlasher` is an implementation of the `BaseSlasher` from [`eigenlayer-middleware`](https://github.com/Layr-Labs/eigenlayer-middleware) with a single additional function, `selfSlash`, which allows an operator to slash themselves (but no one else) however they wish. A single `operatorSet` with ID 0 assigned to the AVS address below has been instantiated which will accept registrations and deregistrations from any operators, and accepts WETH as sole asset.

## Usage

Use the CLI to allocate and register for the meta-AVS's operator set, and then call `selfSlash` with the 0 ID and `wadToSlash` with however much you'd like to slash yourself. State updates can then be read from the `delegationManager` and the `allocationManager`.

## Deployments

### Holesky

| Name | Proxy | Implementation | 
| -------- | -------- | -------- |
[`SelfSlasher`](https://github.com/Layr-Labs/self-slashing-avs/blob/master/src/SelfSlasher.sol) | n/a| [0x8c5b7ea2a3f83d803b6751623fbe517aa1da148c](https://holesky.etherscan.io/address/0x8c5b7ea2a3f83d803b6751623fbe517aa1da148c) |
[`StrategyBase (WETH)`](https://github.com/Layr-Labs/eigenlayer-contracts/blob/slashing-magnitudes/src/contracts/strategies/StrategyBaseTVLLimits.sol) | [`0x80528D6e9A2BAbFc766965E0E26d5aB08D9CFaF9`](https://holesky.etherscan.io/address/0x80528D6e9A2BAbFc766965E0E26d5aB08D9CFaF9) | [`0x5FdD...3C1e`](https://holesky.etherscan.io/address/0x5FdD6a71a3C88111474C812Ca6d60942d7923C1e) |
| [`DelegationManager`](https://github.com/Layr-Labs/eigenlayer-contracts/blob/slashing-magnitudes/src/contracts/core/DelegationManager.sol) | [`0xA44151489861Fe9e3055d95adC98FbD462B948e7`](https://holesky.etherscan.io/address/0xA44151489861Fe9e3055d95adC98FbD462B948e7) | [`0xDa6F...BF48`](https://holesky.etherscan.io/address/0xDa6F662777aDB5209644cF5cf1A61A2F8a99BF48) |
| [`AllocationManager`](https://github.com/Layr-Labs/eigenlayer-contracts/blob/slashing-magnitudes/src/contracts/core/AllocationManager.sol) | [`0x78469728304326CBc65f8f95FA756B0B73164462`](https://holesky.etherscan.io/address/0x78469728304326CBc65f8f95FA756B0B73164462) | [`0xe03d...4ee2`](https://holesky.etherscan.io/address/0xe03d546ada84b5624b50aa22ff8b87badef44ee2) |
AVS address | n/a | 0x1dB6187b7a44Eb7e5c929aacdC92CBfdB4D1384b |
