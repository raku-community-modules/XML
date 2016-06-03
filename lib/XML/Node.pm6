role XML::Node
{
  has $.parent is rw;

  ## For XML classes, the gist is the stringified form.
  multi method gist (XML::Node:D:)
  {
    return self.Str();
  }

  method previousSibling ()
  {
    if $.parent ~~ ::(q<XML::Element>)
    {
      my $pos = $.parent.index-of(* === self);
      if $pos > 0
      {
        return $.parent.nodes[$pos-1];
      }
    }
    return Nil;
  }

  method nextSibling ()
  {
    if $.parent ~~ ::(q<XML::Element>)
    {
      my $pos = $.parent.index-of(* === self);
      if $pos < $.parent.nodes.end
      {
        return $.parent.nodes[$pos+1];
      }
    }
    return Nil;
  }

  method remove ()
  {
    if $.parent ~~ ::(q<XML::Element>)
    {
      $.parent.removeChild(self);
    }
    return self;
  }

  method reparent (::(q<XML::Element>) $parent)
  {
    self.remove;
    $.parent = $parent;
    return self;
  }

  method cloneNode ()
  {
    return self.clone;
  }

  method ownerDocument ()
  {
    if $.parent ~~ ::(q<XML::Document>)
    {
      return $.parent;
    }
    elsif $.parent ~~ ::(q<XML::Node>)
    {
      return $.parent.ownerDocument;
    }
    else
    {
      return Nil;
    }
  }
}
