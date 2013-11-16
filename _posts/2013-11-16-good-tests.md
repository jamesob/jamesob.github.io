---
title: "Good tests, bad tests"
layout: post
published: true
---

No doubt about it, automated testing is in vogue. Everyone knows that if you
want to impress an interviewer, all you have to do is fawn on about getting 
paranoid with whatever JUnit clone is in your language's ecosystem. 

This is better than a complete ambivalence or hostility towards testing, but a
middle is commonly excluded. 

### Yes, testing is great

One of the saving graces of being a human is that you can anticipate your own
stupidity and avoid error with planning and practices. Almost every time I
resist the urge to "just push" a branch to QA without writing tests, I find
that taking the extra few minutes to bang out a few basic usages 
has revealed some dumb omission on my part that would've wasted valuable
QA time.

But we can go too far. The returns on testing don't just diminish; tests
actually become counterproductive if we hit cruise-control and stop using
care.


### So what do you test?

One of the things that I always ask a serious engineering candidate at 
[Percolate](http://www.percolate.com/jobs) is, given
some basic module, what does the shape of your automated test look like?

I usually give them a contrived but illustrative example, the `sorter` module:

<script src="https://gist.github.com/jamesob/7503290.js?file=sorter.py">
</script>

The example is not very Pythonic in all sorts of ways, but it's a great 
playground for getting a sense of how someone decides what to test.

4 times out of 5, a candidate's answer will resemble something like

<script src="https://gist.github.com/jamesob/7503290.js?file=typical-sorter-test.py">
</script>

Really enthusiastic candidates will even tack on a test like this

<script src="https://gist.github.com/jamesob/7503290.js?file=crazy-additional-test.py">
</script>


Wow! A comprehensive, statuesque display of automated safety, am I right? 
Surely a test like this will guarantee a smooth sail through the 
choppy seas of the development lifecycle 'til Kingdom Come. 


### Slow down, Tonto

Presumably in an effort to show that he's a cautious, comprehensive tester, the
candidate has gone whole-hog: tests have been written for all members of the
module, regardless of whether they're marked as being private. He's even
duplicated part of the routing algorithm with a fancy use of `mock`.

The intention here is of course good, but there are some significant drawbacks
to be aware of. Let's back up a bit and talk about module privacy.


### Private means private

Privacy in dynamic languages like Python and Ruby should be shown even more
reverence than in static languages like Java where the concept is codified with
reserved words and compiler enforcement. 

Lightweight function definition makes it all too easy to have a proliferation
of module attributes in dynamic languages, obscuring the intended entrypoints
into a module. Ever open a file only to see roughly 30 top-level public
functions, leaving you with no idea of which one is appropriate to use?

If you don't incorporate privacy conventions and reduce your
public interface aggressively, refactoring becomes much more difficult because
you have made a contract with users of your module that you won't change any
existing part of it. Assume that "not private" means "locked in"[^0].


#### This applies to testing too

Testing the private attributes of a class or module impose the same sort of
burdens as not declaring a minimal public interface. When you test private
attributes, you codify *not only the expected behavior, but the implementation
details* of your module into tests. 

What happens if we want to replace `_merge_sort` with `_quick_sort`? We now
have to update two additional places in the code. Or what about fast-pathing
an empty list to return itself? Going to have a cryptic failure due to 
that clever mock test.

Not only is refactoring more annoying, but we now have *three* superfluous
testcases to run and maintain.


### Doing it right with coverage

The nice thing about measuring code coverage isn't so much that you can rest
on your laurels once you've hit 100%, but that coverage can be a great guide
for exercising all of the code in a module entirely through the public 
interface.

Let's revise our test to be as simple as possible, only using the public
interface:
 
<script src="https://gist.github.com/jamesob/7503290.js?file=the_right_test_1.py">
</script>

Let's see where that gets us with coverage:

{% highlight sh %}
$ nosetests --cov-report=term --with-coverage --cover-package=sorter the_right_test_1.py 
.
Name     Stmts   Miss  Cover   Missing
--------------------------------------
sorter      15      2    87%   40-41
----------------------------------------------------------------------
Ran 1 test in 0.004s

OK
{% endhighlight %}

As you would expect, such a basic test doesn't fully exercise the module. 
Looks like we missed a `_merge_sort` call, so let's include a test case that'll
fix that.
  
<script src="https://gist.github.com/jamesob/7503290.js?file=the_right_test_2.py">
</script>
  

{% highlight sh %}
$ nosetests --cov-report=term --with-coverage --cover-package=sorter the_right_test_2.py 
.
Name     Stmts   Miss  Cover   Missing
--------------------------------------
sorter      15      1    93%   28
----------------------------------------------------------------------
Ran 1 test in 0.004s

OK
{% endhighlight %}

Great, we're making solid progress. The last thing we need to test is the
ValueError.

   
<script src="https://gist.github.com/jamesob/7503290.js?file=the_right_test_3.py">
</script>

Because we're conscious programmers who realize that coverage doesn't mean
everything is covered, we added in a few assertions that test degenerate 
arguments.
 

{% highlight sh %}
$ nosetests --cov-report=term --with-coverage --cover-package=sorter the_right_test_3.py 
.
Name     Stmts   Miss  Cover   Missing
--------------------------------------
sorter      15      0   100%   
----------------------------------------------------------------------
Ran 1 test in 0.005s

OK
{% endhighlight %}

### Better

Awesome: we now have a test that only uses the public interface of `Sorter` but
fully exercises its contents. Our colleagues can confidently refactor the
internals of sorter without having to maintain superfluous tests or suffer
excessive build times. Coverage will alert maintainers if they've introduced an
implementation detail that isn't covered by tests.


### Notes

Let me reiterate that a tool like `coverage` only provides a shallow look into
how much you're actually testing. When you train coverage on your module only,
many independent code paths in underlying libraries may be going uncovered. 

Is fretting about those potential blind spots something that should keep you up
at night? I won't try to answer that, but it's something to keep in mind.

Another point is that if we did want to do significant testing on either
`_merge` or `_radix` sort, we have the option of breaking them out into their
own public objects and then referencing them from `Sorter`. Again, the sorter
tests wouldn't require changes, and the separate packaging of the sort
strategies would enable reuse by other people.


### Takeaways

As an interviewer, part of what I try to gauge is someone's appreciation for
Occam's razor/KISS/less is more/etc. This is a concept that comes up very often
in programming, and it's especially true in effective, sustainable testing.

Careful consideration of privacy in dynamic languages is also key for 
maintaining a team's sanity. Be decisive and clear about what you choose to
expose in a module. Maintenance, testing, and use will be much more pleasant.

### Related resources 

- [Growing Object-Oriented Software, Guided by Tests](http://www.amazon.com/Growing-Object-Oriented-Software-Guided-Tests/dp/0321503627/ref=sr_1_1?ie=UTF8&qid=1384633202&sr=8-1&keywords=growing+objects+tests): 
an engaging read on the importance of end-to-end tests, and how to do them right.
- [Martin Fowler's article on mocks vs. stubs](http://martinfowler.com/articles/mocksArentStubs.html)
and some of the second-order implications.


[^0]: of course there are exceptions here (&lt;1.0 releases) but it's a good
rule of thumb to keep in mind while designing


