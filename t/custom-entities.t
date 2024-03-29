#!/usr/bin/env raku

use XML;
use XML::Entity;
use Test;

plan 3;

my $raw = 'A text node with a &customEntity;';
my $decoded = 'A text node with a Custom Entity!';

my $ce = XML::Entity.new;
$ce.add('customEntity' => 'Custom Entity!');

my $xml = from-xml-file('./t/custom-entities.xml');
my $textNode = $xml.root[0];
is $textNode.text, $raw, 'Text.text is correct';

my $out = $textNode.string($ce);

is $out, $decoded, 'Text.string() with Custom entities is correct.';

my $out2 = $ce.encode($out);

is $out2, $raw, 'Re-encoded custom entity correctly.';

