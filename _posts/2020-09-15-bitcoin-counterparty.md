---
title: "Is Bitcoin's lack of counterparty risk just a micro-optimization?"
layout: post
summary: Yeah, cheap riskless settlement is cool and all, but does it matter?
meta_image: /images/2020-dollar-verification.jpg
---

As more and more talk grows of the dollar getting displaced as the almighty global
reserve settlement asset, gold fans tend to point out that the commodity is a natural
candidate for another go-round in this spot because of its lack of counterparty risk.

<img width='80%' style='margin-top: 2em; margin-bottom: 2em;' src='/images/2020-dollar-risk.png'  />

Most financial assets have associated counterparty risks. Stocks you "own" are subject
to the risk that the exchange on which you purchased them may, willingly or not, take
them from you; or the risk that whatever legal jurisdiction you're under ceases to
associate the ownership of a share with some fraction of the company. 

Bonds come with the risk that the issuer may not remain solvent and will default. US
dollars come, to the surprise of almost no one these days, with the risk that there is
no natural scarcity associated with their creation aside from the good will of the US
govenrment, and their use may be subject to sanctions. With tidal-wave-sized deficits
in our present and almost certainly in our future, that former risk (devaluation)
becomes a very real one.

Physical gold doesn't really have counterparty risk. If you have it, you have it;
you're not relying on the expectation that anyone else is going to do anything (other
than buy it at some point). Someone could take it from you, but that's about it. For
this reason, people who like gold often argue that makes it the premier candidate for a
global reserve asset - central banks who hold gold don't have to worry about some
exogenuous risk like inflation or default. 

But the problem is that physical gold is very hard to transport and verify. Settlement
is a real [pain in the
ass](https://www.washingtonpost.com/news/worldviews/wp/2018/03/15/a-planes-door-flew-open-during-takeoff-raining-gold-and-silver-over-16-miles-of-siberia/).
Getting it shipped is not cheap; here's some guy on [Quora](https://www.quora.com/How-much-does-it-cost-to-buy-and-ship-one-metric-ton-of-gold-bullion-from-London-England-to-Soap-Lake-Washington-USA-What-kinds-of-metrics-do-you-need-to-have-to-make-something-like-that-happen/answer/Neville-Bergin)
talking about what it takes to buy and ship a ton of gold:

> So you have a lazy $48 to $50 million lying around, do you?
>
> [Y]our 1 tonne is going to cost you $47,961,360.
> 
> That much gold is a huge security risk, so you will need to talk with someone like
> Brinks to securely transport it from London to Soap Lake. If they used a regular
> carrier such as Virgin Atlantic the freight cost might only be about $1750, but the
> security could add ten times that. Of course, a regular carrier might refuse to carry
> it, given the security risk so your only choice might be to hire a jet to transport
> your hoard.
> 
> Also, you will need to consider insurance; if it is available, which might be around
> $1.4 million assuming around 3% of value?
> 
> And once you have it at Soap Lake, you will need to store it securely, so either you
> have built a secure vault on your property, with a highly sophisticated security system
> or you will need to pay someone to store it for you. 

So suffice to say if you're talking about transporting millions of dollars in gold,
you're talking about millions of dollars in transport cost.

Gold also has to be physically inspected for its integrity, which is a fairly costly
process requiring thousands of dollars in equipment.
 
<img width='70%' src='/images/2020-gold-verification.jpg'  />
<div class='caption'>
Every breakroom needs one of these babies!
</div>
  
So if gold *did* become the world's reserve asset, there'd be a big need to perform
settlement pretty regularly. But because it's such a pain to transport, odds are that
that settlement would have to be batched. Which means that for some time, the
unreconciled total of your gold is sitting as a liability on someone else's balance
sheet. Which brings us right back to counterparty risk! Rats!

So this is where the Bitcoin people chime in -- I probably don't have to tell you what's
coming next.

Bitcoin, like gold, is a bearer asset. There's no counterparty risk (aside from the
cryptography breaking - which seems roughly on par with the likelihood that we'll
figure out how to synthesize gold or start mining asteroids). 

Your 1 tonne of gold, or $47,961,360, can be [(and has
been)](https://cointelegraph.com/news/bitfinex-made-a-11-billion-btc-transaction-for-only-068)
transmitted on the Bitcoin network with final settlement
within a few hours. Okay, if you're ultra conservative and you want to wait 100 blocks,
it'll take 16 hours. But the point is that for a few bucks, you can perform the same
sort of "physical" reconciliation with Bitcoin that would cost millions with gold. This
seems like a pretty big deal, and is a big selling point for Bitcoin getting adopted as
the global reserve asset at some point way off in the future. True relief from
counterparty risk with no compromise in transmission convenience; quite the opposite!

Now realistically if you're a central bank and you want to settle Bitcoin, it isn't
just going to cost a few bucks. You're going to hire engineers to vet and operate the
software necessary to do settlement in an actually-trust-minimized way. So you're
paying a few guys a few hundred thousand dollars a year to sit around and refresh
Electrum wallets.

But even so, it seems like at least an order of magnitude savings over gold.

Hang on though. If we're talking about reconciliation between central banks, we're
talking about giant flows. The US did [an estimated
$737B](https://ustr.gov/countries-regions/china-mongolia-taiwan/peoples-republic-china#:~:text=U.S.%2DChina%20Trade%20Facts,was%20%24378.6%20billion%20in%202018.)
with China in 2018. That might dwarf a few million here and there to deal with tossing
some gold around for settlement. And besides, is counterparty risk really such a big
deal from one central bank to another? If you're dealing in something like gold that
can't be virtually diluted, refusal to furnish payment would essentially be an act of
war -- what's the realistic likelihood of that happening?  (ah no of course I wasn't
talking about [*you*, Mr. Nixon...](https://en.wikipedia.org/wiki/Nixon_shock))

So maybe the realized cost of counterparty risk when it comes to gold is fairly low?

Central banks and giant commercial operations probably *can* afford to go through the
trouble of transporting and verifying gold for settlement, even if it is more expensive
than they might like. So does that make Bitcoin's claimed efficiency on settlement just
a superficial little [premature
optimization](https://wiki.c2.com/?PrematureOptimization)?

Maybe from their standpoint. The thing is, international trade isn't just performed by
central banks and giant companies (or shouldn't be, anyway). If I want to buy a small
run of keyboard switches from a vendor in Taiwan, I'm *not* going to send over half an
ounce of gold. On the other hand, it's very practical to do the same with Bitcoin. If
I'm a hedge fund in London that wants to buy Russian oil futures, I'm not going to
Fedex a bar or two over, ...  you can see where this is going.

Bitcoin's granularity, transportability, and quick settlement relative to gold enable
small (and not so small) entities to conduct trade in a *practical* way using a reserve
asset without counterparty risk. It allows point-to-point international trade without
any foreign exchange risk.

I'd say that isn't just a premature optimization.


<div style='margin-top: 4em;' />

---

Follow me [@jamesob](https://twitter.com/jamesob), or join [the
bearhaus](https://bearhaus.substack.com/) for periodic writings on macro.
