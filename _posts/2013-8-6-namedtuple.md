---
title: "How namedtuple works in Python 2.7"
layout: post
published: true
---

The other day, I was on a plane to San Francisco. Lacking an internet
connection, I decided to read through some of the source for Python 2.7's
standard library. I found `namedtuple`'s implementation especially
interesting, I guess because I had assumed it was a lot more magical than it
turns out to be.

Here's the
[source](http://hg.python.org/releasing/2.7.3/file/7bb96963d067/Lib/collections.py#l232),
reprinted with some annotations on stuff I found interesting. If you haven't
heard of namedtuple before, it's a very useful builtin that you should [check
out](http://pymotw.com/2/collections/namedtuple.html). 

#### The code
                                                              

```python
################################################################################
### namedtuple
################################################################################

```

woo! doesn't that comment header get you jazzed!?

We start off with---you guessed it---a function declaration and a good use
of doctests.

```python
def namedtuple(typename, field_names, verbose=False, rename=False):
    """Returns a new subclass of tuple with named fields.

    >>> Point = namedtuple('Point', 'x y')
    >>> Point.__doc__                   # docstring for the new class
    'Point(x, y)'
    >>> p = Point(11, y=22)             # instantiate with positional args or keywords
    >>> p[0] + p[1]                     # indexable like a plain tuple
    33
    >>> x, y = p                        # unpack like a regular tuple
    >>> x, y
    (11, 22)
    >>> p.x + p.y                       # fields also accessable by name
    33
    >>> d = p._asdict()                 # convert to a dictionary
    >>> d['x']
    11
    >>> Point(**d)                      # convert from a dictionary
    Point(x=11, y=22)
    >>> p._replace(x=100)               # _replace() is like str.replace() but targets named fields
    Point(x=100, y=22)

    """
```

Below we start with some argument wrangling. Note the use of `basestring`,
which should be used for isinstance checks that try to determine if something
is str-like[^0]: this way, we capture both unicode and str types.

```python
    # Parse and validate the field names.  Validation serves two purposes,
    # generating informative error messages and preventing template injection attacks.
    if isinstance(field_names, basestring):
        field_names = field_names.replace(',', ' ').split() # names separated by whitespace and/or commas
```
 
If `rename` has been set truthy, we pick out all the invalid names given and
underscore 'em for new (and hopefully valid) names.

```python
    field_names = tuple(map(str, field_names))
    if rename:
        names = list(field_names)
        seen = set()
        for i, name in enumerate(names):
            if (not all(c.isalnum() or c=='_' for c in name) or _iskeyword(name)
                or not name or name[0].isdigit() or name.startswith('_')
                or name in seen):
                names[i] = '_%d' % i
            seen.add(name)
        field_names = tuple(names)
```

Note the nice use of a generator expression wrapped in `all()` below. The
`all(bool_expr(x) for x in things)` pattern is a really powerful way of
compressing an expectation about many arguments into one readable statement.

```python
    for name in (typename,) + field_names:
        if not all(c.isalnum() or c=='_' for c in name):
            raise ValueError('Type names and field names can only contain alphanumeric characters and underscores: %r' % name)
        if _iskeyword(name):
            raise ValueError('Type names and field names cannot be a keyword: %r' % name)
        if name[0].isdigit():
            raise ValueError('Type names and field names cannot start with a number: %r' % name)
```

A quick check for duplicate fields:

```python
    seen_names = set()
    for name in field_names:
        if name.startswith('_') and not rename:
            raise ValueError('Field names cannot start with an underscore: %r' % name)
        if name in seen_names:
            raise ValueError('Encountered duplicate field name: %r' % name)
        seen_names.add(name)
```

Now the fun really starts[^1]. Arrange the field names in various ways in
preparation for injection into a code template. Note the cute repurposing of a
tuple str representation for `argtxt`, and the slice notation for duplicating a
sequence without its first and last elements.

```python
    # Create and fill-in the class template
    numfields = len(field_names)
    argtxt = repr(field_names).replace("'", "")[1:-1]   # tuple repr without parens or quotes
    reprtxt = ', '.join('%s=%%r' % name for name in field_names)
```

Here's namedtuple behind the curtain; a format string that resembles (and will
be rendered to) Python code. I've added extra linebreaks for clarity.

