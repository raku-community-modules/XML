#!/usr/bin/env perl6

#use lib 'lib';

use Test;
use XML;

plan 13;

my $text = '<test><title>The title</title><bullocks><item name="first"/><item name="second"/></bullocks></test>';

my $xml = from-xml($text); #XML::Document.new($text);
my $head = '<?xml version="1.0"?>';

ok $xml ~~ XML::Document, 'Document parsed properly.';

is $xml.root.name, 'test', 'root name parsed';
#$*ERR.say: "XML: $xml";
is $xml.root.nodes[0].nodes[0], 'The title', 'text node parsed';
is $xml.root.nodes[1].nodes[0].attribs<name>, 'first', 'attribute 1 parsed';
is $xml.root.nodes[1].nodes[1].attribs<name>, 'second', 'attribute 2 parsed';
is $xml, $head~$text, 'parsed back to xml';

$xml.root.append-xml('<bogus value="false"/>');

is $xml.root.nodes[2].attribs<value>, 'false', 'append-xml worked';

$text ~~ s/'</test>'/<bogus value="false"\/><\/test>/;

is $xml, $head~$text, 'parsed back after set';

$xml.root.nodes[2].unset('value');
$text ~~ s/'<bogus value="false"/>'/<bogus\/>/;

is $xml, $head~$text, 'parsed back after unset';

$text = "<elem attr1='foo' attr2='bar'></elem>";
$xml = from-xml($text);
is $xml.root.attribs<attr1>, 'foo', 'got single-quoted attribute';

# Test available identifiers.

lives-ok { from-xml('<foo><bar id1-1paté="bat" /></foo>') }, 'valid attribute name';
dies-ok  { from-xml('<foo><bar 2d="bar" /></foo>') }, 'invalid attribute name';

my $numdoc = from-xml('<foo><bar-1>baz</bar-1></foo>');

is $numdoc.root[0].name, 'bar-1', 'parsed tag name with number';
