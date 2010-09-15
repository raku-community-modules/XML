#!/usr/bin/env perl6

BEGIN { @*INC.push: './lib'; }

use Test;
use Exemel;
use Exemel::Query::Methods;

plan 8;

my $text = slurp('./t/query.xml');

my $xml = Exemel::Element.parse($text);

my @items = $xml.nodes[2].elements('item');

is @items.elems, 2, 'elements() returns correct number.';
is @items[0].attribs<name>, 'first', 'elements() returns proper data.';

my @comments = $xml.nodes[2].comments();

is @comments.elems, 3, 'comments() returns correct number.';
is @comments[0].data, ' Another comment ', 'comments() returns proper data.';

my @text = $xml.nodes[0].contents();

is @text.elems, 1, 'contents() returns correct number.';
is @text[0], 'The title', 'contents() returns proper data.';

@text = $xml.nodes[3].contents();

is @text.elems, 3, 'contents() with mixed data, returns correct number.';
is @text[2], '.', 'contents() with mixed data, returns proper data.';

