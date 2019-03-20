#!/usr/bin/env perl6

use XML;
use Test;

plan 2;

my $raw = 'A text node with &lt;entities&gt; &amp; stuff &quot;';
my $decoded = 'A text node with <entities> & stuff "';

my $xml = from-xml-file('./t/entities.xml');
my $textNode = $xml.root[0];
is $textNode.text, $raw, 'Text.text is correct';
is $textNode.string, $decoded, 'Text.string is correct';
