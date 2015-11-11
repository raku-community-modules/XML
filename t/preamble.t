#!/usr/bin/env perl6

#BEGIN { @*INC.unshift: './lib'; }

use Test;
use XML;

plan 6;

my $text;

my $xml;
my $head = '<?xml version="1.0"?>';	## the default preamble (to use for no preamble tests

$text = '<?xml version="1.0"?><test><title>The title</title><bullocks><item name="first"/><item name="second"/></bullocks></test>';

$xml = from-xml($text); #XML::Document.new($text);

ok $xml ~~ XML::Document, 'String with preamble parsed properly.';
is $xml.version, '1.0', 'Read version is correct';
is $xml, $text, 'With preamble Raw xml is correct';


$text = '<test><title>The title</title><bullocks><item name="first"/><item name="second"/></bullocks></test>';

$xml = from-xml($text); #XML::Document.new($text);

ok $xml ~~ XML::Document, 'String without preamble parsed properly.';
is $xml.version, '1.0', 'Default version is correct';
is $xml, $head~$text, 'Without preamble Raw xml is correct';

