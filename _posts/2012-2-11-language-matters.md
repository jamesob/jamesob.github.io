---
title: "The medium obscures the message: why programming languages matter"
layout: post
published: true
---

Recently, I've been getting into confrontations in my workplace regarding our
use of PHP. Even some who agree with me that PHP is a poor language still
say that choice of language is mostly irrelevant to the bottom-line.

I disagree. I have reason to believe that PHP, or any programming language that
is less readable, predictable, and consistent than viable alternatives, is
harmful in use and observably so.  While I do not have figures that indicate
this[^6], I will argue my point using
basic analogies, commonly-accepted hacker wisdom, and examples that should
appeal intuitively to technical readers.

## We're engineers

Often, after complaining of a surprising or erroneous behavior of PHP[^1] in our
development chat, I am engaged by someone who takes issue with my criticism of
PHP and our use of it. 

Typically, the crux of their response is this: my criticisms of PHP are
academic, aesthetic judgements that belong on the sidelines; at the end of the
day, we are engineers that "solve problems" and so the choice of language for
problem solution is outside of our concern so long as the language gets the job
done.

I sympathize partially with this response. We are engineers; our daily
activities *are* concerned with solving problems. However, much as the material
that a civil engineer chooses for the construction of a bridge largely
determines the stability of that bridge, so too does the choice of a medium, a
programming language, determine the robustness of a solution that we code. 

A serious engineer surely would not use clay to build a suspension bridge
(though it may be possible), just as a professional web developer would not
advise using TeX to build a high-traffic web application. These are extreme
examples, but they both allude to a relative ordering in the *quality* of a
solution in terms of its medium, ceteris paribus.

## What is quality?

In order to have an intelligent discussion about efficacy, we must first define
it. What does it mean for a piece of software to be quality? Specifically, what
does it mean for a body of code to be quality? 

Quality is highly contextual. A bridge of good quality could be described as a
physical construction that provides a stable, human-navigable connection between two
pieces of land while requiring as little maintenance as possible. Quality is
comprised of a large number of independent metrics in most cases, but
by [Pareto's principle](http://en.wikipedia.org/wiki/Pareto_principle), it's
likely that just a few of those dimensions will give us a good indication of
total quality. The description that I have provided of a good bridge adequately,
but perhaps not completely, represents the criteria used to determine whether a
bridge is good or not.

I will characterize code of a good quality as being a mechanism which allows a
user to supply input, efficiently effecting a desired result which varies on
that input, and preferably in a way that requires the user to learn as little
additional context as possible. Implicit in this definition of quality, and
perhaps key to it, is that the software will perform as free of error as
possible.

Stated simply: good code is, among other things, nearly bug-free. For
simplicity, I will not extend this definition of quality to include
extensibility, which, while important, is beside my point. I contend that choice
of language is especially relevant to the number of bugs; that issue will be my
primary concern.

## Comparing mediums

So, I have demonstrated that the choice of a tool or material, i.e. the medium,
plays a definite role in determining the quality of a solution. I have also
given my definition of what quality is. Now, the relevant question becomes: does
a use of PHP affect the quality in a significantly negative way, ceteris
paribus, relative to the use of other languages?

I will argue that while the difference between PHP and Groovy or Python isn't as
drastic as the difference between clay and steel for use in the making of a
bridge, it is significant. I base my reasoning on three metrics: predictability,
readability, and compactness.

### Predictability

I will define *predictability* as how easy it is for a human to reason about
what a piece of code will do before running that code, or *statically*.
Predictability is important when concerned with writing bug-free code because it
allows the programmer to not only be clear about his intentions to other
programmers, but it allows him to produce code that carries out his intentions
with as little effort as possible. 

The more clearly the intentions of the programmer are represented in code, the
easier it will be for the author and other programmers to verify correctness.

What do you expect the following code example to result in?
{% highlight php %}
<?php
php> $a = null;
php> $a->hotbaz = 1;
{% endhighlight %}

Conceptually, `null` (in most programming languages, and in PHP) is the single,
canonical representation of nothing. It is the absence of value. From the PHP
manual:
> The special NULL value represents a variable with no value. NULL is the only
> possible value of type NULL.

So, what would you expect of the above code? Considering that `null` is nothing,
most sensible programmers would expect an error to be thrown upon dereferencing
nothing. Many sensible API designers would happily return `null` for functions
in which the attempted retrieval of, say, an object fails.

Unfortunately, that isn't what happens. Instead, PHP accepts the above as a
valid operation. Here's how `$a` looks afterwards:
{% highlight php %}
<?php
php> = $a
<object #2 of type stdClass> {
  hotbaz => 1,
}
{% endhighlight %}

A `stdClass` object is automatically instantiated, from nothing, with no
warning. A bug results when a user employing the fictional API mentioned above
continues to use this object, expecting that an `Exception` should have been
thrown and caught.

