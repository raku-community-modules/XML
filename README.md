# Exemel: An Object-Oriented XML Framework for Perl 6

## Introduction

Exemel is a full fledged XML library for Perl 6.

It handles parsing, generating, manipulating and querying XML.
It supports element queries, parent element information, namespaces,
and an extendable interface.

It supports every major kind of XML Node:

 * Document
 * Element
 * Text
 * Comment
 * PI
 * CDATA

You can easily serialize the objects back to XML text by using an Exemel 
object in a string context.

## Examples

I'm planning to add some nice examples in here, but for now, 
see the tests in t/ to get a good idea of how the library works.

## TODO

### Add more DOM-like methods

I want to make Exemel easy to use for people used to the DOM.
To that end, in addition to the current Perl-like methods, there should be
as many of the DOM elements as possible.

### Add [] and {} postfix methods to Exemel::Element

Basically I want:

```perl
  my $name = $xml[1]<name>;
```

to do the same thing as:

```perl
  my $name = $xml.nodes[1].attribs<name>;
```

Look at using Proxy, to support setters using this syntax too.

Also, using the [] and {} calls on an Exemel::Document, should pass the
calls onto the root Element. For that matter add a handles rule for
'attribs' and 'nodes' to proxy them to the root Element too.

### Add documentation

The Exemel library needs better documentation of its classes, methods, and
the exported 'from-xml' method.

### Add Exemel::Query

You can associate any Exemel::Element or Exemel::Document object with a query:

```perl
  my $xq = Exemel::Query($xml);
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

### Add Exemel::Formatter

Enable pretty printing, and more, all with flexible rules.

```perl
  my $xf = Exemel::Formatter.new(
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

The Exemel::Grammar library was originally based on the 
[XML::Grammar::Document](http://github.com/krunen/xml) 
but modified to work with Rakudo 'ng' and later 'nom', 
with other changes specific to the Exemel model.

## License

[Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0)

