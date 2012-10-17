# Exemel: An Object-Oriented XML Framework for Perl 6

## Introduction

Exemel is a full fledged XML library for Perl 6.

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

A _module_ that provides a multi-dispatch function called 'from-xml'.

#### from-xml(Str $string --> XML::Document)

Parse the string as XML, and return an XML::Document object.

#### from-xml(IO $input --> XML::Document)

Slurp the IO, parse the contents, and return an XML::Document object.

#### from-xml(Str :$file --> XML::Document)

Return an XML::Document object representing the specified file.
You will be able to call $xml.save(); to save back to the original file.

### XML::Node

A _role_ used by the rest of the XML Node classes.

#### $.parent [rw]

The XML::Element or XML::Document to which this Node belongs.
Only an XML::Document will have an undefined _$.parent_ property.

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

If the _:copy_ option is specified, we don't re-set the _$.filename_ property.

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

#### deep-clone()

Performs a clone operation that clones the attributes and nodes recursively.
Returns a new XML::Element object representing the clone.

#### insert(XML::Node $node)

Insert an XML::Node at the beginning of our _@.nodes_ list.

#### insert(Str $name, ...)

Create a new XML::Element with the given name, and insert it to the
beginning of our nodes list.

Any named parameters will be used as attributes, any positional parameters
will be used as child nodes. If the positional parameters are not XML::Node
using objects, they will be stringified and included as a new XML::Text node.

#### append(XML::Node $node)

Append an XML::Node to the bottom of our _@.nodes_ list.

#### append(Str $name, ...)

See _insert (Str $name, ...)_ but at the bottom.

#### before(XML::Node $node)

Only works if our _$.parent_ is an XML::Element. Inserts the Node
before the current one.

#### before(Str $name, ...)

See _insert (Str $name, ...)_ and _before(XML::Node $node)_ and figure it out.

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

#### insert-before(XML::Node $existing, XML::Node $new)

Insert the _$new_ Node before the _$existing_ Node.
It only works if the _$existing_ node is actually found in our _@.nodes_ list.

#### insert-after(XML::Node $existing, XML::Node $new)

Insert the _$new_ Node after the _$existing_ Node.

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

Any other named paramters not in the above list, will be assumed to be
attributes that must match.

```perl

  my $head = $html.elements(:TAG<head>, :SINGLE);
  my @stylesheets = $head.elements(:TAG<link>, :rel<stylesheet>);

```

#### getElementById($id)

Return the XML::Element with the given id.

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

I'm planning to add some nice examples in here, but for now, 
see the tests in t/ to get a good idea of how the library works.

## TODO

### Add more DOM-like methods

I want to make Exemel easy to use for people used to the DOM.
To that end, in addition to the current Perl-like methods, there should be
wrappers matching the corresponding DOM methods as closely as possible.

### Add XML::Query

You can associate any XML::Element or XML::Document object with a query:

```perl
  my $xq = XML::Query($xml);
```

It then provides an XPath 1.0 query method:

```perl
  ## Select all <title/> elements with a 'lang' attribute of 'en'.
  my @titles = $xml.findnodes('//title[@lang="en"]');
```

Plus, a jQuery/CSS selector method:

```perl
  ## Select all <input/> elements with a 'type' attribute of 'radio'.
  my @inputs = $xq.select('input[type="radio"]');
```

### Add XML::Formatter

Enable pretty printing, and more, all with flexible rules.

```perl
  my $xf = XML::Formatter.new(
    :end-cap,          ## Put a space before a closing singleton end slash.
    :indent(2),        ## Indent nested elements with 2 spacing units.
    :use-spaces,       ## Use spaces as the spacing units (see also :use-tabs)
    :collapse(         
      :width(80),      ## Keep lines under 80 chars long.
      :single-line,    ## Collapse Elements with a single line Text node.
      :mixed,          ## Collapse Elements with both Text and Element nodes.
      :tags<li>        ## Collapse the contents of <li/> Elements.
    )
  );
  say $xf.format($xml);
```

Sample output:

```xml
  <html>
    <head>
      <title>The title is collapsed</title>
      <link rel="stylesheet" href="style.css" xf:note="space before slash" />
    </head>
    <body>
      <h1>This tag is collapsed, it's a single line.</h1>
      <ul>
        <li><a href="text1.html">specific tag collapsing</a></li>
        <li><a href="text2.html">is a pretty cool feature</a></li>
      </ul>
    </body>
  </html>
```

## Author

Timothy Totten, supernovus on #perl6, https://github.com/supernovus/

### Note

The XML::Grammar library was originally based on the now defunct
[XML::Grammar::Document](http://github.com/krunen/xml) library,
but modified to work with Rakudo 'ng' and later 'nom', 
with other changes specific to the Exemel model.

## License

[Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0)

