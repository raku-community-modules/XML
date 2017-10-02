#!/usr/bin/env perl6

use Test;
use XML;

plan 1;

my $xml1 = from-xml('<test ATTRIB="&quot;text&quot;"></test>');

lives-ok { from-xml($xml1.Str) };
