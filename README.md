## PoolTogether V3 to V5 Adapter

The V3 to V5 Adapter wraps a PoolTogether V5 Prize Pool as a PoolTogether V5 Liquidation Source. This allows us to connect V3 prize pools to PoolTogether V5.

The adapter implements the V3 Prize Strategy interface and the V5 Liquidation Source interface.

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
