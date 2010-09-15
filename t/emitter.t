#!/usr/bin/env perl6

BEGIN { @*INC.push: './lib'; }

use Test;
use Exemel;

plan 3;

my $xml = Exemel::Element.new(:name<test>);
$xml.append: Exemel::Element.new(:name<title>, :nodes(['The title']));
$xml.append: Exemel::Element.new(:name<bullocks>, :nodes((
  Exemel::Element.new(:name<item>, :attribs({:name<first>})),
  Exemel::Element.new(:name<item>, :attribs({:name<second>})),
)));

is $xml.nodes[1].nodes[0].attribs<name>, 'first', 'attribute 1 passed';
is $xml.nodes[1].nodes[1].attribs<name>, 'second', 'attribute 2 passed';

my $text = '<test><title>The title</title><bullocks><item name="first"/><item name="second"/></bullocks></test>';

is $xml, $text, 'element serialized properly';