```python
    template = '''class %(typename)s(tuple):
        '%(typename)s(%(argtxt)s)' \n
        __slots__ = () \n
        _fields = %(field_names)r \n

        def __new__(_cls, %(argtxt)s):
            'Create new instance of %(typename)s(%(argtxt)s)'
            return _tuple.__new__(_cls, (%(argtxt)s)) \n

        @classmethod
        def _make(cls, iterable, new=tuple.__new__, len=len):
            'Make a new %(typename)s object from a sequence or iterable'
            result = new(cls, iterable)
            if len(result) != %(numfields)d:
                raise TypeError('Expected %(numfields)d arguments, got %%d' %% len(result))
            return result \n

        def __repr__(self):
            'Return a nicely formatted representation string'
            return '%(typename)s(%(reprtxt)s)' %% self \n

        def _asdict(self):
            'Return a new OrderedDict which maps field names to their values'
            return OrderedDict(zip(self._fields, self)) \n

        __dict__ = property(_asdict) \n

        def _replace(_self, **kwds):
            'Return a new %(typename)s object replacing specified fields with new values'
            result = _self._make(map(kwds.pop, %(field_names)r, _self))
            if kwds:
                raise ValueError('Got unexpected field names: %%r' %% kwds.keys())
            return result \n

        def __getnewargs__(self):
            'Return self as a plain tuple.  Used by copy and pickle.'
            return tuple(self) \n\n
        
        ''' % locals()
```

So there it is, our template for a new class. 

I like the use of `locals()` for string interpolation. I'd always missed easy
interpolation of local variables in Python; groovy and coffeescript both have
ways of saying something like `"{name} is {some_value}"`. I guess `"{name} is
{some_value}".format(**locals())` is close.

You probably noticed that `__slots__` is set to an empty tuple; this ensures
that Python doesn't set aside a dictionary for each instantiation of this new
class, making instances lightweight. Between the immutability provided by the
parent class (tuple) and the fact that new attributes can't be slapped onto
instances (`__slots__ = ()`), instances created by namedtuple types are
basically [value objects](http://c2.com/cgi/wiki?ValueObject).

Next, a read-only property is attached for each field.
Note that `_itemgetter` comes from the `operator` module and
returns a callable that takes a single argument, so it fits nicely into 
`property`.

```python
    for i, name in enumerate(field_names):
        template += "        %s = _property(_itemgetter(%d), doc='Alias for field number %d')\n" % (name, i, i)
    if verbose:
        print template
```

So, we've got a pretty grandiose str containing Python code; now what do we do
with it? 

Evaluation in a travel-sized namespace sounds about right. Check out the use of
`exec ... in`. 

```python
    # Execute the template string in a temporary namespace and
    # support tracing utilities by setting a value for frame.f_globals['__name__']
    namespace = dict(_itemgetter=_itemgetter, __name__='namedtuple_%s' % typename,
                     OrderedDict=OrderedDict, _property=property, _tuple=tuple)
    try:
        exec template in namespace
    except SyntaxError, e:
        raise SyntaxError(e.message + ':\n' + template)
    result = namespace[typename]
```

Pretty slick! The idea of executing the formatted code string in an isolated
namespace, then extracting out the new type is very novel to me. For more
details on the exec construct, check out 
[this post](http://lucumr.pocoo.org/2011/2/1/exec-in-python/) by Armin 
Ronacher.

Next there's some trickery about setting the `__module__` of the new class
to the module that actually invoked namedtuple:

```python
    # For pickling to work, the __module__ variable needs to be set to the frame
    # where the named tuple is created.  Bypass this step in enviroments where
    # sys._getframe is not defined (Jython for example) or sys._getframe is not
    # defined for arguments greater than 0 (IronPython).
    try:
        result.__module__ = _sys._getframe(1).f_globals.get('__name__', '__main__')
    except (AttributeError, ValueError):
        pass
```

and then we're done!

```python
    return result
```

Easy, right?

### Thoughts on the implementation

For me, the most interesting part of the above implementation was the dynamic
evaluation of the code string in a namespace that existed solely for the 
purpose of that one evaluation. It emphasized to me the simplicity of Python's
data model: all namespaces, including modules and classes, really just reduce
to dicts. Seeing the namedtuple usecase really illustrates the power of that
simplicity.

With that technique in mind, I wonder if the fieldname validation couldn't be
simplified using a similar approach. Instead of 
```python
for name in (typename,) + field_names:
    if not all(c.isalnum() or c=='_' for c in name):
        raise ValueError('Type names and field names can only contain alphanumeric characters and underscores: %r' % name)
    if _iskeyword(name):
        raise ValueError('Type names and field names cannot be a keyword: %r' % name)
    if name[0].isdigit():
        raise ValueError('Type names and field names cannot start with a number: %r' % name)
```
the implementor might have said
```python
for name in (typename,) + field_names:
    try:
        exec ("%s = True" % name) in {}
    except (SyntaxError, NameError):
        raise ValueError('Invalid field name: %r' % name)
```
to test more directly and succinctly for a valid identifier. The drawback
to this approach, though, is that we lose specificity in reporting the problem
with the field name. Given that this is in the standard library, explicit
error messages probably make the existing implementation a better bet.


### Just a `find` away

Python users are fortunate enough to have a very readable standard library.
Take advantage of it; it's easy and satisfying to read the exact blueprint of
the builtin modules you know and love.
            

[^0]: at least in Python &lt;3.0

[^1]: because I'm sure you consider runtime construction of datatypes totally 
fun, right?


