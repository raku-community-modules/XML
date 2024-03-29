#!/usr/bin/env raku

#use lib 'lib';

use Test;
use XML;

plan 32;

my $text = slurp('./t/query.xml');

#say "We're starting the parse";

my $xml = XML::Element.new($text);

ok $xml ~~ XML::Element, 'Element parsed properly.';

#say "We made it past parse";

#say "XML == $xml";

my @items = $xml.nodes[3].elements();

is @items.elems, 2, 'elements() returns correct number.';
is @items[0].attribs<name>, 'first', 'elements() returns proper data.';

@items = $xml.nodes[3].elements(:TAG<item>, :name<second>);

is @items.elems, 1, 'elements() with query, returns correct number.';
is @items[0].name, 'item', 'elements() with query, returns proper tag.';
is @items[0].attribs<name>, 'second', 'elements() with query, returns proper data.';

## TODO: fix comments parsing, and move comments into their own test file.
#my @comments = $xml.nodes[2].comments();

#is @comments.elems, 3, 'comments() returns correct number.';
#is @comments[0].data, ' Another comment ', 'comments() returns proper data.';

my @text = $xml.nodes[1].contents();

is @text.elems, 1, 'contents() returns correct number.';
is @text[0].string, 'The title', 'contents().string() returns proper data.';

@text = $xml.nodes[5].contents();

is @text.elems, 3, 'contents() with mixed data, returns correct number.';
is @text[2].string, '.', 'contents() with mixed data, returns proper data.';

is $xml.nodes[5].contents[1].string, 'Now it works. Bloody', 'direct query on contents works.';

my $byid = $xml.getElementById('hi');

#say $byid;

ok $byid ~~ XML::Element, 'getElementById() returns an element.';
is $byid.attribs<href>, 'hello world', 'getElementById() returned proper element.';

$xml.idattr = 'name';
$byid = $xml.getElementById('first');

ok $byid ~~ XML::Element, 'getElementById() with custom idattr returns an element.';
is $byid.name, 'item', 'custom idattr returns proper element tag.';
is $byid.attribs<name>, 'first', 'custom idattr returns proper element.';

my $parent = $byid.parent;

is $parent.name, 'bullocks', 'parent returns proper item.';

@items = $xml.getElementsByTagName('item');
is @items.elems, 2, 'getElementsByTagName returned proper number.';
is @items[0]<name>, 'first', 'getElementsByTagName returned proper values.';

my $subxml = $xml.getElementsByTagName('item', :object);
ok $subxml ~~ XML::Element, 'object query returns XML::Element';
is $subxml.nodes.elems, 2, 'object query returned proper number of elements';
is $subxml.name, 'test', 'object query used proper tag name.';
is $subxml, '<test><item name="first"/><item name="second"/></test>',
  'object query returned proper XML output.';

$subxml = $xml.elements(:TAG<a>, :RECURSE, :SINGLE);
ok $subxml ~~ XML::Element, "found an element with elements(:TAG<a>,:RECURSE, :SINGLE)";
ok $subxml.name eq "a", "The returned element is <a>";

$subxml = $xml.lookfor(:TAG<a>, :SINGLE);
ok $subxml ~~ XML::Element, "found an element with lookfor(:TAG<a>, :SINGLE)";

$subxml = $xml.lookfor(:TAG<multi>, :SINGLE);
@items = $subxml.lookfor(:TAG<option>, :!class);
is +@items, 1, "found an element with attribute missing";
is @items[0].attribs<name>, "m2", "no attribute got us proper element";

@items = $subxml.lookfor(:TAG<option>, :class(Nil | "skip"));
is +@items, 2, "a junction matcher gives us all expected elements";
is-deeply @items.map(*.attribs<name>).List, <m1 m2>, "only expected elements are given";

@items = $subxml.lookfor(:TAG<option>, :class{ !(.defined && .contains("skip")) });
is +@items, 2, "a code matcher gives us all expected elements";
is-deeply @items.map(*.attribs<name>).List, <m2 m3>, "only expected elements are given";
