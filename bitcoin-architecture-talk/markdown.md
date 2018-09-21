
class: center, middle

# Bitcoin Core architecture overview
### Dev++ 2018
### jamesob, Chaincode Labs

---

# Agenda

0. General introduction
0. User interfaces
0. Storage
0. Data structures
0. Initialization and concurrency model
0. Regions
0. Libs
0. Examples
   - Accepting a new block
   - Mining a block
   - Constructing a transaction
   - Looking up a transaction (`getrawtransaction`)
   - Building and maintaining a transaction index (`txindex`)
0. Future work

---

# Introduction

Bitcoin Core serves a number of uses:

- A validating relay node in the peer-to-peer network
  - Blocks (chainstate) and transactions (mempool)

- A canonical wallet implementation
  - A tool for end-users
  - A working example for wallet implementers (e.g. coin selection)

- Block assembly for miners

- A programmatic interface for Bitcoin applications
  - RPC via HTTP

---

### Introduction

In this talk, we will discuss the structure of the Bitcoin Core software and
how it accomplishes these uses, including

- storage: how do we store and access data on disk?

- data structures: how is data represented and manipulated in memory?

- regions: what are the major subsystems?

- concurrency model: how do we do multiple things simultaneously?

- libs: what are the stateless libraries we use?

---

### Introduction

I'm going to gloss over:

- Any and all cryptographic implementations

- Details of P2P message protocol

- Graphical code (`qt/`)

- Test framework (`test/`)

- Exact validation semantics

...or basically any other conceptual detail in Bitcoin.

This is purely about the organization and mechanism of code and a few
important data structures.

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
  DNS seeds

- DoS protection is implemented to prevent malicious peers from disrupting the
  network
  - `-banscore=<n>` configures sensitivity, defaults to `100`

- SPV (simple payment verification) nodes retrieve txout proofs

---

### User interfaces > RPC/HTTP

- A remote procedure call (RPC) interface allows users to programmatically
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

#


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

- Defined in:
- Used in:

---

### Data structures > chainstate > `CBlockLocator`

- Defined in:
- Used in:

---

### Data structures > mempool > `CTxMempool`

- Defined in:
- Used in:

---

### Data structures > p2p > `NetMsgType`

- Defined in: src/protochol.h
- Used in:

---

### Data structures > p2p > `CNode`

- Defined in:
- Used in:

---

### Data structures > p2p > `CAddrMan`

- Defined in:
- Used in:

---

### Data structures > p2p > `CConman`

- Defined in:
- Used in:

---

### Data structures > validation > `CSignatureCache`

- Defined in:
- Used in:

---

# Initialization and concurrency model

---

## Initialization and concurrency model

- Bitcoin Core performs a number of tasks simultaneously
- It has a model of concurrent execution to support this


---


### Initialization and concurrency model > `init.cpp`

1. `AppInitBasicSetup()`: Register SIGTERM/INT handler, Windows-specific networking config
   - Handler sets `fShutdownRequested = true`
     - grep `ShutdownRequested()` for details
2. `AppInitParameterInteraction()`: ensure CLI parameters make sense
   - See `ArgsManager gArgs`
3. `AppInitSanityChecks()`: crypto sanity checks, lock datadir
4. `AppInitMain()`:
   - Set up `signatureCache`, `scriptExecutionCache`
   - Spawn script verification threads (`ThreadScriptCheck`)
   - Start the `CScheduler scheduler` service loop
   - Register RPC commands
   - `AppInitServers()`: start RPC-HTTP server.
   - Register ZMQ validation interface.

???

---

### Initialization and concurrency model > `qt/bitcoin.cpp`

---

### Initialization and concurrency model > threading

- CScheduler

---

### Flow control > `ValidationInterface`

---

### Locks


- `CCriticalSection`
- `cs_main`
- `cs_vNodes`
- `cs_wallet`

---


class: center, middle

# Regions

---

## Regions

---

### Regions > `validation.{h,cpp}`

---

### Regions > `net_processing.{h,cpp}`

---

### Regions > `net.{h,cpp}`

---

### Regions > `txmempool.{h,cpp}`

---

### Regions > `script/`


---

### Regions > `consensus/`

---

### Regions > `policy/`

---

### Regions > `interfaces/`

---

### Regions > `indexes/`

---

### Regions > `wallet/`

---

### Regions > `qt/`

---

### Regions > `rpc/`

---

### Regions > `zmq/`

---

class: center, middle

# Libs

---



class: center, middle

# Examples

---


class: center, middle

# Future work

---
