
class: center, middle

# Bitcoin Core architecture overview
### Dev++ 2018
### jamesob, Chaincode Labs

---

# Agenda

0. General introduction
0. User interfaces
0. Initialization and concurrency model
0. Storage
0. Data structures
0. Regions
0. Libs
0. Flow control
0. Locks
0. Examples
   - Accept a new block
   - Mining a block
   - Construct a transaction
   - Looking up a transaction (`getrawtransaction`)
0. Future work

---

# Introduction

```cpp
int yao = 3;
while (yao < 10) {
  yao++;
}
```

---

class: center, middle

# User interfaces

---

### User interfaces > P2P

---

### User interfaces > RPC/HTTP

---

### User interfaces > QT

---

### User interfaces > ZMQ


---

# Initialization and concurrency model

---

### Initialization and concurrency model > `init.cpp`

---

### Initialization and concurrency model > `qt/bitcoin.cpp`

---

### Initialization and concurrency model > threading

- CScheduler


---

class: center, middle

# Storage

---

## Storage > `.dat` files

---

## Storage > leveldb

---

## Storage > berkeleydb

---
 
class: center, middle

# Data structures

---

### Data structures > chainstate > `CCoinsView`

- Defined in:
- Used in:

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

# Flow control

---

 
---

### Flow control > `ValidationInterface`
 
---


   
class: center, middle

# Locks

---
 

class: center, middle

# Examples

---    
  

class: center, middle

# Future work

---     
