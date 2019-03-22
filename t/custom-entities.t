#!/usr/bin/env perl6

use XML::Entity;
use Test;

plan 2;

my $raw = 'Text with a &customEntity;';
my $decoded = 'Text with a Custom Entity!';

my $ce = XML::Entity.new;
$ce.add('customEntity' => 'Custom Entity!');

my $out = $ce.decode($raw);

is $out, $decoded, 'Decoded custom entity';

my $out2 = $ce.encode($out);

is $out2, $raw, '(Re)-Encoded custom entity';

