use XML::Node;

## XML::Text - represents a text node.
## The original text is stored in the 'text' attribute, and is
## preserved in its original format, including whitespace.
## The default stringification removes extra whitespace, and chomps
## the string. If this is not what you expect, call .text directly.
class XML::Text does XML::Node
{
  has $.text;
  method Str (:$strip)
  {
    my $text = $.text;
    $text ~~ s:g/\s+/ /;  ## Relace multiple whitespace with a single space.
    if $strip
    {
        $text ~~ s:g/\s+$//;  ## Chop out trailing spaces.
        $text ~~ s:g/^\s+//;  ## Chop out leading spaces.
    }
    $text.=chomp;         ## Remove a trailing newline if it exists.
    return $text;
  }
  method string ()
  {
    return self.Str(:strip);
  }
}

