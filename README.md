## PoolTogether V3 to V5 Adapter

The V3 to V5 Adapter wraps a PoolTogether V5 Prize Pool as a PoolTogether V5 Liquidation Source. This allows us to connect V3 prize pools to PoolTogether V5.

The adapter implements the V3 Prize Strategy interface and the V5 Liquidation Source interface.

## Deployments

| Chain | Contract | Address |
| ---- | ----- | ------ |
| Ethereum | V3PrizePoolLiquidatorAdapter (V3 USDC prize pool) | [0x1cA3CF8B47B596F2d9b440EdC59542539619bAec](https://etherscan.io/address/0x1cA3CF8B47B596F2d9b440EdC59542539619bAec) |
| Ethereum | V3PrizePoolLiquidatorAdapter (V3 DAI prize pool) | [0x8AB3bA7413b8B0eBa426C8A4696D6232e934D0c8](https://etherscan.io/address/0x8AB3bA7413b8B0eBa426C8A4696D6232e934D0c8) |

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
