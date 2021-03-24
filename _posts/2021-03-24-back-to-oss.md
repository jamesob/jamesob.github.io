---
title: Priorities for the wilderness
layout: post
meta_image: /images/devattention.png
summary: After a year of wandering, I'm coming back to Bitcoin Core full-time. These are my priorities.
---

Even bug aside, the last year has been pretty good dose of whiplash. 

Back in Feb. 2020, I
left my job at Chaincode Labs after two years of mostly working on Bitcoin Core. My
leaving was motivated by a deep compulsion to get away from the density of New York[^5] and
return to my rightful place in the 'burbs... or at least somewhere more 'burblike.

But in all candor I was burnt out on the solitary and ponderous nature of doing opensource work 40 hours a week.
I missed the atta-boys and release rushes of commercial dev. I felt less like a
software engineer and more like a disgruntled PhD student.

Given that city life was wearing me thin, the obvious thing to do was get a job in Tokyo. So
I planned to fly over and work with the team at DG Labs (I love these guys), continuing the
Core work half-time and the other half on commercial Bitcoin stuff. My
flight to Tokyo was set for April.

<blockquote class="twitter-tweet center-element"><p lang="en" dir="ltr">Some news: I&#39;m leaving NYC to move to Tokyo. Still working on Bitcoin (that goes without saying), just doing so at <a href="https://twitter.com/dglab_official?ref_src=twsrc%5Etfw">@dglab_official</a> instead of <a href="https://twitter.com/ChaincodeLabs?ref_src=twsrc%5Etfw">@ChaincodeLabs</a>. <a href="https://t.co/tlmVXoUxrI">pic.twitter.com/tlmVXoUxrI</a></p>&mdash; James O&#39;Beirne (@jamesob) <a href="https://twitter.com/jamesob/status/1224435568840302592?ref_src=twsrc%5Etfw">February 3, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

Needless to say, the flight was canceled. 
11 months later, Japan's borders still aren't open and I have a hell of a lot more 
dry food and elderberry syrup in my basement than I did previously.

