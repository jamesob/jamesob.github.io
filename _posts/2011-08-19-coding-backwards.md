---
title: Coding backwards
layout: post
published: true
---

For a while I've wanted to write some personal finance software. Call me crazy,
but I can't find anything currently in existence that allows me to project my
earnings and expenses[^1], then summarizes the net effect over a period of time.
Basically, I want to be able to propose a budget to myself and simulate how it
will play out.

So I sat down (as so many programmers have before me), ready to (almost
certainly) reinvent the wheel, and I began to code. I wasn't really feeling
inspired, though. A good design wasn't immediately clear to me, so I got
slightly frustrated and stared aimlessly at the screen awhile. 

Until I got an idea. 

## Quick flashback

Last winter, I interviewed at a hedge fund called Two Sigma in New York City.
Regrettably, I bombed the interview, but it was a great experience nonetheless.
My first technical interviewer was a guy who looked like he needed no less
than three pots of coffee to show any sign of human emotion.  He asked me the
boilerplate questions about design patterns and data structures, but afterwards
he asked me to tackle a considerably difficult data-handling problem in Java. I
cracked open a terminal-based session of `vi` as he shook his head and muttered
something about why wasn't I using Eclipse.

Then, to my surprise, he told me to write out a bunch of class skeletons ---
class names, method signatures, and attributes. He wanted
me to enumerate the cast of characters that I was going to be interacting with
before I actually decided how the interactions would go down.

I walked out of the interview knowing I didn't get the gig, but I was intrigued
by this guy's approach.

## The backwards art of software design

I reminisced about the TwoSigma episode yesterday, as I was struggling to get
down a design for my little personal-finance Python API. I decided that I'd do
the stoic TwoSigma interviewer one better and *write out a script using the yet
unwritten API*. I'd reverse-engineer a good design by pretending I'd already
written one!

Ten minutes and a few backspaces later, I came up with this:

{% highlight python %}
from miser import *

m = Miser("jobeirne")

g = Goal(amount = 16e3, # $16,000
         by = Date(2012, 8, 1)) # by Aug. 1, 2012

m.attachGoal(g)

bills = [Expense(name = "MATH315 tuition",
                 amount = 1.3e3,
                 on = Date(2011, 8, 29)),

         Expense(name = "netflix",
                 amount = 14.,
                 on = MonthlyRecurring(15))] # 15th day of the month

income = [Income(name = "phase2",
                 amount = 1.5e3,
                 on = MonthlyRecurring(7, 22))]

m.attachExpenses(bills)
m.attachIncome(income)

print(m.summary(fromdt = Date(2011, 8, 20), 
                todt = Date(2012, 9, 1))) 
{% endhighlight %}

## Skipping steps

In a few ways, the design I came up with coding backwards was better than what I
originally proposed. Initially, I was going to have classes like
`MonthlyIncome` and `DailyExpense` that mandated an overly complicated
inheritance structure to avoid repeating periodicity code.

When I wrote a script in my fictional API, I decoupled the transactions and
their frequency of occurrence into two disparate objects without really thinking
about it; instead of my initial design,
 
{% highlight python %}
MonthlyExpense(name = "netflix", amount = 14.);
{% endhighlight %}
 
I now had

{% highlight python %}
Expense(name = "netflix", amount = 14., on = MonthlyRecurring(15))
{% endhighlight %}
                    
which makes for a waaay more reasonable class tree (goodbye, multiple
inheritance).
 
I was surprised at how satisfying the experiment was. A better design quickly
appeared when I forced myself to preemptively eat my own dogfood. Instead of
shoehorning use-cases into a class structure I'd already
designed, I coded backwards and the opposite happened: a design evolved from
daydreaming about an API that I'd like using.
                           
## Paint by numbers

Now that I had written out an interface I liked, development was simple: I
started out with skeleton classes and then filled them out so as to match their
behavior in the example usage I had written.

The process was straightforward, though I had to put some thought into how
the classes would be structured internally. As I fleshed out the classes, I
noticed a few ways I could improve upon the API I had come up with, so I made a
few minor changes to the example usage. This iterative back-and-forth continued
throughout development.

## Snags

My experiment wasn't without a catch; since this method of coding backwards is
about as top-down as you can get, I fell into the pitfall of doing a ton of
development without actually running the code to test correctness.

This, of course, led to a long bout of debugging at the end, which was a slight
pain, especially since I'm so used to rapid prototyping. Maybe if I had
test-driven the filling out of the classes, things would've gone
down smoother.

The project was so small that it wasn't a big deal, but I can see how my
approach wouldn't have scaled to something much larger. I'm usually a big fan of
bottom-up development, but coding backwards put me in a mindset that made that a
little less straightforward.

## Conclusion & buzzword bingo
 
Clearly, this technique is inspired by test-driven development, and for all I
know it may be old news to experienced programmers. Nonetheless, I found using
it to be a fun experiment and a nice addition to my utility belt.
                                 
There is no silver bullet for development methodology. Coding backwards, or
*interface-driven development*[^2], certainly won't solve all your problems. It
is, though, a quick and gratifying way to help writer's block and gain some
clarity when you sit down to write an API.

You can follow the development of Miser, my dead-simple personal-finance script,
[here on Github](https://github.com/jamesob/Miser).


[^1]: Mint and other services will allow you to analyze expenses that have
happened in the past, but I couldn't find anything that would let me ask "what
if I adhere to *this* budget?"

[^2]: use that one in a meeting.
