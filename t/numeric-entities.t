#!/usr/bin/env perl6

use XML::Entity;
use Test;

plan 3;

my $input = '&#126;&#x07e;';
my $want-decoded = '~~';
my $want-encoded1 = '&#126;&#126;';
my $want-encoded2 = '&#x7E;&#x7E;';

my $decoded = decode-xml-entities($input, :numeric);
is $decoded, $want-decoded, 'decode-xml-entity(:numeric) works.';

my $encoded1 = encode-xml-entities($decoded, 126);
is $encoded1, $want-encoded1, 'encode-xml-entity(:numeric) works.';

my $encoded2 = encode-xml-entities($decoded, 126, :hex);
is $encoded2, $want-encoded2, 'encode-xml-entity(:numeric, :hex) works.';
