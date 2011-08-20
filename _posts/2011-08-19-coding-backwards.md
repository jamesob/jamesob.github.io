---
title: Coding backwards
layout: post
published: false
---

For a while I've wanted to write some personal finance software. Call me crazy,
but I can't find anything currently in existence that allows me to set a
savings goal and then *project* my earnings and expenses[^1]. Basically, I want
to daydream about money.

So I sat down as so many programmers have before me, ready to (almost certainly)
reinvent the wheel my way, and I began to code. I wasn't really feeling inspired,
though. The class structure wasn't immediately clear to me, so I got slightly
frustrated and stared at the screen a while. 

Until I got an idea. 

## The backwards art of software design

Last winter, I interviewed at a hedge fund called Two Sigma in New York City.
Regrettably, I bombed the interview, but it was a great experience nonetheless.
When I sat down with some VP, my first technical interviewer, he asked me to
tackle a considerably difficult data-handling problem in Java. I cracked open a
terminal-based session of vi as he shook his head and muttered something about
why wasn't I using Eclipse.

Then, to my surprise, he told me to write out a bunch of class skeletons ---
class-names, method signatures, and attributes.  He wanted
me to enumerate the cast of characters that I was going to be interacting with,
before I actually decided how the interactions would go down.

Like I said, the interview didn't go too well, but I walked out of there
intrigued by this guy's approach.

I reminisced about this yesterday, as I was struggling to get down a design for
my little Python script. I decided that I'd do the TwoSigma VP one better and
*write out a script using my then-fictitious API*. I'd reverse-engineer a good
design by pretending I'd already written one!

Ten minutes and many backspaces later, I came up with this:

{% highlight python %}
from miser import *
import datetime as dt

m = Miser("jobeirne")

g = Goal(amount = 16e3, # $16,000
         by = dt.date(2012, 8, 1)) # by Aug. 1, 2012

m.attachGoal(g)

bills = [Expense(name = "MATH315 tuition",
                 amount = 1.3e3,
                 on = dt.date(2011, 8, 29)),

         Expense(name = "netflix",
                 amount = 14.,
                 on = MonthlyRecurring(15))] # 15th day of the month

income = [Income(name = "phase2",
                 amount = 1.5e3,
                 on = [MonthlyRecurring(7),
                       MonthlyRecurring(22)])]

m.attachExpenses(bills)
m.attachIncome(income)
{% endhighlight %}

## Skipping steps

I was surprised at how easy and... fun it was. A better design quickly appeared
when I forced myself to preemptively eat my own dogfood. Instead of shoehorning
use-cases after the fact into a class structure I'd already designed, I coded
backwards and the opposite happened: a design evolved from daydreaming about an
API I'd like using.

In a few ways, the design I came up with coding backwards was better than what I
originally proposed. Initially, I was going to have classes like
`MonthlyIncome` and `DailyExpense` that mandated an overly complicated
inheritance structure to avoid repeating periodicity code.

When I wrote a script in my fictional API, I decoupled the transactions and
their frequency of occurrence into two disparate objects without really thinking
about it; I now had

{% highlight python %}
Expense(name = "netflix", amount = 14., on = MonthlyRecurring(15))
{% endhighlight %}

instead of

{% highlight python %}
MonthlyExpense(name = "netflix", amount = 14.);
{% endhighlight %}

which makes for a waaay more reasonable class tree (goodbye, multiple
inheritance).
                  

[^1]: Mint will, of course, let you do the former.
