#!/usr/bin/env perl6

#use lib 'lib';

use Test;
use XML;

plan 11;

my $doc = from-xml-file('./t/query.xml');

ok $doc ~~ XML::Document, 'from-xml-file works.';

my $xml = $doc.root;

is $xml[1][0].string, 'The title', 'Postcircumfix lookup of Text node works.';
is $xml[3][1]<name>, 'first', 'Postcircumfix lookup of Attribute works.';

is $doc.nodes[1].nodes[0].string, 'The title', '.nodes on doc works';
is $doc[3][3]<name>, 'second', 'Postcircumfix [] on doc works.';

lives-ok { $doc<id> = 'default' }, 'Write through postcircumfix {}';

is $xml.attribs<id>, 'default', 'Postcircumfix {} on doc works.';

is $doc.attribs<id>, 'default', '.attribs on doc works.';

lives-ok { $doc[1] = XML::Text.new(:text("The new title")) }, 'Write through postcircumfix []';

is $xml.nodes[1].string, "The new title", 'Postcircumfix [] on doc works after write.';

is $doc.nodes[1].string, "The new title", '.nodes on doc works after write.';
