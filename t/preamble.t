#!/usr/bin/env perl6

#BEGIN { @*INC.unshift: './lib'; }

use Test;
use XML;

plan 18;

my $text;
my $text2;

my $xml;
my $head = '<?xml version="1.0"?>';	## the default preamble (to use for no preamble tests

$text = '<?xml version="1.0"?><test><title>The title</title><bullocks><item name="first"/><item name="second"/></bullocks></test>';

$xml = from-xml($text); #XML::Document.new($text);

ok $xml ~~ XML::Document, 'String with preamble parsed properly.';
is $xml.version, '1.0', 'Read version is correct';
is ~$xml, $text, 'With preamble Raw xml is correct';


$text = '<test><title>The title</title><bullocks><item name="first"/><item name="second"/></bullocks></test>';

$xml = from-xml($text); #XML::Document.new($text);

ok $xml ~~ XML::Document, 'String without preamble parsed properly.';
is $xml.version, '1.0', 'Default version is correct';
is ~$xml, $head~$text, 'Without preamble Raw xml is correct';

$text = '<?xml version="1.0" encoding="UTF-8"?><test><title>The title</title><bullocks><item name="first"/><item name="second"/></bullocks></test>';

$xml = from-xml($text); #XML::Document.new($text);

ok $xml ~~ XML::Document, 'String with preamble and encoding parsed properly.';
is $xml.version, '1.0', 'Read version  on xml with encoding is correct';
is $xml.encoding, 'UTF-8', 'Read encoding is correct';
is ~$xml, $text, 'With preamble and encoding xml is correct';


$text2 = q{<?xml version='1.0' encoding="UTF-8"?><test><title>The title</title><bullocks><item name="first"/><item name="second"/></bullocks></test>};

$xml = from-xml($text2); #XML::Document.new($text);

ok $xml ~~ XML::Document, 'String with preamble (s-q) and encoding parsed properly.';
is $xml.version, '1.0', 'Read version  on xml with encoding is correct';
is $xml.encoding, 'UTF-8', 'Read encoding is correct (version is sq)';
is ~$xml, $text, 'With preamble and encoding xml is correct (version is sq)'; ## need to check with $text with double quotes as that is what is emitted

$text2 = q{<?xml version='1.0' encoding='UTF-8'?><test><title>The title</title><bullocks><item name="first"/><item name="second"/></bullocks></test>};

$xml = from-xml($text2); #XML::Document.new($text);

ok $xml ~~ XML::Document, 'String with preamble (sq) and encoding (sq) parsed properly.';
is $xml.version, '1.0', 'Read version  on xml with encoding is correct (all sq)';
is $xml.encoding, 'UTF-8', 'Read encoding is correct (all sq)';
is ~$xml, $text, 'With preamble and encoding xml is correct (all sq)'; ## need to check with $text with double quotes as that is what is emitted

