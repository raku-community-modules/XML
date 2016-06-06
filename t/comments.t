#!/usr/bin/env perl6

#use lib 'lib';

use XML;
use Test;

plan 1;

my $xml = from-xml-file('./t/comments.xml');

ok 1;
