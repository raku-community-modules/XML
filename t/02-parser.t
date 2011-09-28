#!/usr/bin/env perl6

BEGIN { @*INC.unshift: './lib'; }

use Test;
use Exemel;

plan 8;

my $text = '<test><title>The title</title><bullocks><item name="first"/><item name="second"/></bullocks></test>';

my $xml = Exemel::Document.parse($text);
my $head = '<?xml version="1.0"?>';

is $xml.root.name, 'test', 'root name parsed';
$*ERR.say: "XML: $xml";
is $xml.root.nodes[0].nodes[0], 'The title', 'text node parsed';
is $xml.root.nodes[1].nodes[0].attribs<name>, 'first', 'attribute 1 parsed';
is $xml.root.nodes[1].nodes[1].attribs<name>, 'second', 'attribute 2 parsed';
is $xml, $head~$text, 'parsed back to xml';

$xml.root.append-xml('<bogus value="false"/>');

is $xml.root.nodes[2].attribs<value>, 'false', 'insert-xml worked';

$text ~~ s/'</test>'/<bogus value="false"\/><\/test>/;

is $xml, $head~$text, 'parsed back after set';

$xml.root.nodes[2].unset('value');
$text ~~ s/'<bogus value="false"/>'/<bogus\/>/;

is $xml, $head~$text, 'parsed back after unset';

