
class: center, middle

# Bitcoin Core architecture overview
### Dev++ 2018
### jamesob, Chaincode Labs

---

# Agenda

0. General introduction
0. User interfaces
0. Concurrency model
0. Regions
0. Storage
0. Data structures
0. Future work

<!--
0. Libs
0. Examples
   - Accepting a new block
   - Mining a block
   - Constructing a transaction
   - Looking up a transaction (`getrawtransaction`)
   - Building and maintaining a transaction index (`txindex`)
0. Future work
-->

---

# Introduction

Bitcoin Core serves a number of uses:

- A validating relay node in the peer-to-peer network
  - Blocks (chainstate) and transactions (mempool)

- A canonical wallet implementation
  - A tool for end-users
  - A working example for wallet implementers (e.g. coin selection)

- Block assembly and submission for miners

- A programmatic interface for Bitcoin applications
  - RPC via HTTP, CLI

---

### Introduction

In this talk, we will discuss the structure of the Bitcoin Core software and
how it accomplishes these uses, including

- concurrency model: how do we do multiple things simultaneously?

- regions: what are the major subsystems?

- storage: how do we store and access data on disk?

- data structures: how is data represented and manipulated in memory?

---

### Introduction

I'm going to gloss over:

- Any and all cryptographic implementations

- Details of P2P message protocol

- Graphical code (`qt/`)

- Test framework (`test/`)

- Exact validation semantics

...or basically anything really detailed.

This is purely about the organization and mechanism of code and a few
important data structures.

---

### Introduction

I've probably forgotten a few things, so feel free to shout out or ask
questions.

---

class: center, middle

# User interfaces

---

## User interfaces

Before jumping into the structure of the software itself, let's talk about
the user interfaces that Bitcoin provides.

---

### User interfaces > P2P

- Bitcoin forms a TCP overlay network of nodes passing messages to one another
  - Messages defined in `src/protocol.h`

- Each node has a set of outbound and inbound peers they exchange data with
  - `-addnode=<addr>`
  - `-maxconnections=<n>`
  - `net.h MAX_OUTBOUND_CONNECTIONS, DEFAULT_MAX_PEER_CONNECTIONS`

- Peers can be manually added (`-addnode`) or are discovered randomly from
  DNS seeds: DNS servers that randomly resolve to known Bitcoin nodes

- DoS protection is implemented to prevent malicious peers from disrupting the
  network
  - `-banscore=<n>` configures sensitivity, defaults to `100`

- SPV (simple payment verification) nodes retrieve txout proofs

---

### User interfaces > RPC/HTTP

A remote procedure call (RPC) interface allows users to programmatically
interact with Bitcoin Core over HTTP

- Block explorers can query blockchain and mempool data

- External wallets can construct and sign transactions

- Miners and pool operators use `getblocktemplate` for block construction

- `bitcoin-cli` provides a way to access this interface on the commandline

---

### User interfaces > Qt

The Qt interface reveals

- wallet functionality
- basic network statistics
- RPC console



- TODO: screenshots

---

### User interfaces > ZMQ

The ZMQ interface publishes notfications over a socket upon receipt of a

- new block (raw): `rawblock`
- new block (hash): `hashblock`
- new transaction (raw): `rawtx`
- new transaction (hash): `hashtx`

which allows external software to perform some action on these events:



```python
# From `contrib/zmq/zmq_sub.py`

zmqSubSocket = self.zmqContext.socket(zmq.SUB)
zmqSubSocket.setsockopt_string(zmq.SUBSCRIBE, "hashblock")
msg = await zmqSubSocket.recv_multipart()
topic, body, *_ = msg

if topic == b"hashblock":
    print('saw hashblock')
    print(binascii.hexlify(body))
```

See also: `-blocknotify=<cmd_str %s>`

---

class: center, middle

# Concurrency model

---

## Concurrency model

- Bitcoin Core performs a number of tasks simultaneously
- It has a model of concurrent execution to support this based on
  `{std,boost}::threads`, shared state, and a number of locks.

---

### Concurrency model > threads

