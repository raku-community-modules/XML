unit class XML::Entity;

## A class for working with XML entities.

## A quick sub that uses only the default XML entities.
sub decode-xml-entities(Str $in, Bool :$numeric) is export {
    XML::Entity.new.decode($in, :$numeric)
}

## A quick sub to encode default XML entities.
sub encode-xml-entities(Str $in, Bool :$hex, *@numeric) is export {
    XML::Entity.new.encode($in, :$hex, |@numeric)
}

has @.entityNames is rw = ['&amp;','&lt;','&gt;','&quot;','&apos;'];
has @.entityValues is rw = ['&','<','>',q{"},q{'}];

## Decode registered XML entitites.
method decode(Str $in, Bool :$numeric=False) {
    my $out = $in.trans(@.entityNames => @.entityValues);
    if $numeric {
        $out.=subst(/'&#' $<dec>=[<digit>+] ';'/, { $<dec>.Int.chr; }, :g);
        $out.=subst(/'&#x' $<hex>=[<xdigit>+] ';'/, { :16(~$<hex>).chr; }, :g);
    }
    $out
}

## Encode named XML entities.
## You can pass an array of numeric entities to encode.
method encode(Str $in, Bool :$hex, *@numeric) {
    my $out = $in.trans(@.entityValues => @.entityNames);
    for @numeric -> $code {
        my $char = $code.chr;
        my $replacement;
        if $hex {
            $replacement = '&#x'~$code.base(16)~';';
        }
        else {
            $replacement = '&#'~$code~';';
        }
        $out.=subst($char, $replacement, :g);
    }
    $out
}

## Add a custom entity.
multi method add(Str $name is copy, Str $value) {
    if !$name.match(/^'&'/) {
        $name = '&'~$name;
    }
    if !$name.match(/';'$/) {
        $name ~= ';';
    }
    @.entityNames.push($name);
    @.entityValues.push($value);
}

multi method add (Pair $pair) {
    self.add($pair.key, $pair.value);
}

# vim: expandtab shiftwidth=4
