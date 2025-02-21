[![Actions Status](https://github.com/raku-community-modules/XML/actions/workflows/linux.yml/badge.svg)](https://github.com/raku-community-modules/XML/actions) [![Actions Status](https://github.com/raku-community-modules/XML/actions/workflows/macos.yml/badge.svg)](https://github.com/raku-community-modules/XML/actions) [![Actions Status](https://github.com/raku-community-modules/XML/actions/workflows/windows.yml/badge.svg)](https://github.com/raku-community-modules/XML/actions)

An Object-Oriented XML Framework for Raku
=========================================

Introduction
------------

XML (originally called Exemel) is a full fledged XML library for Raku.

It handles parsing, generating, manipulating and querying XML. It supports element queries, parent element information, namespaces, and an extendable interface.

It supports every major kind of XML Node (XML::Node):

    * Document (XML::Document)

    * Element (XML::Element)

    * Text (XML::Text)

    * Comment (XML::Comment)

    * PI (XML::PI)

    * CDATA (XML::CDATA)

You can easily serialize the objects back to XML text by using any XML::Node object in a string context.

Documentation
-------------

### XML

A *module* that provides a few simple subroutines.

#### from-xml(Str $string --> XML::Document)

Parse the string as XML, and return an XML::Document object.

#### from-xml-stream(IO $input --> XML::Document)

Slurp the IO, parse the contents, and return an XML::Document object.

#### from-xml-file(IO::Path() $file --> XML::Document)

Return an XML::Document object representing the specified file. You will be able to call $xml.save(); to save back to the original file.

#### open-xml(Str|IO::Path|IO::Handle $src)

A multi sub that picks the right way to open `$src` . If a `Str` is given it defaults to a filename. If such file is found it assumes a `Str` containing XML.

#### make-xml(Str $name, ... --> XML::Element)

See the *XML::Element.craft()* function for details on how this works.

### XML::Node

A *role* used by the rest of the XML Node classes.

#### $.parent [rw]

The XML::Element or XML::Document to which this Node belongs. Only an XML::Document will have an undefined *$.parent* property.

#### remove()

Removes the Node from its parent element.

#### reparent(XML::Element $newparent)

Removes the Node from its existing parent (if any) and sets the specified node as its *$.parent* property.

#### previousSibling()

Returns the Node that exists in the parent just before this one. Returns Nil if there is none.

#### nextSibling()

Returns the Node that exists in the parent just after this one. Returns Nil if there is none.

#### cloneNode()

This is a polymorphic method that exists in all XML::Node objects, and does what is needed to return a clone of the desired Node.

#### ownerDocument()

Returns the top-level XML::Document that this Node belongs to.

### XML::Document [XML::Node]

A Node representing an XML document. You can use array access syntax on it to access children of the root node. You can use hash access syntax on it to access attributes of the root node.

#### $.version

The XML version. Default: '1.0'

#### $.encoding

The text encoding, if specified in the XML declarator.

#### %.doctype

Has two keys, *'type'* represents the document type, *'value'* represents the rest of the DOCTYPE declaration (if applicable.)

#### $.root

The root XML::Element of the document. This also proxies many of the useful XML::Element methods, so that they can be called directly from the XML::Document object.

#### $.filename

If an XML::Document represents a file on the file-system, this is the path to that file.

#### new(Str $xml, :$filename)

Parse the passed XML and return an XML::Document. If the *$filename* variable is passed, the *$.filename* property will be set on the object.

#### new(XML::Element $root)

Create a new XML::Document object, with the specified XML::Element as its root element.

#### load(Str $filename)

Create a new XML::Document object, representing the specified file. The *$.filename* property will be set.

#### save(Str $filename?, Bool :$copy)

Save the XML back into a file. If the *$filename* parameter is not passed, we use the *$.filename* property (if it is set, otherwise we return False.)

If the *:copy* option is true, we don't re-set the *$.filename* property.

#### .elems()

See XML::Element.elems() for details, but this basically tells you how many child nodes (whether Element nodes or otherwise) the root node has. 

### XML::Element [XML::Node]

A Node representing an individual XML element. You can use array access syntax to access child nodes, and hash access syntax to access or set attributes.

#### $.name [rw]

The tag name of the element.

#### @.nodes

Any child nodes that may exist. All members of *@.nodes* MUST be an object that does the XML::Node role.

Unless you are doing something that requires direct access of the *@.nodes* property, it's probably easier (and less noisy) to use the array access syntax.

#### %.attribs

XML attributes for the current node. We expect the keys and values to be strings, but you can use numeric values if you want. Remember on emitting or parsing, all values will be strings, even if you set it as a number.

It is recommended that you do not use *%.attribs* directly to set values. Use the *set()* method or the hash access syntax to set attribute values, and use the *unset()* method to delete attributes.

#### $.idattr [rw, default: 'id']

Specifies what attribute will be used as the XML Id when using the *getElementById()* method. This defaults to *'id'* which is used in (X)HTML and thus the most common.

#### new(Str $xml)

Return a new XML::Element object representing the specified XML string.

#### insert(XML::Node $node)

Insert an XML::Node at the beginning of our *@.nodes* list.

#### insert(Str $name, ...)

Create a new XML::Element with the given name, and insert it to the beginning of our nodes list. Uses *craft()* to build the element.

Any named parameters will be used as attributes, any positional parameters will be used as child nodes.

Positional parameters can be one of the following:

    * An XML::Node object. Will be added as is.

    * A String. Will be included as an XML::Text node.

    * A Capture. Calls *craft()* using the Capture as the signature.

    * Anything else, will be stringified, and added as an XML::Text node.

#### append(XML::Node $node)

Append an XML::Node to the bottom of our *@.nodes* list.

#### append(Str $name, ...)

See _insert (Str $name, ...)_ but at the bottom.

#### before(XML::Node $existing, XML::Node $new)

Insert the *$new* Node before the *$existing* Node. It only works if the *$existing* node is actually found in our *@.nodes* list.

#### before(XML::Node $node)

Only works if our *$.parent* is an XML::Element. Inserts the Node before the current one.

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

If the *$existing* node is found, replace it with *$new* , otherwise, we return False.

#### replaceChild(XML::Node $new, XML::Node $existing)

An alternative to *replace()* with DOM semantics.

#### removeChild (XML::Node $node)

Removes the *$node* from our child *@.nodes* if it exists. If it doesn't we return False.

#### firstChild()

Return our first child node.

#### lastChild()

Return our last child node.

#### index-of($find)

Pass it a smart match rule, and it will return array index of the first matching node.

#### craft(Str $name, ...)

Create and return a new XML::Element object with the given name. Named and positional parameters are handled as with _insert(Str $name, ...)_

#### set(Str $name, $value)

Set an attribute with the given *$name* to the specified *$value* . If the *$value* is a Str or Numeric is is added directly. If it is Bool and True, the value will be set to the same as the *$name* . If it is Bool and False, the attribute will be deleted.

Any other value will be stringified using the *.Str* method.

#### set(...)

A *set()* call containing no positional paramters, will pass all named parameters to the above *set()* as key/value pairs.

#### unset($name, ...)

Each positional parameter passed will be assumed to be the name of an attribute to delete.

#### unset(:$name, ...)

We assume the key of each named parameter passed to be the name of an attribute to delete. The value means absolutely nothing and is in fact ignored entirely.

#### is-bool($attrib)

Returns True if the given attribute exists, and has the same value as its name (the definition of an XML boolean.)

#### add-values (Str $attrib, Set $values)

For the attribute with the given *$name* , perform the set-wise union, *(|)* , of the set of *$values* passed to the method and the existing values of the attribute. The results are converted back to a string value and stored in the attribute. For example:

```perl
my $xml = from-xml('<test><folks we = "Al Barb Carl"/></test>');
say $xml[0]; # <folks we="Al Barb Carl"/>

$xml[0].add-values("we", <Carl Dave Ellie>.Set);
say $xml[0]; # <folks we="Al Barb Carl Dave Ellie"/>
```

#### delete-values (Str $attrib, Set $values)

For the attribute with the given *$name* , perform the set-wise difference, *(-)* , of the existing values of the attribute and the *$values* passed to the method. The results are converted back to a string value and stored in the attribute. For example:

```perl
my $xml = from-xml('<test><folks we = "Al Barb Carl Dave Ellie"/></test>');
say $xml[0]; # <folks we="Al Barb Carl Dave Ellie"/>

$xml[0].delete-values("we", <Al Ellie Zack>.Set);
say $xml[0]; # <folks we="Barb Carl Dave"/>
```

#### test-values (Str $attrib, @tests)

For the attribute with the given *$name* , test each value in @tests for membership in the set of existing values of the attribute. Returns a hash that has the test values as keys and the boolean results of the membership test as values. For example:

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

If set to a non-zero digit, child elements will also be searched for elements matching the queries. The recursion will traverse a tree depth of the value set to this parameter.

    * NEST

Used with *RECURSE* if this is set to True, this will recurse even child elements that matched the query.

    * SINGLE

If this is set to True, we will return the first matched value. If no values match, we will return False. If *SINGLE* is not specified, or is set to False, we return an Array of all matches (this may be empty if no nodes matched.)

    * OBJECT

If this is set to True, instead of returning an Array of results, we will return a XML::Element object with the same name as the original input object, with its nodes set to the matched elements.

    * POS

If set to an Int, the element must be the nth child to match. If set to a Range, the element's position must be within the range. If set to a Whatever match rule (e.g. * > 2) the rule must match.

If this is set to an Int, and RECURSE is not a positive value, then the SINGLE rule will be set to True.

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

Match even child nodes. By default this is based on natural position (i.e. the second child element is even) see BYINDEX for details.

    * ODD

Match odd child nodes. By default this is based on natural position (i.e. the first child element is odd) see BYINDEX for details.

    * BYINDEX

If set to True, then the EVEN and ODD rules match against the array index value rather than the natural position. Therefore, the first element will be even, since it is in position 0.

Any other named paramters not in the above list, will be assumed to be attributes that must match. You can match by value, regular expression, or whatever code matches.

```perl
  my $head = $html.elements(:TAG<head>, :SINGLE);
  my @stylesheets = $head.elements(:TAG<link>, :rel<stylesheet>);
  my @middle = $table.elements(:!FIRST, :!LAST);
  my @not-red = $div.elements(:class(* ne 'red'));
  my @elms-by-class-name = $html.elements(:RECURSE(Inf), :class('your-class-name')); # find all elements by class name
```

#### lookfor(...)

A shortcut for elements(..., :RECURSE)

#### getElementById($id)

Return the XML::Element with the given id.

#### getElementsByTagName($name, :$object?)

Return an array of XML::Elements with the given tag name.

If the boolean $object named parameter is true, then the 'OBJECT' rule will be applied to the query sent to elements().

#### nsPrefix(Str $uri)

Return the XML Namespace prefix.

If no prefix is found, it returns an undefined value. If the URI is the default namespace, it returns ''.

#### nsURI(Str $prefix?)

Returns the URI associated with a given XML Namespace prefix. If the *$prefix* is not specified, return the default namespace.

Returns an undefined value if there is no XML Namespace URI assigned.

#### setNamespace($uri, $prefix?)

Associated the given XML Namespace prefix with the given URI. If no *$prefix* is specified, it sets the default Namespace.

#### comments()

Return an array of all XML::Comment child nodes.

#### cdata()

Returns an array of all XML::CDATA child nodes.

#### instructions()

Returns an array of all XML::PI child nodes.

#### contents()

Returns an array of all XML::Text child nodes.

#### .elems()

XML and Raku have quite different meanings for the word "element". In XML, an Element is a <tag/>, whereas in Raku, it's a single element in a one-dimensional list/array. 

The TL;DR is that .elements() uses the XML meaning, whereas .elems() uses the Raku meaning. 

The slightly longer version is that, since XML::Element does Positional, it has to have a .elems() method that supports the Raku meaning. So .elems will tell you how many children the node has, not the number of XML::Element children (since there will likely be some text nodes and things in there as well). 

### XML::Text [XML::Node]

A Node representing a portion of plain text.

#### $.text

The raw text, with no whitespace chopped out.

#### Str(XML::Entity :$decode, Bool :$min, Bool :$strip, Bool :$chomp, Bool :numeric)

Return the text, with various modifications depending on what was passed. If :decode is set, we decode XML entities using the XML::Entity object. If :min is set, we replace multiple whitespace characters with a single space. If :strip is set, we trim off leading and trailing whitespace. If :chomp is set, we remove the trailing newline. The :numeric value is passed to the decoder specified in :decode.

#### string(XML::Entity $decode=XML::Entity.new)

An alias for Str(:$decode, :min, :strip, :chomp, :numeric);

Basically, make the text node easier to read for humans.

The default $decode value is a new instance of XML::Entity.

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

### XML::Entity

#### decode(Str $input, Bool :$numeric)

Decode XML entities found in the string.

#### encode(Str $input, Bool :$hex, ...)

Encode known XML entities, plus any numeric values passed as extra parameters. Any additional parameters should be the regular base10 integer values of the additional characters that should be encoded.

If :hex is true we encode using hexidecimal entities instead of decimal.

#### add (Str $name, Str $value)

Add a new custom entity named $name with the replacement value $value.

#### add (Pair $pair)

An alias for self.add($pair.key, $pair.value);

Examples
--------

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

### test.raku

```raku
use XML;

my $xml = from-xml-file('test.xml');

say $xml[1]<en> ~ $xml[1][0]; ## "hello world"
say $xml[3][5][0]; ## "Maybe"

$xml[3].append('item', 'Never mind');

say $xml[3][9]; ## <item>Never mind</item>
```

Author
------

Timothy Totten, supernovus on #raku, https://github.com/supernovus/

### Note

The XML::Grammar library was originally based on the now defunct [XML::Grammar::Document](http://github.com/krunen/xml) library, but modified to work with Rakudo 'ng' and later 'nom', with other changes specific to this library.

License
-------

[Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0)

