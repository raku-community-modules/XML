unit class XML::Entity;

## A class for working with XML entities.

## A quick sub that uses only the default XML entities.
sub decode-xml-entities (Str $in, :$numeric=True) is export
{
  XML::Entity.new.decode($in, :$numeric);
}

has @.entityNames is rw = ['&amp;','&lt;','&gt;','&quot;','&apos;'];
has @.entityValues is rw = ['&','<','>',q{"},q{'}];

## Decode registered XML entitites.
method decode (Str $in, :$numeric=False)
{
  my $out = $in.trans(@.entityNames => @.entityValues);
  if ($numeric)
  {
    $out.=subst(/'&#' $<dec>=[<digit>+] ';'/, { $<dec>.Int.chr; });
    $out.=subst(/'&#x' $<hex>=[<xdigit>+] ';'/, { :16($<hex>).chr; });
  }
  return $out;
}

## Encode named XML entities.
## Currently does not support numeric entities.
method encode (Str $in)
{
  $in.trans(@.entityValues => @.entityNames);
}

## Add a custom entity.
multi method add (Str $name is copy, Str $value)
{
  if !$name.match(/^'&'/)
  {
    $name = '&'~$name;
  }
  if !$name.match(/';'$/)
  {
    $name ~= ';';
  }
  @.entityNames.push($name);
  @.entityValues.push($value);
}

multi method add (Pair $pair)
{
  self.add($pair.key, $pair.value);
}