| Purpose                 | # | Task run           |
| :---------------------- | ----------------: | :-------------------- |
| Script verification | `min(nproc, 16))`*   | `ThreadScriptCheck()` |
| Loading blocks  | 1   | `ThreadImport()` |
| Servicing RPC calls | 4*| `ThreadHTTP()` |
| Load peer addresses from DNS seeds | 1 | `ThreadDNSAddressSeed()` |
| Send and receive messages to and from peers     | 1 | `ThreadSocketHandler()` |
| Initializing network connections | 1 | `ThreadOpenConnections()` |
| Opening added network connections | 1 | `ThreadOpenAddedConnections()` |
| Process messages from `net` -> `net_processing` | 1 | `ThreadMessageHandler()` |
| Tor control | 1 | `TorControlThread()` |
| Wallet notify (`-walletnotify`) | 1 | user-specified |

* can be overridden

???

- Uses `select` which creates file descriptor related limitations

TODO: what does loading blocks do?
TODO: research select poll


---

### Concurrency model > threads (continued)


| Purpose                 | # | Task run           |
| :---------------------- | ----------------: | :-------------------- |
| txindex building | 1   | `ThreadSync()` |
| Block notify (`-blocknotify`) | 1   | user-specified |
| Upnp connectivity | 1   | ThreadMapPort |
| `CScheduler` service queue | 1   | `CScheduler::serviceQueue()` |
| (powers `ValidationInterface`) |     |  |

???

- TODO: understand Unpn better

---

### Concurrency model > `ValidationInterface`

Allows the asynchronous decoupling of chainstate events from various
responses.

Uses `SingleThreadedSchedulerClient` to queue responses and execute them
out-of-band w.r.t. things like network communications, though still often
blocked on lock acquisition, e.g. `cs_main`.

Used (subclassed) for many things:
- Index building (`src/index/bash.h:BaseIndex`)
- Messaging with peers (`net_processing:PeerLogicValidation`)
- Trigger wallet updates (`wallet/wallet.h:CWallet`)
- Sending ZMQ publications (`CZMQNotificationInterface`)


???

TODO: understand the PeerLogicValidation bit better

---


### Locks


- `CCriticalSection`: a named, recursive mutual-exclusion lock.
- `cs_main`: guards basically everything.
- `cs_vNodes`: guards P2P peer state.
- `cs_wallet`: guards wallet state.

---

class: center, middle

# Regions

---

## Regions

"Regions" of code (in my terms) consist of state and procedures necessary for
Bitcoin's operation.

Each region is a subsystem within Bitcoin Core that handles a certain
domain of tasks at a certain layer of abstraction.

Starting here will give us a high-level but specified sense of
which parts of the system do what tasks.

---

### Regions > `net.{h,cpp}`

`net` is the "bottom" of the Bitcoin core stack. It handles network
communication with the P2P network.

It contains addresses and statistics (`CNodeStats`) for peers (`CNode`s) that
the running node is aware of.

`CConman` is the main class in this region - it manages socket connections (and
network interaction more generally) for each peer, and forwards messages to the
`net_processing` region (via `CConman::ThreadMessageHandler`).

The globally-accessible `CConman` instance is called `g_conman`.

???

- Point out the naming convention: `g_` for globals.

---

### Regions > `net_processing.{h,cpp}`

`net_processing` adapts the network layer to the chainstate validation layer.
It translates network messages into calls for local state changes.

"Validation"-specific (i.e. information relating to chainstate) data is
maintained per-node using `CNodeState` instances.

Much of this region is `ProcessMessage()`: a giant conditional for rendering
particular network message types to calls deeper into Bitcoin, e.g.

- `NetMsgType::BLOCK` -> `validation:ProcessNewBlock()`
- `NetMsgType::HEADERS` -> `validation:ProcessNewBlockHeaders()`
- ...

Peers are also penalized here based on the network messages they send
(see `Misbehaving` and its usages).

???

- TODO: mapOrphanTransactions
- TODO: discuss threading, can node messages be processed simultaneously?

---

### Regions > `validation.{h,cpp}`

`validation` handles modifying in-memory data structures for chainstate and
transactions (mempool) on the basis of certain acceptance rules.

It both defines some of these data structures (`CChainState`, `mapBlockIndex`)
as well as procedures for validating them, e.g. `CheckBlock()`.

Oddly, it also contains some utility functions for marshalling data to and from
disk, e.g. `ReadBlockFromDisk()`, `FlushStateToDisk()`, `{Dump,Load}Mempool()`.
This is probably because `validation.{h,cpp}` is the result of refactoring
`main.{h,cpp}` into smaller pieces.

