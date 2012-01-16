use v6;

BEGIN { @*INC.unshift: './lib'; }

use Exemel;

my $doc = '<test><element1 attrib1="hello" attrib2="world"/><element2 attrib1="goodbye" attrib2="universe">with content</element2><element3 what="is it"><foo/></element3></test>';

say "Here's the doc, in text form, before parsing:";

say $doc;

my $xml = Exemel::Document.parse($doc);

say "Now, here's the doc, after being parsed into an object.";

say $xml;

say "Now, what happened to the attributes for the element with contents?";
