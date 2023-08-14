---
title: Thoughts on scaling bitcoin
layout: post
summary: "I talk about my expectation for how Bitcoin might scale to handle billions of users, and some implications for short-to-mid term protocol development."
---

A while ago, AJ published an [underread blogpost](https://www.erisian.com.au/wordpress/2023/06/21/putting-the-b-in-btc) about scaling. I’ll do a hasty job of paraphrasing and say that the main gist is that the way that we might scale to **1 billion** users transacting at about **1 tx/week** (which is checking-account volume, my personal target) is by having about 50,000 kinda-sorted-trusted “sidechains” that bear the brunt of most payment volume.

AJ/I use “sidechains” in a loose sense here to mean anything that allows aggregating bitcoin activity off-chain. If you wanted to be especially coarse you could just call them “bitcoin banks.” Examples of what I mean here are

- a traditional, federated sidechain like Liquid,
  - (you’re trusting a group of signers not to rob you, but in return you get more expressive scripting abilities or confidential assets or faster blocks or some combination of all of them)

- some kind of Chaumian ecash bank like fedimint or cashu,
  - (you’re trusting a federation or maybe even an individual operator not to rob you, and you get some privacy benefits)

- or some yet-to-be-discovered design that isn’t really a sidechain at all, in that it doesn’t hinge on trusting some third party. Instead such a design would rely purely on enforcement via “smart contract” (i.e. bitcoin script) and a magic sprinkle of *time-sensitivity* on the part of its users. This is like a [coin pool](https://coinpool.dev) or something vaguely in the direction of [Ark](https://www.arkpill.me/) (which is itself right now just a vague direction).
  - You could think of this as behaving like the generalization of a lightning channel from 2 parties to `n` parties. It would probably require interactivity across all participants for each payment, but the holy grail would be some design that allows subsets of participants to generate off-chain activity without requiring everyone to sign. (Though I think the latter might not be possible?)
  - For the purposes of this post, this could even be some kind of [ZKP rollup](https://github.com/john-light/validity-rollups/blob/main/validity_rollups_on_bitcoin.md) thing - after all, “fraud proof” and “penalty transaction” seem basically equivalent.
  - We’ll just refer to this thing as “coinpool” for short.

The last option, this hypothetical coinpool thing, seems clearly preferable since it’s not relying on a third party. But it’s still a hypothetical, and then even if it weren’t (as we’ve seen with lightning) there are operational caveats around actually maintaining a working, live presence that understands a layer 2 protocol and is able to validate new activity and not get sybiled etc.

Even relative experts aren’t necessarily able to run networked infrastructure that can lose money if it goes offline. It’s a full-time job, probably for multiple people.

Okay, so to get back on track here: in our projected scaling scenario, we’ve got individual users who are using 3 or 4 of these sidechain-type services that essentially resemble community banks. These “banks” are probably networked with payment channels (or atomic swappability) so that they can handle cross-bank liquidity operations, like doing the equivalent of wire transfers. I.e., I want to pay you, but we’re at different bitcoin banks, so the institutions themselves facilitate some kind of batched settlement over a lightning gateway.

The quiet part out loud here is that by the time 1 billion people want to use bitcoin, the main chain is very expensive to transact on. Note that I say “very expensive” and not “impossibly expensive,” because if individuals lose the ability to take some form of layer 1 physical custody, bitcoin is just gold with less friction: a paper market develops and all the nice properties of bitcoin are diminished, as AJ talks about in his post ([link again](https://www.erisian.com.au/wordpress/2023/06/21/putting-the-b-in-btc)).

Also: part of what keeps these offchain constructions workable is the threat of their depositors somehow interacting with layer 1. Even in the case of some kind of coinpool thing, *the ability to appeal to layer 1 is what makes it all work*. So if L1 is too expensive to appeal to for most people, the coinpool design doesn’t really work. Maybe in poorer regimes, that appeal process happens in some batch to amortize base layer fees over a set of users.

These bank things are incentivized to keep operating (and don’t run away with the money) because (i) they collect fees and (ii?) they may be subject to some kind of local legal jurisdiction. But one of the saving graces here is that the the nature of bitcoin makes it feasible for each customer to also be an auditor.

So one possibility is a situation that prices throwing a transaction on the mainchain at maybe a few hundred bucks -- something many people could afford in case there’s a Big Problem with their “bank” and they need to flee to the mainchain -- but definitely not something that an individual might do every month or even every year.

## How we scale?

I think this is roughly what scaling to a billion people looks like for Bitcoin: a constellation of 50,000 networked “banks,” with (hopefully!) roughly uniform distribution of BTC managed across each bank, and a hub-and-spoke use of a few of those banks at the individual level.

The alternatives? Can’t just raise the blocksize. Distributing the equivalent of the world’s checking account activity over a network of validating nodes just doesn’t allow you to preserve decentralization.

I truly don’t think that your average person is going to manage a lightning node (directional liquidity and uptime are annoying), and the Phoenix model of a semi-trusted LSP that is by definition a kind of friendly sybil still requires pushing around a UTXO, which isn’t workable at the scale of a billion people, although [utreexo](https://bitcoinops.org/en/topics/utreexo/) helps somewhat with this.

Is 50,000-”bank” thing  a compromise away from mainchain ownership? Yes. But mainchain ownership for the entire world -- barring some unforeseen magic, which of course I’m rooting for! -- isn’t in the cards. At least with bitcoin’s technological context, we can have good auditing and custody tools to ensure that fraud is easily detectable and theft is basically impossible.

So, assuming you’re willing to entertain these broad strokes, this architectural target gives us a few hints about bitcoin development in the short- to mid-term.

## Design for exit

Because we’re probably going to see a few dominant second layer  (“bank”) designs emerge, we have to account for correlated failure.

Take for example the [lnd fiasco(s)](https://github.com/btcsuite/btcd/issues/1906) within the last year that could have caused mass channel closures amongst lnd nodes. Once a few workable L2 designs come into common use, the probability of a mass exit event goes up, making this seem like a crucial usecase to plan for.

Because mainchain space is scarce, we need to be able to pack all the exits we can into some timespan of blocks. The way to do this seems to be decoupling the actions “get out” from “actually reclaim your funds” (i.e. create new UTXOs) so that we can facilitate a timely exit for as many participants as possible. This is more or less congestion control, an idea largely pioneered by [Jeremy Rubin](https://rubin.io) during the mid-days of CTV development.

Locking funds for later claim to a prespecified path (or set of paths) should be made as concise as possible so that in times of cataclysm, we can pack in as many exit transactions as possible.

I don’t think it’s possible to get more concise than the bare script
```
<32 byte hash> OP_CHECKTEMPLATEVERIFY
```

It’s worth noting that a P2TR scriptPubKey is the same size (`OP_1 <32 byte pubkey>`), but then actually spending that coin comes with 17vB overhead (= `(34vB (controlblock) + 33vB (CTV script)) / 4`). If you’re trying to fill a block with 2-in-1-out CTV unrolls, this could be about 10% overhead.

The burden of this overhead decreases as you add inputs or outputs of course, so “batch” unrolls for multiple users won’t benefit as much from bare script CTVs. But the most common use-case these days would be lightning channel closes, which are 1-in-2-out.

There are rival proposals to CTV that are more flexible, like OP_TX/OP_TXHASH and others, but in a correlated crisis requiring mass exit from an L2, flexibility isn’t what’s needed - judicious use of the mainchain is. So whether or not OP_TX et al. are good for other things, I think CTV is needed simply because it is the most concise way to articulate exit from a contract on-chain at a time when blockspace might be precious.

## Bomb-proof custody patterns

The other observation that comes to mind is if there are going to be ~50,000 institutions managing large sums of bitcoin each, many of them perhaps managed by federated signers, there need to be relatively straightfoward custodial patterns that let us be pretty sure that theft or loss is out of the question.

It shouldn’t come as a surprise that I think the functionality in [OP_VAULT](https://github.com/jamesob/bips/blob/jamesob-23-02-opvault/bip-0345.mediawiki) is critical to achieve this, because it introduces “reactive security.” As Jameson Lopp [says](https://blog.keys.casa/why-bitcoin-needs-covenants/):

>With the right tools, we can be *reactive* rather than only *proactive* with regard to recovering from key compromises.
>
>Vaults allow for the creation of a new set of game theory. Similar to how you can run watchtowers to look out for a Lightning channel counterparty trying to cheat you, you would be able to run a watchtower to make sure no one has compromised your bitcoin vault. If you find that a compromise has occurred, sweeping the funds to safety is simple enough that you can automate it!
>
> It is my sincere belief that every bitcoin self-custody user and every wallet developer should be salivating over the prospect of user-friendly vault functionality. The ability to "claw back" funds that have been lost due to a compromised security architecture means that bitcoiners can sleep more peacefully at night, knowing that they can be fallible, make mistakes, and not have to suffer from catastrophic loss due to a single oversight.

I think that vaults that are enforced on-chain are probably a necessary part of successfully scaling custody to a large number of collaboratively managed pools of bitcoin. And OP_VAULT seems like the most chainspace-efficient way to do this.

Obviously there are a lot of parameters to be decided -- e.g.
- who manages a watchtower, and how much do they know?
- Highly secure backup keys, social recovery, or some time-decayed composition of both?

and I’m sure others. But I don’t think we can rely on proactive security to get 50,000 entities feeling good about putting a lot of capital on the line in an automated way. Even if you could template out some standard array of HSMs, the supply chain attacks (both from hardware and software) seem too feasible.


## Conclusion

This article is already long enough, and there will probably be subsequent writings from me that either build on this or respond to posts from others using this lens.

I think barring some kind of magical development, which I’m not counting on, the way that we wind up scaling bitcoin to handle checking-account volume is with something on the order of 50,000 entities that manage/risk pools of capital to facilitate payment flows. These entities would be networked, probably with lightning.

It’s important for those of us building layers beneath these entities to give them the tools to do their job safely and efficiently. Among other things I’ve missed (I’m not even touching lightning), this boils down to making concise and quick exit possible when necessary (in response to failures that will likely be correlated) and making every day custodial operations safe and simple.
