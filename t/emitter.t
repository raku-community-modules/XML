#!/usr/bin/env perl6

#BEGIN { @*INC.unshift: './lib'; }

use Test;
use XML;

plan 5;

my $xml = XML::Element.new(:name<test>);
$xml.append: XML::Element.new(:name<title>, :nodes(['The title']));
$xml.append: XML::Element.new(:name<bullocks>, :nodes((
  XML::Element.new(:name<item>, :attribs({:name<first>})),
  XML::Element.new(:name<item>, :attribs({:name<second>})),
)));

is $xml.nodes[1].nodes[0].attribs<name>, 'first', 'attribute 1 passed';
is $xml.nodes[1].nodes[1].attribs<name>, 'second', 'attribute 2 passed';

my $text = '<test><title>The title</title><bullocks><item name="first"/><item name="second"/></bullocks></test>';

is $xml, $text, 'element serialized properly';

$xml.nodes[0].set('alt', 'Alternate text');
$xml.nodes[1].set('standalone', True);

$text ~~ s/'<title>'/<title alt="Alternate text">/;
$text ~~ s/'<bullocks>'/<bullocks standalone="standalone">/;

is $xml.nodes[1].attribs<standalone>, 'standalone', 'set using Boolean.';
is $xml, $text, 'element after set serialized properly';

