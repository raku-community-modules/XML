#!/usr/bin/env raku

use XML;
use XML::Entity;
use Test;

plan 4;

my $raw = 'A text node with &lt;entities&gt; &amp; stuff &quot;';
my $decoded = 'A text node with <entities> & stuff "';

my $xml = from-xml-file('./t/entities.xml');
my $textNode = $xml.root[0];
is $textNode.text, $raw, 'Text.text is correct';
is $textNode.string, $decoded, 'Text.string is correct';

my $out = decode-xml-entities($raw);
is $out, $decoded, 'decode-xml-entities works';

my $reinc = encode-xml-entities($out);
is $reinc, $raw, 'encode-xml-entities works';