In other languages, namely Python and Groovy, this class of bugs is not
possible: 

{% highlight python %}
>>> a = None 
>>> a.hotbaz = 1
Traceback (most recent call last): File "<stdin>", line 1, in <module>
AttributeError: 'NoneType' object has no attribute 'hotbaz' 
{% endhighlight %}

{% highlight python %}
groovy:000> a = null
===> null
groovy:000> a.hotbaz = 1
ERROR java.lang.NullPointerException:
Cannot set property 'hotbaz' on null object
        at groovysh_evaluate.run (groovysh_evaluate:2)
        ...
{% endhighlight %}

Those two languages maintain a reverence for the definition of `None` and
`null`, and thus behave in a way that a programmer capable of deductive
reasoning would consider predictable.

The treatment of such a fundamental language construct should be indicative of
other properties of a language. If a language behaves unexpectedly with
fundamental properties such as the null value, how can we rely on it to do more
complex operations in a predictable way?

Let's consider another essential language property: function arity. 
{% highlight php %}
<?php
php> function baz($a) {
 ...   return $a + 1;
 ... }

php> = baz(1, 2, 3);
2
{% endhighlight %}

The PHP interpreter doesn't complain when a function is passed more arguments
than what it was defined to handle; this makes the execution of a program more
difficult to reason about and therefore makes unexpected behavior harder to
track down. What if an argument is left out of a function definition after
refactoring? PHP will not inform the programmer of this, giving him less
information to combat errors.

This sort of lenience is not permitted in other languages, where predictability
as a tool for quality is recognized[^2]:

{% highlight python %}
>>> def foo(a):
...   return a + 1
... 
>>> foo(1, 2, 3)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: foo() takes exactly 1 argument (3 given)
{% endhighlight %}

{% highlight python %}
groovy:000> def baz(a) {
groovy:001>   a + 1
groovy:002> }
===> true
groovy:000> baz(1, 2, 3)
ERROR groovy.lang.MissingMethodException:

No signature of method: groovysh_evaluate.baz() is applicable for argument
types: (java.lang.Integer, java.lang.Integer, java.lang.Integer) values: [1, 2, 3]
Possible solutions: baz(java.lang.Object), wait(), run(), run(), any(), grep()
        at groovysh_evaluate.run (groovysh_evaluate:2)
        ...
{% endhighlight %}


### Readability

