#!/usr/bin/env perl6

#BEGIN { @*INC.unshift: './lib'; }

use XML;
use Test;

plan 3;

my $xml = from-xml-file('./t/example.xml');

is $xml[1]<en> ~ ' ' ~ $xml[1][0], 'hello world', 'first get';
is $xml[3][5][0], 'Maybe', 'second get';

$xml[3].append('item', 'Never mind');

is $xml[3][9], '<item>Never mind</item>', 'append';
