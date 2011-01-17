---
layout: post
title: Search and replace across many files in vim
---

During some refactoring, I was hit with the need to do some serious bad-man
search and replace across entire directories from within vim, because almost any
alternative would be more painful than listening to Cher's discography and
watching The View simultaneously.
After scouring Google results for a while, the only article I could find
detailing this technique was a [pretty good one][l1] by Ibrahim Ahmed.

I'll summarize with an example. Let's say you have a massive Python project, and
you want to replace every call to certain accessor functions with a variable
name. For example, `wat.getZappaAlbum()` becomes `wat.zappaAlbum`. Let's
say that your Python project is in the `~/Code/albums` directory.

From within vim, we first have to specify which files we want to operate on.

    :args ~/Code/albums/**/*.py

That is, we specify `args` as any Python file within any subdirectory of
`~/Code/albums`. You can use regular expressions here and, in fact, a few
comments on Ibrahim's site allude to piping in file names with a bash script.

After we have specified the files we want to act on, we specify the action.
Let's say we have two functions we want to replace: `getTreasureFingersAlbum`
and `getToroAlbum`. We want to change them to `treasureFingersAlbum` and
`toroAlbum`, respectively.
    
    :argdo %s/get\(TreasureFingers\|Toro\)Album()/\l\1Album/gec | update

Now you're whipping through each matching instance, yaying or naying each
replacement like a glutton prince.

Wait, what? Let's break down what's going on here.

- `:argdo`, unsurprisingly, specifies that we're acting on the args we
  specified earlier.
- `%s/foo/bar/gc` replaces each instance of `foo` with `bar` and prompts you
  before doing so.
- `get\(TreasureFingers\|Toro\)Album()` matches either
  `getTreasureFingersAlbum()` or `getToroAlbum()` and the escaped
  parenthesis "capture" either
  `TreasureFingers` or `Toro` for later use in the replacement.
- `\l\1Album` is the meat. The prefix, `\l`, tells vim to make the first
  character of the following back-reference lowercase. The next component, 
  `\1`, is a back-reference to the capture (either `TreasureFingers` or
  `Toro`), and "Album" is simply appended to the replacement.
- `gec` is used instead of `gc` because the inclusion of `e` avoids error
  messages in the case that we search a file and don't find a match (this
  will happen).
- `| update` simply saves the file after we've completed the first
  operation: the find and replace.

More information about case changes within regular expressions can be found
[here][l2].
    

[l1]: http://www.ibrahim-ahmed.com/2008/01/find-and-replace-in-multiple-files-in.html
[l2]: http://vim.wikia.com/wiki/Changing_case_with_regular_expressions
