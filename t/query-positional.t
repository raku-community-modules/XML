#!/usr/bin/env perl6

#BEGIN { @*INC.unshift: './lib'; }

use Test;
use XML;

plan 32;

my $xml = from-xml-file('./t/test1.xml');

my $two = $xml.elements(:POS(1));

ok $two ~~ XML::Element, ':POS(1) returned a single element.';

is $two<id>, 'two', 'Correct element returned';

my @odd = $two.elements(:ODD);

is @odd.elems, 2, ':ODD returned proper number of elements.';

is @odd[0]<id>, 'two.1', 'First :ODD element is correct.';
is @odd[1]<id>, 'two.3', 'Second :ODD element is correct.';

my @even = $two.elements(:EVEN);

is @even.elems, 2, ':EVEN returned proper number of elements.';

is @even[0]<id>, 'two.2', 'First :EVEN element is correct.';
is @even[1]<id>, 'two.4', 'Second :EVEN element is correct.';

@odd = $two.elements(:ODD, :BYINDEX);

is @odd[0]<id>, 'two.2', 'First :ODD, :BYINDEX element is correct.';
is @odd[1]<id>, 'two.4', 'Second :ODD, :BYINDEX element is correct.';

@even = $two.elements(:EVEN, :BYINDEX);

is @even[0]<id>, 'two.1', 'First :EVEN, :BYINDEX element is correct.';
is @even[1]<id>, 'two.3', 'Second :EVEN, :BYINDEX element is correct.';

my @not-two = $xml.elements(:NOTPOS(1));

is @not-two.elems, 2, ':NOTPOS(1) returned proper number of elements.';

is @not-two[0]<id>, 'one', 'First :NOTPOS(1) element is correct.';
is @not-two[1]<id>, 'three', 'Second :NOTPOS(1) element is correct.';

@not-two = $xml.elements(:POS(* != 1));

is @not-two.elems, 2, ':POS(* != 1) returned proper number of elements.';

is @not-two[0]<id>, 'one', 'First :POS(* != 1) element is correct.';
is @not-two[1]<id>, 'three', 'Second :POS(* != 1) element is correct.';

my @gt-one = $xml.elements(:POS(* > 0));

is @gt-one.elems, 2, ':POS(* > 0) returned proper number of elements.';

is @gt-one[0]<id>, 'two', 'First :POS(* > 0) element is correct.';
is @gt-one[1]<id>, 'three', 'Second :POS(* > 0) element is correct.';

my $first = $two.elements(:FIRST);

ok $first ~~ XML::Element, ':FIRST returned a single element.';

is $first<id>, 'two.1', ':FIRST returned correct element.';

my $last = $two.elements(:LAST);

ok $last ~~ XML::Element, ':LAST returned a single element.';

is $last<id>, 'two.4', ':LAST returned correct element.';

my @not-first = $two.elements(:!FIRST);

is @not-first.elems, 3, ':!FIRST returned correct number of elements.';
is @not-first[0]<id>, 'two.2', ':!FIRST returned proper elements.';

my @not-last = $two.elements(:!LAST);

is @not-last.elems, 3, ':!LAST returned correct number of elements.';
is @not-last[@not-last.end]<id>, 'two.3', ':!LAST returned proper elements.';

my @two-to-three = $two.elements(:POS(1..2));

is @two-to-three.elems, 2, ':POS(1..2) returns correct number of elements.';
is @two-to-three[0]<id>, 'two.2', 'First :POS(1..2) element is correct.';
is @two-to-three[1]<id>, 'two.3', 'Second :POS(1..2) element is correct.';

