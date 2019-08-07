---
layout: post
title: Writing a robot driver with Clojure
labels: clojure, robots, state
enable_comments: true
---

So after watching a few of the <a href="http://clojure.blip.tv">Hickey talks</a>,
I got excited about Clojure (a modern, practical Lisp that'll leverage
JIT compilation and Java inter-op? Stamp my hand, Chachi!) and decided to learn
it by writing a driver for the iRobot Create, the results of which are
[here](http://github.com/jamesob/create.clj/).

My experience was mixed. I enjoyed blowing through the talks and Programming Clojure,
i.e., listening to people talk about why Clojure is great, but when it came
to the task of coding something that inherently relies on mutable state (a robot
construct) I found a few parts of the language aggravating:

* Cumbersome notation for anything mutable.
  Dereferencing a ref every time you need to get at the
  data basically takes the language back to C's pointer
  notation for every mutable object in the system. Considering
  C has you specify argument types at function definition, this isn't
  a huge deal, but in Clojure, function definitions dealing with
  mutable objects can get hairy and ambiguous as to whether or not
  an incoming object has already been dereferenced. 

  I know state is evil and rabble rabble rabble, but I don't see how
  adding an extra level of indirection does anyone any good.

  Instead of using the "@" notation for indirection, why can't
  a ref just evaluate to its value and throw an `IllegalStateException`
  if it's modified outside of a transaction? No need for convoluted
  notation and still as thread-safe as it was previously. If someone
  can provide me an example of where the indirection is beneficial,
  I'd be interested in hearing it.

* The fact that seqs are by default lazy caused some serious confusion
  at points. Yes, this gripe is mostly on me for not being intimate with
  the style, but it caused some subtle bugs in my code that were tough to
  track down. For example, this function flushes a buffer by reading bytes
  out of it until the estimated "available" value is 0:

  ```clojure
  (defn flush-read-buff
    "Flush a robot's read buffer."
    [bot]
    (let [bytenum (.available ((bot :sock) :robj))]
    ((bot :recv) bytenum)))
    ;; (bot :recv) points to a fn that 
    ;; builds a seq of .readByte calls
    
    This code is completely ineffective when called like so:

  (flush-read-buff bot)
  ```

  Because elements of sequences are, by default, unevaluated until needed and therefore
  the desired side effects aren't imposed, you need to call it like this:
  
  ```clojure
  (doall (flush-read-buff bot))
  ```

  Again, this complaint falls on me, but it's no less counter-intuitive when
  debugging.

* Online documentation is terse and kind of sparse. I understand the language
  is in flux, but even so, in certain cases I really had to hunt around for
  ways to do fairly basic things. For example, here's a simple filtration of a hashmap:
  
  ```clojure
  (def hmap {1 "a", 2 "b", 3 "c"})
  (def filtmap (filter (fn [[k v]] (< 0 k)) hmap))
  filtmap
  ;; returns ([1 "a"] [2 "b"]), a seq
  ;; but we want a hashmap back!
  ```

  So we filter a hashmap and get back... a seq? Okay, but I want a hashmap back.
  
  ```clojure
  (hash-map filtmap)
  ;; fails:
  ;; No value supplied for key: ...
  ;; [Thrown class java.lang.IllegalArgumentException]
  ```

  Okay, so how the hell do I get back to a hashmap idiomatically? Turns out you have
  to use a function called "into", which I couldn't glean from the main documentation
  (despite there being a one word link to the into documentation from the Sequences
  page).

There are a lot of great ideas in Clojure, but its unintuitive performance and
quest against state are very trying.