It contains the instantiation of the infamous `cs_main` lock, which we'll
talk more about later.

---

### Regions > `txmempool.{h,cpp}`

`txmempool` provides a definition for the in-memory data structure that manages
the set of transactions this node has seen, `CTxMempool`.

This data structure provides a helpful view of transactions sorted in various
ways (e.g. by fee rate, txid, entry time, fee rate with ancestors). See
`CTxMempool::indexed_transaction_set`.

The mempool is a fixed size, so eviction logic is defined here too.

An index of the UTXO set which includes unconfirmed mempool transactions
is also defined here (`CCoinsViewMemPool`).

This region is used in `validation`. `src/policy` (fee estimation), `miner`,
and others.

---

### Regions > `script/`

The `script` subtree contains procedures for defining and executing Bitcoin
scripts, as well as signing transactions (`script/sign.*`).

It also maintains data structures which cache script execution and signature
verification (`script/sigcache.*`).

Script evaluation happens in `script/interpreter.cpp::EvalScript()`.


---

### Regions > `consensus/`

Contains procedures for obviously consensus-critical actions like computing
Merkle trees, checking transaction validity.

Contains chain validation parameters, e.g. `Params::BIP66Height,
nMinimumChainWork`.

Defines BIP9 deployment description struct
(`consensus/params.h:BIP9Deployment`).

`CValidationState` is defined in `consensus/validation.h` and is used broadly
(but mostly in `validation`) as a small piece of state that tracks validity
and likelihood of DoS when examining blocks.

---

### Regions > `policy/`

Policy contains logic for making various assessments about transactions (does
this tx signal replace-by-fee?).

It contains logic for doing fee estimation (`policy/fees.*`).

---

### Regions > `interfaces/`

Defines interfaces for interacting with the major subsystems in Bitcoin:
node, wallet, GUI (eventually).

This is part of an ongoing effort by Russ Yanofsky to decompose the different
parts of Bitcoin into separate systems that communicate using more formalized
messages.

Eventually, we might be able to break Bitcoin Core into a few smaller
repositories which can be maintained at different cadences.

---

### Regions > `indexes/`

Contains optional indexes and a generic base class for adding more.

Currently only one index: `indexes/txindex` which provides a mapping of
transaction ID to the `CDiskTxPos` for that transaction.

More indexes proposed, e.g. address to any related transactions.

???

- TODO: link to Marcin's PR

---

### Regions > `wallet/`

Contains

- logic for marshalling wallet data to and from disk via BerkeleyDB.
- utilities for fee-bumping transactions.
- doing coin selection.
- RPC interface for the wallet.
- bookkeeping for wallet owners (`CWalletTx`, address book) .

---

### Regions > `qt/`

Contains all the code for doing the graphical user interface.

`qt/bitcoin.cpp:main()` is an alternate entrypoint for starting Bitcoin.

---

### Regions > `rpc/`

Defines RPC interface and provides related utilities (`UniValue` mangling).

---

### Regions > `miner.{h,cpp}`

Includes utilities for generating blocks to be mined (e.g. `BlockAssembler`).
Used in conjunction with `rpc/mining.cpp` by miners:

- `getblocktemplate`
- `submitblock`

---

### Regions > `zmq/`

Registers events with `ValidationInterface` to forward on notifications about
new blocks and transactions to ZMQ sockets.

---

class: center, middle

# Let's talk about data structures

---

class: center, middle

# Storage

---

## Storage > `.dat` files

Bitcoin stores some data in `.dat` files, which are just the raw bytes of
some serialized data structure.

---

## Storage > `.dat` files

- `blocks/blk?????.dat`: serialized block data
    - `validation.cpp:WriteBlockToDisk()`
    - `src/primitives/block.h:CBlock::SerializationOp()`

--

- `blocks/rev?????.dat`: "undo" data -- UTXOs added and removed by a block
    - `validation.cpp:UndoWriteToDisk()`
    - `src/undo.h:CTxUndo`

--

- `mempool.dat`: serialized list of mempool contents
    - `src/txmempool.cpp:CTxMemPool::infoAll()`
    - Dumped in `src/init.cpp:Shutdown()`

--

- `peers.dat`: serialized peers
    - `src/addrmah.h::CAddrMan::Serialize()`

--

- `banlist.dat`: banned node IPs/subnets
    - See `src/addrdb.cpp` for serialization details

