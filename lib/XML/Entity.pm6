unit class XML::Entity;

## An extremely simple class right now.
## I'd like to expand it further at some point.

sub decode-entities (Str $in) is export
{
  return $in.trans(
  [
    '&amp;',
    '&lt;',
    '&gt;',
    '&quot;',
    '&apos;',
  ] => [
    '&',
    '<',
    '>',
    q{"},
    q{'},
  ]).subst(/'&#' $<dec>=[<digit>+] ';'/, { $<dec>.Int.chr; }).subst(/'&#x' $<hex>=[<xdigit>+] ';'/, { :16($<hex>).chr; });
}
