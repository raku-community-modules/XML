#!/usr/bin/env perl6

BEGIN { @*INC.unshift: './lib'; }

use Test;
use Exemel;

plan 18;

my $text = slurp('./t/query.xml');

#say "We're starting the parse";

my $xml = Exemel::Element.parse($text);

ok $xml ~~ Exemel::Element, 'Element parsed properly.';

#say "We made it past parse";

#say "XML == $xml";

my @items = $xml.nodes[1].elements();

is @items.elems, 2, 'elements() returns correct number.';
is @items[0].attribs<name>, 'first', 'elements() returns proper data.';

@items = $xml.nodes[1].elements(:TAG<item>, :name<second>);

is @items.elems, 1, 'elements() with query, returns correct number.';
is @items[0].name, 'item', 'elements() with query, returns proper tag.';
is @items[0].attribs<name>, 'second', 'elements() with query, returns proper data.';

## TODO: fix comments parsing, and move comments into their own test file.
#my @comments = $xml.nodes[2].comments();

#is @comments.elems, 3, 'comments() returns correct number.';
#is @comments[0].data, ' Another comment ', 'comments() returns proper data.';

my @text = $xml.nodes[0].contents();

is @text.elems, 1, 'contents() returns correct number.';
is @text[0], 'The title ', 'contents() returns proper data.';
is @text[0].string, 'The title', 'contents().string() returns proper data.';

@text = $xml.nodes[2].contents();

is @text.elems, 3, 'contents() with mixed data, returns correct number.';
is @text[2].string, '.', 'contents() with mixed data, returns proper data.';

is $xml.nodes[2].contents[1], 'Now it works. Bloody ', 'direct query on contents works.';

my $byid = $xml.getElementById('hi');

#say $byid;

ok $byid ~~ Exemel::Element, 'getElementById() returns an element.';
is $byid.attribs<href>, 'hello world', 'getElementById() returned proper element.';

$xml.idattr = 'name';
$byid = $xml.getElementById('first');

ok $byid ~~ Exemel::Element, 'getElementById() with custom idattr returns an element.';
is $byid.name, 'item', 'custom idattr returns proper element tag.';
is $byid.attribs<name>, 'first', 'custom idattr returns proper element.';

my $parent = $byid.parent;

is $parent.name, 'bullocks', 'parent returns proper item.';

