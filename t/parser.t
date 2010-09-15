#!/usr/bin/env perl6

BEGIN { @*INC.push: './lib'; }

use Test;
use Exemel;

plan 5;

my $text = '<test><title>The title</title><bullocks><item name="first"/><item name="second"/></bullocks></test>';

my $xml = Exemel::Document.parse($text);

is $xml.root.name, 'test', 'root name parsed';
is $xml.root.nodes[0].nodes[0], 'The title', 'text node parsed';
is $xml.root.nodes[1].nodes[0].attribs<name>, 'first', 'attribute 1 parsed';
is $xml.root.nodes[1].nodes[1].attribs<name>, 'second', 'attribute 2 parsed';
is $xml, '<?xml version="1.0"?>'~$text, 'parsed back to xml';