In a 1946 essay entitled *[Politics and the English
Language](http://www.mtholyoke.edu/acad/intrel/orwell46.htm)*, George Orwell
argues that stark, simple English must be used (and demanded) by
readers, else lies and atrocities could be masked by overly complex presentation.

The same applies to programs. The logical meat-and-potatoes of a program should
be as plain as possible to readily reveal potential errors. Syntax should be
simple and noise-free so that larger matters of correctness can be more easily
considered.

When each variable in your language is prefixed by `$`, the signal-to-noise
ratio is diluted. When object dereferences take two characters instead of one,
the eye has more boilerplate to process. When the most commonly used data
structure in your language is wrapped in `array()` instead of `[]`, an
individual critiquing for correctness (or simply attempting to understand) has
more work to do than is necessary. Finding hidden or subtle faults will take
more time and diligence.

*Readability*, or the level of ease and speed with which a competent
practitioner can fully understand a piece of code, has an obvious effect on how
amenable a program is to housing errors.

#### An example

Consider the following example of PHP[^7]:

{% highlight php %}
<?php
$x = 1;
$nums = array(10, 20, 30, 40);

$arr = array();
foreach ($nums as $n)
  if ($n > 15)
    $arr[] = $n * 2 + $x;
$res = 0;
foreach ($arr as $r)
  $res -= $r;
{% endhighlight %}

Consider the same functionality in Groovy:
{% highlight python %}
def x = 1
def nums = [10, 20, 30, 40]
def res = nums.findAll { it > 15 } 
    .collect { it * 2 + x } 
    .inject(0) {accum, val -> accum - val}
{% endhighlight %}

The intent in the Groovy code is much clearer. We can attempt to emulate this
succinct style in PHP, though it becomes an unreadable mess:

{% highlight php %}
<?php
$x = 1;
$nums = array(10, 20, 30, 40);

$res = array_reduce(
        array_map(
            function($v) use ($x) { return $v * 2 + $x; },
            array_filter(
                $nums,
                function($v) { return $v > 15; })
            ),
        function ($v, $w) { return -$v - $w; }
);
{% endhighlight %} 

#### From the real world

If you find the previous example too contrived, consider the following PHP code
pulled straight from production[^4]:

{% highlight php %}
<?php
/**
 * $node is a `stdClass`, $item is an associative array.
 */
private function update_taxonomy(&$node, $item) {
  // loop through all the taxonomy terms we are interested in
  $site = variable_get('site', '');

  foreach ($this->taxonomyMap as $type => $map) {
    if (($type == '*') || ($type == $node->type) || ($type == $site .'/*') \
        || ($type = $site.'/'.$node->type)) {
      foreach ($map as $field_name => $tax_term) {
        $read_only = isset($tax_term['read-only']) ? $tax_term['read-only'] : FALSE;

        foreach ($tax_term['path'] as $path) {
          $list = xpath($item, $path);

          if (!is_null($list)) {
            // add terms to vocabulary
            if (!is_array($list)) { $list = array($list); }
            foreach ($list as $local_item) {
              add_taxonomy_node($node, $field_name, $local_item, $tax_term['vid'], $read_only);
            }
          }
        }
      }          
    }
  }
}
{% endhighlight %}

I don't expect you to read it or understand it; partly because it is
highly-contextual, but mostly because it is daunting and convoluted.

On the other hand, try reading this code:

{% highlight python %}
def update_taxonomy(self, node, item):
  site = variable.get('site', '')

  ok_types = ['*', 
              node.type, 
              '%s/*' % site, 
              '%s/%s' % (site, node.type)]

  ok_maps = [self.taxonomyMap[t] for t in ok_types]

  for field, tax_term in ok_maps.items():
    read_only = tax_term.get('read_only', False)
    path_list = list(tax_term.get('path', []))

    for path in path_list:
      local_items = xpath(item, path)
      local_items = list(local_items) if local_items else []
      [add_tax_node(node, fieldname, local, i, tax_term['vid'], read_only) 
       for i in local_items]
{% endhighlight %}

These two methods do the same thing and assume the same context. There is not
necessarily a difference in the number of lines of code, but there is a clear
difference in the readability of the two. One of the examples makes it very easy
to see exactly what the intentions and assumptions of the author were.[^3]

When a language requires more effort to read, either because it pollutes code
with a lot of noise  
(`$`, `->`, `array()`, et al), or lacks succinct notation
for common operations like collection --iteration,  
--creation, and --manipulation, it
is more difficult to judge the correctness of the algorithms it expresses. 

Because of this, a more readable language will exhibit fewer bugs. By our
definitions, this leads to an increase in the quality of code and a decrease in
the amount of time that it takes to ship software with the same functionality.

### Compactness

In *[The Art of Unix Programming](http://www.faqs.org/docs/artu/ch04s02.html)*,
Eric S. Raymond defines *compactness* as a property indicating how well "a
design can fit inside a human being's head." Compactness is a primary
determinant in how predictable and readable a programming language is. As such,
it is relevant when considering how effective a language is at producing code
with less errors.

Stated differently, a language is compact if it is intuitive to use after an
initial understanding of the language's paradigms.

#### Regularity in paradigm

A confusion of design makes a language anti-compact. When object-orientation is
half-baked into a standard library that is mostly procedural, unintuitive
behavior and code that is difficult to read follows. Systems that are built on
languages like this exhibit the same problem: see the confusion that results
from the presence of `stdClass`s, structured arrays, and full-blown objects in
Drupal, a CMS framework written in PHP.

Nodes, one of the most common datatypes in Drupal, are represented with
`stdClass`s when, by nature of having behaviors and required attributes, they
should be distinct classes.

{% highlight php %}
<?php
php> $node = new stdClass();
php> $node->title = 'foobar';
php> $node->type = 'article';
php> node_save($node);

php> $node2 = new stdClass();
php> $node->title = 'heybaz';
php> node_save($node2);

Uncaught exception: EntityMalformedException: Missing bundle property on entity
of type node.
{% endhighlight %}

Persisting the node to a datastore can be attempted without the node having
required attributes. 

The association of functions with a `stdClass` instead of methods with a proper
object means that there is no single point of truth for how Drupal expects a
node to behave, thereby increasing complexity, confusion, and the likelihood of
misuse. Instead of going to one source of documentation for how to work with a
node, we're subject to many sources. This is more time-consuming than it needs
to be.

Consistency in the data model of PHP would encourage consistency in Drupal. This
is how the above should look:
 
{% highlight php %}
<?php
php> $node = new Node('article');
php> $node->title = 'foobar';
php> $node->save();

php> // better yet
php> $node = new ArticleNode($title);
...
{% endhighlight %}

#### Regularity in notation

In Python and Groovy, collections behave consistently. 

{% highlight python %}
Python 2.7.2 (default, Dec  5 2011, 20:11:10)
...
>>> for i in "abc":
...   print i,
... 
a b c
>>> for i in ['a', 'b', 'c']:
...   print i,
... 
a b c
>>> for i in {'a':1, 'b':1, 'c':1}:
...   print i,
... 
a c b

>>> [i for i in "abc"]
['a', 'b', 'c']

>>> [i for i in [1, 2, 3]]
[0, 1, 2]

>>> {"abc"[x]:x for x in range(3)}
{'a': 0, 'c': 2, 'b': 1}
{% endhighlight %}

Specifically, collections are objects that all implement a specific interface
which allows them to be used by the same control structures. They are
polymorphic to a common notation. This affords the Python or Groovy programmer
regularity; he has to think less to accomplish what he wants. A reader doesn't
have to work as hard because the notation is consistent. This medium makes the
message clearer.

PHP does not exhibit this kind of compactness.

{% highlight php %}
<?php
php> foreach (array(1, 2, 3) as $x) {
 ...   echo $x;
 ... }
123

php> foreach ("abc" as $i) {
 ...   echo $i;
 ... }

Warning: Invalid argument supplied for foreach() in
/usr/local/lib/python2.7/site-packages/phpsh/phpsh.php(593) 
...

php> foreach(str_split('abc') as $x) {
 ...   echo $x;
 ... }
abc
{% endhighlight %}

This divides how a user operates with separate data structures that are, in many
ways, analogous. If we were reading Chinese, this is like having to parse a
technical manual written in both Mandarin and Cantonese. An editor having to
check that text's grammar and content now has twice as much work.

PHP also doesn't respect referential transparency[^8], a large factor in compactness
and predictability.

{% highlight php %}
<?php
php> "abc"[0]
Multiline input has no syntactic completion:

Parse error: syntax error, unexpected '[' in Command line code on line 1

php> $a = "abc"
php> = $a[0]
"a"

php> $arr = array(1, 2, 3);
php> function get_arr() {
 ...   global $arr;
 ...   return $arr;
 ... }

php> = get_arr()[0]
Multiline input has no syntactic completion:

Parse error: syntax error, unexpected '[' in Command line code on line 1

php> = (get_arr())[0]
Multiline input has no syntactic completion:

Parse error: syntax error, unexpected '[' in Command line code on line 1

php> = $arr[0]
1
{% endhighlight %}

This kind of behavior stifles regularity, and therefore compactness. It
places a needless burden on the programmer and his co-workers. 

In short, anti-compactness wastes time.

## The medium constrains the message

Mathematics is, by many accounts, the purest distillation of reason. It also
features a language that is predictable, readable, and compact. The language of
mathematics is so rich in these three metrics that the overwhelming majority of
time is spent not on the notation itself, but understanding the ideas
represented by the notation. 

Looking back at [early mathematical
notation](http://math.unipa.it/~grim/mathnotation.pdf) and its evolution, the
language clearly wasn't always concise as it is today.

<img src="/images/chinese_math.png" />
<div class="caption">Ancient Chinese notation for an arithmetic expression, from
the article above.</div>

Had we continued using the same cumbersome notation seen above for ideas as
basic as addition and multiplication, how could we expect to develop and express
complex ideas like differential calculus? How could we expect mathematicians to
critique one another's work in a timely way?

It's no coincidence that mathematical notation is minimal and concise. It is a
medium that makes its content as obvious as possible, which has enabled
criticism and development to flourish.

The same evolution is true of programming languages. Using programming languages
that make concise abstraction difficult results in code that is more prone to
error because it is more harder to develop and read. This is wasted time. This
is wasted money[^9].

For this reason, the choice of language is relevant to the daily business and
long-term success of a software company. Subsequently, it is the duty of a
software engineer to make judgements about his tools and advocate those which
allow him to operate most effectively. 


[^1]: To name a few: injection of inner functions into the global symbol table
(violation of lexical scoping), PHP's unwillingness to allow array dereferences
on functions that return arrays (`foo()[0]`, or even `(foo())[0]`), PHP's
throwing of a fatal error on the second encounter of an inner function
definition, PHP's automatic `stdClass` construction from a null variable (`$a =
null; $a->foo = 'abc';`), PHP's inability to declare class-level attributes that
are not strings or integers.

[^2]: Worth noting is that both Python and Groovy offer constructs for
variadic arguments.

[^3]: In fact, the Python is even at a disadvantage here because it interacts
with an API that was designed to accommodate PHP's warts; namely, the continual
checking and casting of return types.

[^4]: The variable names have been sanitized for anonymity.

[^6]: Studies correlating bug count with language use are apparently not of
interest to academia.

[^7]: This example was taken and modified from [this
article](http://justafewlines.com/2009/10/whats-wrong-with-php-closures/)

[^8]: [Referential transparency on
Wikipedia](http://en.wikipedia.org/wiki/Referential_transparency)

[^9]: See Paul Graham's [experiences with
Viaweb](http://www.paulgraham.com/avg.html).

