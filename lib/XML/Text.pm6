use XML::Node;
use XML::Entity;

## XML::Text - represents a text node.
## The original text is stored in the 'text' attribute, and is
## preserved in its original format, including whitespace and entities.
## The default stringification removes extra whitespace, and chomps
## the string. If this is not what you expect, call .text directly.
class XML::Text does XML::Node
{
  has $.text;
  method Str (XML::Entity :$decode, Bool :$min, Bool :$strip, Bool :$chomp)
  {
    my $text = $.text;
    if $decode
    { ## Decode the entities.
      $text = $decode.decode($text);
    }
    if $min
    { ## Relace multiple whitespace with a single space.
      $text ~~ s:g/\s+/ /;  
    }
    if $strip
    { ## Strip leading and trailing whitespace.
        $text ~~ s:g/\s+$//;  ## Chop out trailing spaces.
        $text ~~ s:g/^\s+//;  ## Chop out leading spaces.
    }
    if $chomp
    {
      $text.=chomp;         ## Remove a trailing newline if it exists.
    }
    return $text;
  }
  method string (XML::Entity $decode=XML::Entity.new)
  {
    return self.Str(:$decode, :min, :strip, :chomp);
  }
}

