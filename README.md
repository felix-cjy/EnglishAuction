## Bounty

DODO 为去中心化交易所,主动式做市商(PMM)算法
https://docs.dodoex.io/zh/home/what-is-dodo

PMM 算法是基于传统金融中使用的集中式限价单簿模型的衍生品，由 DODO 团队开发而来。

集中式限价单簿模型是现代金融市场基础设施的核心部分之一，它不仅提高了市场的流动性，还促进了市场价格发现的过程。此外，随着技术的发展，许多交易所和交易平台已经实现了订单簿的电子化和自动化，使得交易更加高效和透明。

提高了市场的流动性，还促进了市场价格发现的过程。此外，随着技术的发展，许多交易所和交易平台已经实现了订单簿的电子化和自动化，使得交易更加高效和透明。

PMM 算法通过调整资产的价格曲线，以确保在最新的市场价格下有充足的流动性。
例如，当某个资产的供应量减少时，PMM 算法会自动提高该资产的市场价格，以预期从市场上购回缺失的库存。

PMM 模型结合了市场做市商和流动性池的优点，旨在降低交易滑点并提高市场深度。
优化了流动性分布，减少了用户交易时的成本.

DODO X 是去中心化金融领域的尖端解决方案，既是一个超级聚合器，又是一个跨链交易平台。
DODO X 致力于提供终极的交易体验，不仅包括最优价格，还包括高链上成功率、流畅的用户体验和方便的操作.

提供了 Trading API 和 Swap Widget 开发者工具，允许任何协议将 DODO X 的所有功能快速集成到其产品中。

在您的应用程序中直接交换代币
Swap Widget 交易小部件
● 最佳价格
● 跨链支持
● 收入分享
● 简单无缝集成
● 绩效分析

Trading API 交易接口
● 智能交易路径
● Web3 数据
● 限价订单
● 跨链交易
● Widget 配置中心

DODO Bounty 任务
**DODO 公开拍卖**

1. 每个购买者在拍卖期间发送他们的竞标到智能合约。
2. 竞标包括发送资金，以便将购买者与他们的竞标绑定。
3. 如果最高出价被提高，之前的出价者就可以拿回他们的竞标资金。
4. 竞价期结束后，出售人可以手动调用合约，收到他们的收益。
5. \*时间加权出价奖励机制(在拍卖即将结束时，出价者的出价会根据距离拍卖结束的时间权重进行调整。
   例如，在拍卖最后 5 分钟内的出价可以按某个倍数进行加权，使得临近结束的出价会更有竞争力。)
6. \*竞拍冷却机制(为防止竞拍者连续快速出价，可以设置一个竞拍冷却期。
   每个出价者在一次出价后，需要等待一段时间后才能再次出价，让拍卖过程更具策略性。)
7. \*拍卖终局延长(如果在拍卖快要结束的最后几分钟内有人出价，则拍卖时间会自动延长一定的时间(例如 5 分钟)，
   避免"最后一秒出价"的情况，并让竞拍更加激烈。
   除了 1,2,3,4 基础拍卖功能外，还需要从 6,7,8 三个附加功能中选择任意一个实现。

**Morph**

zkEVM Layer2
Layer2 通常为两类,OP Rollip 或 ZK Rollup
OP(乐观) 是由外部验证人节点来确保交易的最终确认
ZK(零知识) 是生成 ZK Proof 来确保交易的最终确认.

课程: 构建一个碎片化房地产交易平台
实战搭建一个去中心化订票平台.

**Arbitrum**
以太坊最大规模的扩容方案.
快速,便宜,安全,兼容

赏金任务:

- 基于可重试票据建立应用程序
  可重试票据是跨链消息系统中的工具.允许处理消息传递中的失败情况.如 gas 不足等问题. 消息失败时, 它们可以被保存并再未来的 7 天内重新执行.票据第一次会自动赎回.如果执行成功,票据将被销毁.如果因为某些原因失败,票据将被加入重试区,用户可自行重新执行该票据. 任务是利用这种技术创建一个应用程序,展示如何处理消息传递中可能出现的问题,并保证系统的可靠性和稳定性.
- 开发需要高计算资源的 Dapps
  需要大量计算资源或计算复杂的 dapp

**ETH Panda**
创立不久的华语建设者网络

- 赛题：
  1.Morph：
  基于我们提供的指南开发一个基于 Morph 的去中心化酒店预定 app
  https://morph.ghost.io/developer-guide-building-a-decentralized-hotel-booking-system-on-morph-2/
  2.DoDo：公开拍卖
  每个购买者在拍卖期间发送他们的竞标到智能合约。 竞标包括发送资金，以便将购买者与他们的竞标绑定。 如果最高出价被提高，之前的出价者就可以拿回他们的竞标资金。 竞价期结束后，出售人可以手动调用合约，收到他们的收益。
  3.Arbitrum(二选一)：
  1）Orbit：Build application based on retryable ticket
  2）Stylus: Any dapps that require high computational usage
  Orbit：基于可重试票证构建应用程序
  Stylus：任何需要高计算使用量的 dapp
- 每个赛道$450 奖金池

## 集中式限价单簿模型（Centralized Limit Order Book, CLOB）

集中式限价单簿模型（Centralized Limit Order Book, CLOB）是传统金融市场中的一种交易机制，它主要用于股票、期货、期权等金融产品的买卖撮合。这种模型的核心是一个由市场参与者提交的买卖订单组成的电子簿记系统，系统按照价格优先和时间优先的原则来匹配买卖双方的订单。

### 集中式限价单簿的关键特点包括：

1. **订单簿**：

   - **买盘（Bid）**：表示投资者愿意以某个价格买入一定数量的资产。
   - **卖盘（Ask/Offer）**：表示投资者愿意以某个价格卖出一定数量的资产。
   - 订单簿会列出所有未成交的限价订单，每个价位都有一个最高买价（最佳买盘）和一个最低卖价（最佳卖盘），两者之间的差额被称为“买卖价差”（bid-ask spread）。

2. **撮合规则**：

   - **价格优先**：在相同方向的订单中，价格更好的订单优先执行。例如，在买盘中，出价最高的订单最先得到满足；在卖盘中，要价最低的订单最先成交。
   - **时间优先**：在价格相同的订单之间，则根据订单进入市场的先后顺序进行匹配。

3. **透明性**：

   - 集中式订单簿通常提供市场深度信息，即不同价位上的订单量，这有助于市场参与者了解当前市场的供求状况，从而做出更明智的交易决策。

4. **效率**：

   - 这种模型能够快速高效地处理大量交易，同时保持市场秩序，减少人为干预。

5. **监管合规**：
   - 在传统金融市场中，CLOB 通常受到严格的监管，确保交易公平公正，并防止市场操纵等违法行为。

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

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

使用 `block.timestamp` 可能被矿工操纵，考虑使用 Chainlink 的 VRF 来获取更安全的时间戳。
