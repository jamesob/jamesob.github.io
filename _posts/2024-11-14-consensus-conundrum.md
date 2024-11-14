---
title: Bitcoin's Consensus Conundrum
layout: post
---

Bitcoin faces a one-of-a-kind leadership problem

—--

A lot of consensus-change proposals for bitcoin are on the table at the moment. All of
them have good motivations, whether it's scaling UTXO ownership or making self-custody
more tractable. I won’t rehash them here, you’re probably already familiar. Some have
been actively developed for years.

The past two such changes that have been made to bitcoin successfully, Segwit and
Taproot, were massive engine-lift-style deployments fraught with drama. There have been
smaller changes in bitcoin’s past, like the introduction of locktimes, but for some
reason the last two have been kitchen sink affairs.

The reality not often talked about by many bitcoin engineers is that up until Taproot,
bitcoin’s consensus development was more or less operating under a benevolent
dictatorship model. Project leadership went from Satoshi to Gavin to… well, I’ll stop
naming names.

Core developers will likely quibble with this characterization, but we all know deep
down that to a first order approximation that it’s basically true. The “final say” and
big ideas were implicitly signed off on by one guy, or maybe a small oligarchy of
wizened autists.

In many ways there’s really nothing wrong with this - most (all?) major opensource
projects operate similarly with pretty clear leadership structures. Oftentimes they
have benevolent dictators who just “make the call” in times of high-dimensional
ambiguity. Everyone knows Guido and Linus and the based Christian sqlite guy.

Bitcoin is aesthetically loathe to this but the reality, whether we like it or not, is
that this is how it worked up until about 2021.

Given that, there are three factors that create the CONSENSUS CONUNDRUM facing bitcoin
right now:

- The old benevolent dictators (or high-caste oligarchy) have abdicated their power,
  leaving a vacuum that shifts the project from “conventional mode of operation” to
  “novel, never-before-tried” mode: an attempt at some kind of supposedly meritocratic
  leaderlessness.

This change is coupled with the fact that

- the possible design space for improvements and things to care about in bitcoin is
  wide open at this point. Do you want vaults? Or more L2s? What about rollups? Or how
  about a generic computational tool like CAT? Or should we bundle the generic things
  with applications (CTV + VAULT) to make sure they really work?

The problem is that all of these are valid opinions. They all have merit, both in terms
of what to focus on and how to get to the end goal. There really isn’t a clear
“correct” design pattern.

- A final factor that makes this situation poisonous is that faithfully pursuing,
  fleshing out, building, “doing the work” of presenting a proposal IS REALLY REALLY
  TIME CONSUMPTIVE AND MIND MELTING.

Getting the demos, specs, implementation, and "marketing" material together is a long
grind that takes years of experience with Core to even approach.

I was well paid to do this fulltime for years, and the process left me with disgust
for the dysfunction and having very little desire to continue contribution. I think
this is a common feeling.

A related myth is that businesses will do something analogous to aid the process. The
idea that businesses will build on prospective forks is pretty laughable. Most bitcoin
companies have a ton on their backlog, are fighting for survival, and have basically no
one dedicated to R&D. The have a hard enough time integrating features that actually
make it in.

Many of the ones who do have the budget for R&D are shitcoin factories that don’t care
about bitcoin-specific upgrades.

I’ve worked for some of the rare companies that care about bitcoin and do have the
money for this kind of R&D, and even then the resources are not sufficient to build a
serious product demo on top of 1 of N speculative softforks that may never happen.

—--

This kind of situation is why human systems evolve leadership hierarchies. In general,
to progress in a situation like this someone needs to be in a position to say “alright,
after due consideration we’re doing X.”

Of course what makes this seem intractable is that the Bitcoin mythology dictates
(rightly) that clear leadership hierarchies are how you wind up, in the limit, with the
Fed.

Sure, bitcoin can just never change again in any meaningful way ("ossify"). But at this
point that almost certainly resigns it to yet another financial product that can only
be accessed with the benefit of a large institution.

If you grant that bitcoin should probably keep tightening its rules for more and better
functionality, but that we should go "slow and steady," I think there are issues with
that too.

Because another factor that isn’t talked about is that as bitcoin rises in price, and
as nation-states start buying in size, the rules will be harder to change. So inaction
— not deciding — is actually a very consequential decision.

I do not know how this resolves.

—--

There’s another uncomfortable subject I want to touch on: where the power actually lies.

The current mechanism for changing bitcoin hinges on what Core developers will merge.
This of course isn’t official policy, but it’s the unintended reality.

Other less technically savvy actors (like miners and exchanges) have to pick some
indicator to pay attention to that tells them what changes are safe and when they are
coming. They have little ability or interest to size these things up for themselves, or
do the development necessary to figure them out.

My Core colleagues will bristle at this characterization. They’ll say “we’re just
janitors! we just merge what has consensus!” And they’re not being disingenuous in
saying that. But they’re also not acknowledging that historically, that is how
consensus changes have operated.

This is something that everyone knows semi-consciously but doesn’t really want to own.

Core devs saying “yes” and clicking merge has been a necessary precursor every time.
And right now none of the Core devs are paying attention to the soft fork 
conversations - sort of understandable, there’s a bunch to do in bitcoin.

But let’s be honest here, a lot of the work happening in Core has been sort of
secondary to bitcoin’s realization.

Mempool work is interesting, but the whole model is more or less upside down anyway
because it’s based on altruism. For-profit darkpools and accelerators seem inevitable
to me, although that could be argued. Much of the mempool work is rooted in support for
Lightning, which is pretty obviously not going to solve the scaling problem.

Sure, encrypted P2P connections are great, but what’s even the point if we can’t get
on-chain ownership to a level beyond essentially requiring the use of an exchange,
ecash mint, sidechain, or some other trusted third party?

My main complaint is that Core has developed an ivory tower mindset that more or less
sneers at people pitching long-run consensus ideas. They don't seem to try to
actually engage with the long-term, hard problems.

And that could have bitcoin fall short of its potential.

—--

I don’t know what the solution to any of this is. I do know that self-custody is
totally nervewracking and basically out of the question for casual users, and I do know
that bitcoin in its current form will not scale to twice-monthly volume for even 10% of
the US, let alone most of the world.

The people who don’t acknowledge this, and who want to spend critical time and energy
proposing the perfect remix of CTV, are making a fateful choice.

Most of the longstanding, fully specified fork proposals active today are totally fine,
and conceptually they’d be great additions to bitcoin.

Hell, probably a higher block size is safe given features like compactblocks and
assumeutxo and eventually utreexo. But that’s another post for another day.

—--

I've gone back and forth about writing a post like this, because I don't have any
concrete prescriptions or recommendations. I guess I can only hope that bringing up
these uncomfortable observations is some distant precursor to making progress on
scaling self-custody.

All of these opinions have probably been expressed by @JeremyRubin years ago in his
blog. I’m just tired of biting my tongue.

Thanks to @rot13maxi and @MsHodl for feedback on drafts of this.