When winds shifted, Chaincode graciously gave me my job back as a temp remote employee, and I 
continued some work on performance benchmarking tools for Bitcoin as well as [the assumeutxo project](https://github.com/bitcoin/bitcoin/issues/15605).
But within a few months the siren call of commercial Bitcoin work returned and I took a job
in industry.


<img width='100%' style='margin-top: 2em; margin-bottom: 1em;' src='/images/benchula.png'  />
<div style='margin-bottom: 2em;' class='caption'>
One of the outcomes of the Chaincode extension, <code>benchula</code>. Hopefully at some point this
will be publicly available.
</div>

I believed at the time that my work on Core would be backfilled by somebody. There were
a variety of promising newcomers in the repo who were steadily learning the system and
its many peculiarities. I told myself that *Core Would Be Okay* and that I should focus on
what I thought of the next most important thing for Bitcoin: building deep liquidity.
I told myself, perhaps optimistically, that I could keep up with assumeutxo development 
and Core review in my off-time. 

## Narrator: *he couldn't.*

I went to go work in various neighborhoods of Bitcoin's finance world for a while.
People in this industry are doing difficult, worthwhile things - starting banks,
opening futures markets - and it's all going to help bring liquidity to Bitcoin. Which in
some sense is what this whole thing is all about. These people are doing some very not-fun
work to navigate oceans of red tape, and they deserve a lot of recognition.

But a confluence of things made me rethink how I was spending my time. Early in the year
I read [AJ Towns'
update on Bitcoin development](http://www.erisian.com.au/wordpress/2021/01/07/bitcoin-in-2021) and found myself
nodding along in trepidatious agreement.

> I’m not sure I’m in a growth mindset for Bitcoin this year, rather than a
> consolidation one: consider the BTC price at the start of the past few years: 2016:
> ~$450, 2017: $1000, 2018: $13,000, 2019: $3700, 2020: $8000, 2021: $30,000. Has there
> been a 8x increase in security and robustness during 2016, 2017 and 2018 to match the 8x
> price increase from Jan 2016 to Jan 2019? Yeah, that’s probably fair. 
>
> Has there been another 8x increase in security and robustness during 2019 and 2020 to
> match the 8x price increase there? Maybe. What if you’re thinking of a price target of
> $200,000 or $300,000 sometime soon — doesn’t that require yet another 8x increase in
> security and robustness? Where’s that going to come from? 
> 
> And those 8x factors are multiplicative: if you want something like $250k by December 2021, that’s not a “three-eights-are-24” times increase in robustness over six years (2016 to 2022), it’s an **“eight-cubed-is-512”** times increase in robustness! And your mileage may vary, but I don’t really think Bitcoin’s already 500x more robust than it was five years ago.
> 
> So as excited as I am about taproot and the possibilities that opens up (PTLCs and eventually eltoo on lightning, scriptless scripts and discreet log contracts, privacy preserving proof of reserves, cheap multisig — the list might not be infinite but at least seems computationally intractable), I think I’m now even more of the view that **it’s probably more important to work on things that reinforce the existing foundations, than neat new ideas to change them** than I was this time last year. 


When I left the opensource world for industry, the price was floating around $9,000. Last week
it breached $60,000 and Bitcoin became a trillion dollar asset. As AJ writes, that multiplier
(which works out to 6.66x, ominously) doesn't at least outwardly have a concordant
uptick in scrutiny on the Core repo.

<img width='100%' style='margin-top: 2em; margin-bottom: 1em;' src='/images/devattention.png'  />
<div class='caption'>
Okay ya got me, that's actually just the S&P500.
</div>

I started to grow increasingly concerned about this. Not that anything bad would
necessarily happen with Bitcoin, but that maybe I was focusing myself in the wrong
place. 
It dawned on me that
I've spent nearly six years accumulating context
on this fairly labyrinthine system (Core) that for good reason many engineers find difficult,
undesirable, or intractable to come to grips with.[^1] I certainly don't blame them;
Core has a glamorous brand but working on it for the longterm can be a pretty huge drag given the
wide-open feedback loops and immense scrutiny that changes are (justifiably) subject to.

Nonetheless, it's important -- super important -- that we have a deep bench of people
actively working on and watching the repo. In 2017 Greg Maxwell [said something that stuck with
me](https://youtu.be/EHIuuKCm53o?t=418) 
about the importance of overkilling certain tasks in Bitcoin, in this particular case
block propagation:

> In general, this is a problem that we need to overkill. When we talk about how we spend resources in the community, there's many cases where we can half-ass a solution and that works just fine. It's true for a lot of things. But other things we need to solve well. Then there's a final set of things that we need to nuke from orbit. The reason why I think that block propagation is something that we should overkill is because we can't directly observe its effects. If block propagation is too slow, then it's causing mining centralization, and we won't necessarily see that happening.

<div class='center-element'>
<iframe width="560" height="315" src="https://www.youtube.com/embed/EHIuuKCm53o?t=418" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>

Review and involvement on bitcoind is a similar story. We don't know who's out there
scrutinizing, fuzzing, scanning with the aim of disrupting Bitcoin. What we do know is right
now there are about 68 identities who have 3+ commits in the repo over the past
year[^2]. That actually sounds pretty healthy, but consider that Bitcoin now has a
market cap comparable to Google's. Think about how many people are on Google's
security team; do you think they have more or less than 68 people working internally to 
fortify their system? Probably two orders of magnitude more.

Now okay, this is somewhat of a misleading comparison: 

1. resources devoted to security at bitcoind layer don't necessarily need to
  scale linearly with price, and
2. the surface area of Google's product is quite a bit higher than bitcoind's. 

But directionally the sentiment is right:
we need to build a deep bench and absolutely nuke Core stability from orbit.

So I came to the conclusion that it would be a waste for me to have spent all those
years building experience on Core and then not
put it to use. I'm not the brightest guy in the world; I'm certainly not going to be
credited with in any crypto papers anytime soon. But I can write safe software,
and help test and review this heap. Buckets of skepticism and ideological fervor probably
count for something too. 

Maybe dealing with Core, and all the accompanying isolation
and mundane janitorial work[^3] is just the
most comparative advantaged way that I can contribute to Bitcoin. Given the level of
participation in the Core repo and the pace of review, it certainly seems that
way.

So I left my job in industry. I'm back to opensource full time.

## Priorities

I have a very clear criteria for what I'm going to working on, and it's **things
that improve the likelihood of bitcoind's uninterrupted operation.** 

"Ossification" is a sort of meme, and I get the sense that many people think that
bitcoind has arrived. From the outside, I could see
how people might have this impression, and that's the end goal,
but the reality is that as with so many other things Core's stability
is sort of an arms race between attackers and defenders. I don't care so much about
adding "features" to Core per se[^4] but I want to make sure that the features which are
there keep working, and this entails some change in the code.

### Fuzzing

One obvious line of work that's relevant here is the 
[ongoing fuzzing effort](https://github.com/bitcoin/bitcoin/pulls?q=is%3Apr+is%3Aopen+fuzzing), which
[in layman's
terms](https://bitcoin.stackexchange.com/questions/99955/what-is-fuzz-testing) 
is just reshuffling the code around so that we can make it easier for other
programs to generate massive amounts of random inputs to feed into bitcoind with the
intent of crashing it. If we get a crash, we get a 
potential vulnerability. But sometimes large parts of the code need to change
architecturally for this to be possible. Fuzzing is one thing I'll be focusing on.

### Process separation & AltNet

There are two other projects that I think are critical for fortification. The first is
Russ Yanofsky's long-running process separation project, which has been in progress [for
4 years now](https://github.com/bitcoin/bitcoin/pull/10102) and feels pretty close to
being in a usable state. In brief, this project
moves bitcoind from running as a single monolithic process, where a failure in any part
of the code can halt execution, to multiple processes with a higher degree of failure
independence. It also sits [upstream of
AltNet](https://github.com/bitcoin/bitcoin/pull/18988), Antoine Riard's draft proposal
for allowing pluggable transport layers in bitcoind. 

Antoine's proposal would allow us to do
things like implement alternative and fallback P2P networks. I think this is incredibly important,
because in many ways the P2P layer is likely the most complex and
hardest-to-reason-about 
part of bitcoind. Certainly some of the most [credible](https://www.usenix.org/conference/usenixsecurity15/technical-sessions/presentation/heilman) and complex threats
to Bitcoin in recent years have come from its P2P layer. There is [exceptional
work](https://github.com/bitcoin/bitcoin/pull/15759) happening to address these risks,
but P2P still feels like a sort of single point of failure at the moment. We need
ready-to-go backups, and multiprocess/AltNet are prerequisites.

### Consensus encapsulation

Another line of work that I'll be sure to review consistently is [Carl Dong's
libbitcoinkernel project](https://twitter.com/carl_dong/status/1298002824740188160).
Basically the idea is to separate out the consensus-critical runtime and data structures
into a separate interface that's accessible from other, non-bitcoind
environments. This would mean that there could be a variety of node implementations
written in `$your_favorite_trendy_lang` with, say, whatever P2P semantics you'd like 
without risk of fudging consensus operation.

Carl's starting this work by building off some refactoring I had to do for the assumeutxo
project: [introducing a single object](https://github.com/bitcoin/bitcoin/pull/17737) 
that manages access to the consensus data structures. Right now he's 
[in the process](https://github.com/bitcoin/bitcoin/pull/20158) of removing global
usages of that object so that we can cordon off its use to the validation layer.

If I somehow have time after reviewing all that, keeping the assumeutxo PRs rebased, and
keeping bitcoinperf off the operating table, I plan to continue work on a network
monitor I've been mulling over for a few years.


## Asks

So at the moment I'm the early processes of shaking the tree to fund the work I've outlined above. 

If you or
someone you know is looking to fund stability-focused Core work, I'd really appreciate
the consideration. Feel free to get in touch any way you like; email and twitter are
good options.

The other material thing that Bitcoin needs right now is compute for fuzzing. Fuzz
processes are very computationally expensive, and the more compute we have running
fuzzers, the more likely we are to discover vulns. If you or someone you know has a
bunch of compute laying around, please get in touch.


### Back in the wilderness

For about 30 seconds I was a little scared to leave a full-time job and return to the
unstructured "desert of the real" that is opensource Bitcoin development. It can be an
isolating grind. But there's so much that needs doing and bitcoind resilience is so
critical that I didn't give it a second thought.

It's good to be back.


---

[^1]: Mostly just because no one pays them to do it. I swear to you I was near useless for the first six months at Chaincode (aside from bitcoinperf work) because I had to orient myself on how to make useful changes in Core. 
[^2]: 80% of Core development is spending time with `git rebase -i`, reconciling diffs, restarting CI runs, and trying to figure out how to clandestinely encode expletives into your comments.
[^3]: `cd ~/src/bitcoin/ && git shortlog -s -n --since="2020-03-21"`
[^4]: Yeah yeah I'm excited about taproot like everyone else, but an important corequisite is that we ensure existing Bitcoin functionality continues uninterrupted.
[^5]: Since I didn't learn my lesson [six years ago](https://unemployeddd.tumblr.com/post/102456668270/leaving-new-york).
