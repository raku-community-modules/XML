#!/usr/bin/env perl6

use v6;

use Test;
use XML;

plan 1;

my $xml = make-xml('test', :type<embedded>,
  \('hello', :lang<en>, "world"),
  \('aurevoir', :lang<fr>, "univers")
);

is ~$xml, '<test type="embedded"><hello lang="en">world</hello><aurevoir lang="fr">univers</aurevoir></test>', 'make-xml worked.';
