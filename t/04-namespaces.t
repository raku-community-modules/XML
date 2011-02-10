#!/usr/bin/env perl6

BEGIN { @*INC.unshift: './lib'; }

use Test;
use Exemel;

plan 8;

## This should be in its own test, but for now this will do.
my $xml = Exemel::Document.load('./t/namespaces.xml');

ok $xml ~~ Exemel::Document, 'Exemel::Document.load() works';

## Now, let's do the real namespace tests.
my $myns = $xml.root.getNamespacePrefix('http://ns.z4y.net/example/1.0');

is $myns, 'ex', 'getNamespacePrefix returns proper value.';

my @items = $xml.root.elements(:NS($myns), :RECURSE(1));

is @items.elems, 2, 'elements(:NS) returns correct number.';
is @items[0].attribs<name>, 'first', 'elements(:NS) returns proper data.';

my $parent = @items[0].parent;

is $parent.name, 'bullocks', 'parent returns proper element.';

## Next, the default namespace.

$myns = $xml.root.getNamespacePrefix('http://ns.z4y.net/test');

is $myns, '', 'getNamespacePrefix handles default namespace.';

@items = $xml.root.elements(:NS($myns), :RECURSE(1), :NEST(1));

is @items.elems, 4, 'elements(:NS) with default namespace, correct count.';
is @items[3].contents, 'A nested item, oh boy.', 'default namespace, correct content.';