---

## Storage > leveldb

Leveldb is a fast, sorted key value store used for a few things in Bitcoin.

It allows bulk writes and snapshots.

It is bundled with the source tree in `src/leveldb/` and maintained in
[`bitcoin-core/leveldb`](https://github.com/bitcoin-core/leveldb).

???

Pieter on BDB -> LBD: https://bitcoin.stackexchange.com/a/51446

---

## Storage > leveldb

- `blocks/index`: the complete tree of valid(ish) blocks the node has seen
  - Serializes `mapBlockIndex`, or a list of `CBlockIndex`es
  - `CBlockIndex` is a block header plus some important metadata, for example validation
    status of the block (`nStatus`) and position on disk (`nFile`/`nDataPos`)

--

- `chainstate/`: holds UTXO set
  - `COutPoint` -> `CCoinsCacheEntry`
      - Basically `(txid, index) -> Coin` (i.e. [CTxOut, is_coinbase, height])
  - `CCoinsViewCache::BatchWrite()`

--

#### Important class
- `CDBWrapper` (`src/dbwrapper*`)
  - Abstracts away leveldb API

???

- Confusing that blocks/index holds, basically, the state of the chain but
  we call the index of unspent outputs "chainstate." Kind of a misnomer.

Chainstate: CCoinsViewCache

---

## Storage > berkeleydb

BerkeleyDB is basically like leveldb but
[worse](https://bitcoin.stackexchange.com/a/51446).

We still use it for the wallet.

Some want to replace it with SQLite.

---

## Storage > berkeleydb

- Wallet
  - `wallets/wallet.dat`: BerkeleyDB wallet file
      - `src/wallet/db.cpp`

---

class: center, middle

# Data structures

---

# Data structures

The storage formats we just covered are deserialized into in-memory
data structures during runtime.

Here are a few of the important ones.

---

### Data structures > chainstate > blocks

##### `src/primitives/block.h:CBlockHeader`

The block header attributes you know and love: `nVersion, hashPrevBlock,
hashMerkleRoot, nTime, nBits, nNonce`.

--

##### `src/primitives/block.h:CBlock`

It's `CBlockHeader`, but with transactions attached.

--

##### `src/primitives/block.h:CBlockLocator`

A list of <32 block hashes starting with a given block and going back through
a chain in sort-of logarithmic distribution.

Used to quickly find the divergence point between two tips.

Construction logic lives in [`src/chain.cpp:CChain::GetLocator()`]().

???

- Clarify that everyone knows what a tip is.

---

### Data structures > chainstate > blocks (continued)

##### `src/chain.h:CBlockIndex`

A block header plus some important metadata, for example validation
status of the block (`nStatus`) and position on disk (`nFile`/`nDataPos`)

The entire blockchain (and orphaned, invalid parts of the tree) is stored
this way.

---

### Data structures > chainstate > UTXOs

##### `src/chain.h:CCoinsView`

This manages an iterable view of all unspent coins.

It is an abstract base class that provides a lookup from `COutPoint` (txid and txout
index) to the `Coin` (`CTxOut`, `is_coinbase`, `nHeight`).

It is subclassed by `src/txdb.h:CCoinsViewDB` to provide access to on-disk
UTXO data (`datadir/chainstate/*.ldb`).

It is also subclassed by `CCoinsViewBacked`, which in turn is subclassed by
`CCoinsViewCache` (an in-memory view of the UTXO set) and
`src/txmempool.cpp:CCoinsViewMemPool`.


---

### Data structures > chainstate > `CChainState`

Defined in `validation`. Contains logic and storage for maintaining the
`activeChain`, the most-work valid chain.

`mapBlockIndex` is an attribute.

Makes liberal use of `cs_main`.

`ActivateBestChain{Step}()` contains logic for incorporating new blocks and
setting the most-work chain.

`AddToBlockIndex()` incorporates all block headers encountered.

???

TODO: all _valid_ block headers encountered?

<!-- TODO:
NetMsgType
CNode
CAddrMan
CConman
CSignatureCache
-->

---

### Future work

- [#12934: Call ProcessNewBlock()
  asynchronously](https://github.com/bitcoin/bitcoin/pull/12934) by @skeees
- [#10973: Refactor: separate wallet from
  node](https://github.com/bitcoin/bitcoin/pull/10973) by @ryanofsky
