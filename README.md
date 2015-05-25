# An Object-Oriented XML Framework for Perl 6

[![Build Status](https://travis-ci.org/supernovus/Template-Anti.svg?branch=master)](https://travis-ci.org/supernovus/Template-Anti)

## Introduction

XML (originally called Exemel) is a full fledged XML library for Perl 6.

It handles parsing, generating, manipulating and querying XML.
It supports element queries, parent element information, namespaces,
and an extendable interface.

It supports every major kind of XML Node (XML::Node):

 * Document (XML::Document)
 * Element (XML::Element)
 * Text (XML::Text)
 * Comment (XML::Comment)
 * PI (XML::PI)
 * CDATA (XML::CDATA)

You can easily serialize the objects back to XML text by using any XML::Node
object in a string context.

## Documentation

### XML

A _module_ that provides a few simple subroutines.

#### from-xml(Str $string --> XML::Document)

Parse the string as XML, and return an XML::Document object.

#### from-xml-stream(IO $input --> XML::Document)

Slurp the IO, parse the contents, and return an XML::Document object.

#### from-xml-file(Str $file --> XML::Document)

Return an XML::Document object representing the specified file.
You will be able to call $xml.save(); to save back to the original file.

#### make-xml(Str $name, ... --> XML::Element)

See the _XML::Element.craft()_ function for details on how this works.

### XML::Node

A _role_ used by the rest of the XML Node classes.

#### $.parent [rw]

The XML::Element or XML::Document to which this Node belongs.
Only an XML::Document will have an undefined _$.parent_ property.

#### remove()

Removes the Node from its parent element.

#### reparent(XML::Element $newparent)

Removes the Node from its existing parent (if any) and sets the
specified node as it's _$.parent_ property.

#### previousSibling()

Returns the Node that exists in the parent just before this one.
Returns Nil if there is none.

#### nextSibling()

Returns the Node that exists in the parent just after this one.
Returns Nil if there is none.

#### cloneNode()

This is a polymorphic method that exists in all XML::Node objects,
and does what is needed to return a clone of the desired Node.

#### ownerDocument()

Returns the top-level XML::Document that this Node belongs to.

### XML::Document [XML::Node]

A Node representing an XML document. You can use array access syntax on it
to access children of the root node. You can use hash access syntax on it
to access attributes of the root node.

#### $.version

The XML version. Default: '1.0'

#### $.encoding

The text encoding, if specified in the XML declarator.

#### %.doctype

Has two keys, _'type'_ represents the document type, _'value'_ represents
the rest of the DOCTYPE declaration (if applicable.)

#### $.root

The root XML::Element of the document. 
This also proxies many of the useful XML::Element methods, so that
they can be called directly from the XML::Document object.

#### $.filename

If an XML::Document represents a file on the file-system, this is the
path to that file.

#### new(Str $xml, :$filename)

Parse the passed XML and return an XML::Document.
If the _$filename_ variable is passed, the _$.filename_ property will be
set on the object.

#### new(XML::Element $root)

Create a new XML::Document object, with the specified XML::Element as it's
root element.

#### load(Str $filename)

Create a new XML::Document object, representing the specified file.
The _$.filename_ property will be set.

#### save(Str $filename?, Bool :$copy)

Save the XML back into a file. If the _$filename_ parameter is not passed,
we use the _$.filename_ property (if it is set, otherwise we return False.)

If the _:copy_ option is true, we don't re-set the _$.filename_ property.

### XML::Element [XML::Node]

A Node representing an individual XML element. You can use array access syntax
to access child nodes, and hash access syntax to access or set attributes.

#### $.name [rw]

The tag name of the element.

#### @.nodes

Any child nodes that may exist. 
All members of _@.nodes_ MUST be an object that does the XML::Node role.

Unless you are doing something that requires direct access of the _@.nodes_
property, it's probably easier (and less noisy) to use the array access syntax.

#### %.attribs

XML attributes for the current node. We expect the keys and values to be
strings, but you can use numeric values if you want. Remember on emitting
or parsing, all values will be strings, even if you set it as a number.

It is recommended that you do not use _%.attribs_ directly to set values.
Use the _set()_ method or the hash access syntax to set attribute values,
and use the _unset()_ method to delete attributes.

#### $.idattr [rw, default: 'id']

Specifies what attribute will be used as the XML Id when using the
_getElementById()_ method. This defaults to _'id'_ which is used in (X)HTML
and thus the most common.

#### new(Str $xml)

Return a new XML::Element object representing the specified XML string.

#### insert(XML::Node $node)

Insert an XML::Node at the beginning of our _@.nodes_ list.

#### insert(Str $name, ...)

Create a new XML::Element with the given name, and insert it to the
beginning of our nodes list. Uses _craft()_ to build the element.

Any named parameters will be used as attributes, any positional parameters
will be used as child nodes. 

Positional parameters can be one of the following:

 * An XML::Node object. Will be added as is.
 * A String. Will be included as an XML::Text node.
 * A Capture. Calls _craft()_ using the Capture as the signature.
 * Anything else, will be stringified, and added as an XML::Text node.

#### append(XML::Node $node)

Append an XML::Node to the bottom of our _@.nodes_ list.

#### append(Str $name, ...)

See _insert (Str $name, ...)_ but at the bottom.

#### before(XML::Node $existing, XML::Node $new)

Insert the _$new_ Node before the _$existing_ Node.
It only works if the _$existing_ node is actually found in our _@.nodes_ list.

#### before(XML::Node $node)

Only works if our _$.parent_ is an XML::Element. Inserts the Node
before the current one.

#### before(Str $name, ...)

See _insert (Str $name, ...)_ and _before(XML::Node $node)_ and figure it out.

#### after(XML::Node $existing, XML::Node $new)

Like _before($existing, $new)_ but put the node after the _$existing_ one.

#### after(XML::Node $node)

Like _before(XML::Node $node)_ but put the node after the current one.

#### after(Str $name, ...)

As per the others.

#### insert-xml(Str $xml)

Insert to top, a new XML::Element representing the given XML string.

#### append-xml(Str $xml)

Append to bottom, a new XML::Element representing the given XML string.

#### before-xml(Str $xml)

Insert a new XML::Element for the XML string, before the current element.

#### after-xml(Str $xml)

Insert a new XML::Element for the XML string, after the current element.

#### insertBefore(XML::Node $new, XML::Node $existing)

An alternative to _before($existing, $new)_ using DOM semantics.

#### insertAfter(XML::Node $new, XML::Node $existing)

An alternative to _after($existing, $new)_ using DOM-like semantics.

#### replace(XML::Node $existing, XML::Node $new)

If the _$existing_ node is found, replace it with _$new_,
otherwise, we return False.

#### replaceChild(XML::Node $new, XML::Node $existing)

An alternative to _replace()_ with DOM semantics.

#### removeChild (XML::Node $node)

Removes the _$node_ from our child _@.nodes_ if it exists.
If it doesn't we return False.

#### firstChild()

Return our first child node.

#### lastChild()

Return our last child node.

#### index-of($find)

Pass it a smart match rule, and it will return array index of the first
matching node.

#### craft(Str $name, ...)

Create and return a new XML::Element object with the given name.
Named and positional parameters are handled as with _insert(Str $name, ...)_

#### set(Str $name, $value)

Set an attribute with the given _$name_ to the specified _$value_.
If the _$value_ is a Str or Numeric is is added directly.
If it is Bool and True, the value will be set to the same as the _$name_.
If it is Bool and False, the attribute will be deleted.

Any other value will be stringified using the _.Str_ method.

#### set(...)

A _set()_ call containing no positional paramters, will pass all named
parameters to the above _set()_ as key/value pairs.

#### unset($name, ...)

Each positional parameter passed will be assumed to be the name of
an attribute to delete.

#### unset(:$name, ...)

We assume the key of each named parameter passed to be the name of
an attribute to delete. The value means absolutely nothing and is in fact
ignored entirely.

#### is-bool($attrib)

Returns True if the given attribute exists, and has the same value
as its name (the definition of an XML boolean.)

#### add-values (Str $attrib, Set $values)

For the attribute with the given _$name_, perform the set-wise union, _(|)_, 
of the set of _$values_ passed to the method and the existing values of the attribute.
The results are converted back to a string value and stored in the attribute. For example:

```perl
my $xml = from-xml('<test><folks we = "Al Barb Carl"/></test>');
say $xml[0]; # <folks we="Al Barb Carl"/>

$xml[0].add-values("we", <Carl Dave Ellie>.Set);
say $xml[0]; # <folks we="Al Barb Carl Dave Ellie"/>
```

#### delete-values (Str $attrib, Set $values)

For the attribute with the given _$name_, perform the set-wise difference, _(-)_, 
of the  existing values of the attribute and the _$values_ passed to the method.
The results are converted back to a string value and stored in the attribute. For example:

```perl
my $xml = from-xml('<test><folks we = "Al Barb Carl Dave Ellie"/></test>');
say $xml[0]; # <folks we="Al Barb Carl Dave Ellie"/>

$xml[0].delete-values("we", <Al Ellie Zack>.Set);
say $xml[0]; # <folks we="Barb Carl Dave"/>
```

#### test-values (Str $attrib, @tests)

For the attribute with the given _$name_, test each value in @tests for membership
in the set of existing values of the attribute. Returns a hash that has the test values
as keys and the boolean results of the membership test as values. For example:

```perl
my $xml = from-xml('<test><folks we = "Barb Carl Dave"/></test>');
say $xml[0]; # <folks we="Barb Carl Dave"/>

my %test-results = $xml[0].test-values("we", <Al Carl Zack>.Array);
say %test-results; # "Al" => Bool::False, "Carl" => Bool::True, "Zack" => Bool::False
```

#### elements()

Return all child XML::Elements.

#### elements(...)

Specify a query of named parameters. Special processing parameters are used:

 * TAG

   If set, elements must match the given tag name.

 * NS

   If set, elements must match the given namespace prefix.

 * URI

   If set, elements must match the given namespace URI.

 * RECURSE

   If set to a non-zero digit, child elements will also be searched for
   elements matching the queries. The recursion will traverse a tree depth
   of the value set to this parameter.

 * NEST

   Used with _RECURSE_ if this is set to True, 
   this will recurse even child elements that matched the query.

 * SINGLE

   If this is set to True, we will return the first matched value.
   If no values match, we will return False.
   If _SINGLE_ is not specified, or is set to False, we return an Array
   of all matches (this may be empty if no nodes matched.)

 * OBJECT

   If this is set to True, instead of returning an Array of results,
   we will return a XML::Element object with the same name as the original
   input object, with its nodes set to the matched elements.

 * POS

   If set to an Int, the element must be the nth child to match.
   If set to a Range, the element's position must be within the range.
   If set to a Whatever match rule (e.g. * > 2) the rule must match.

   If this is set to an Int, and RECURSE is not a positive value, then
   the SINGLE rule will be set to True.

 * NOTPOS

   Set to an Int, then we match if the element is not the nth child.

 * FIRST

   Match only if the element is the first child.

   If RECURSE is not a positive value, then SINGLE will be set to True.

 * !FIRST

   Don't include the first child in the results.

 * LAST

   Match only if the element is the last child.

   If RECURSE is not a positive value, then SINGLE will be set to True.

 * !LAST

   Don't include the last child in the results.

 * EVEN

   Match even child nodes. By default this is based on natural position
   (i.e. the second child element is even) see BYINDEX for details.

 * ODD

   Match odd child nodes. By default this is based on natural position
   (i.e. the first child element is odd) see BYINDEX for details.

 * BYINDEX

   If set to True, then the EVEN and ODD rules match against the array index
   value rather than the natural position. Therefore, the first element will
   be even, since it is in position 0.

Any other named paramters not in the above list, will be assumed to be
attributes that must match. You can match by value, regular expression, or
whatever code matches.

```perl

  my $head = $html.elements(:TAG<head>, :SINGLE);
  my @stylesheets = $head.elements(:TAG<link>, :rel<stylesheet>);
  my @middle = $table.elements(:!FIRST, :!LAST);
  my @not-red = $div.elements(:class(* ne 'red'));

```

#### getElementById($id)

Return the XML::Element with the given id.

#### getElementsByTagName($name, :$object?)

Return an array of XML::Elements with the given tag name.

If the boolean $object named parameter is true, then the 'OBJECT' rule will
be applied to the query sent to elements().

#### nsPrefix(Str $uri)

Return the XML Namespace prefix.

If no prefix is found, it returns an undefined value.
If the URI is the default namespace, it returns ''.

#### nsURI(Str $prefix?)

Returns the URI associated with a given XML Namespace prefix.
If the _$prefix_ is not specified, return the default namespace.

Returns an undefined value if there is no XML Namespace URI assigned.

#### setNamespace($uri, $prefix?)

Associated the given XML Namespace prefix with the given URI.
If no _$prefix_ is specified, it sets the default Namespace.

#### comments()

Return an array of all XML::Comment child nodes.

#### cdata()

Returns an array of all XML::CDATA child nodes.

#### instructions()

Returns an array of all XML::PI child nodes.

#### contents()

Returns an array of all XML::Text child nodes.

### XML::Text [XML::Node]

A Node representing a portion of plain text.

#### $.text

The raw text, with no whitespace chopped out.

#### string()

Return the $.text, chomping training newline, replacing multiple whitespace
characters with a single space, and trimming off leading and trailing 
whitespace characters.

### XML::Comment [XML::Node]

Represents an XML Comment 

```xml
  <!-- comment here -->
```

#### $.data

Contains the string data of the content.

### XML::PI [XML::Node]

Represents an XML processing instruction.

```xml
  <?blort?>
```

#### $.data

Contains the string text of the processing instruction.

### XML::CDATA [XML::Node]

Represents an XML CDATA structure.

```xml
  <![CDATA[ random cdata content here ]]>
```

#### $.data

Contains the string text of the CDATA.

## Examples

A quick example, for more, see the tests in the 't/' folder.

### test.xml

```xml
<test>
  <greeting en="hello">world</greeting>
  <for>
    <item>Yes</item>
    <item>No</item>
    <item>Maybe</item>
    <item>Who cares?</item>
  </for>
</test>
```

### test.p6

```perl
use XML;

my $xml = from-xml-file('test.xml');

say $xml[0]<en> ~ $xml[0][0]; ## "hello world"
say $xml[1][2][0]; ## "Maybe"

$xml[1].append('item', 'Never mind');

say $xml[1][4]; ## <item>Never mind</item>
```

## Author

Timothy Totten, supernovus on #perl6, https://github.com/supernovus/

### Note

The XML::Grammar library was originally based on the now defunct
[XML::Grammar::Document](http://github.com/krunen/xml) library,
but modified to work with Rakudo 'ng' and later 'nom', 
with other changes specific to this library.

## License

[Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0)

