#!/usr/bin/env perl6

#BEGIN { @*INC.unshift: './lib'; }

use XML;
use Test;

plan 3;

my $xml = from-xml-file('./t/example.xml');

is $xml[0]<en> ~ ' ' ~ $xml[0][0], 'hello world', 'first get';
is $xml[1][2][0], 'Maybe', 'second get';

$xml[1].append('item', 'Never mind');

is $xml[1][4], '<item>Never mind</item>', 'append';

