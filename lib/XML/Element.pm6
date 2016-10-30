use XML::Node;
use XML::Text;
use XML::Comment;
use XML::PI;
use XML::CDATA;

class XML::Element does XML::Node
{
  use XML::Grammar;
  has $.name    is rw;         ## We may want to change element type.
  has @.nodes   is rw;         ## Cloning requires rw.
  has %.attribs is rw;         ## Cloning requires rw.
  has $.idattr  is rw = 'id';  ## Default id attribute is, well, 'id'.

  method cloneNode ()
  {
    my $clone = self.new;
    $clone.name = $.name;
    $clone.idattr = $.idattr;
    $clone.attribs = %.attribs.clone;
    $clone.nodes = [];
    loop (my $i=0; $i < @.nodes.elems; $i++)
    {
      if (@.nodes[$i] ~~ XML::Node)
      {
        $clone.nodes[$i] = @.nodes[$i].cloneNode;
        $clone.nodes[$i].parent = $clone;
      }
      else
      {
        $clone.nodes[$i] = @.nodes[$i].clone;
      }
    }
    return $clone;
  }

  multi method insert (XML::Node $node)
  {
    @.nodes.unshift: $node.reparent(self);
  }

  multi method append (XML::Node $node)
  {
    @.nodes.push: $node.reparent(self);
  }

  method index-of ($find)
  {
    loop (my $i=0; $i < @.nodes.elems; $i++)
    {
      my $cur = @.nodes[$i];
      if $cur ~~ $find
      {
        return $i;
      }
    }
    return False;
  }

  multi method before (XML::Node $existing, XML::Node $new, :$offset=0)
  {
    my $pos = self.index-of(* === $existing) + $offset;
    if $pos ~~ Int
    {
      @.nodes.splice($pos, 0, $new.reparent(self));
    }
  }

  method insertBefore (XML::Node $new, XML::Node $existing)
  {
    self.before($existing, $new);
    return $new;
  }

  multi method after (XML::Node $existing, XML::Node $new, :$offset=1)
  {
    self.before($existing, $new, :$offset);
  }

  method insertAfter (XML::Node $new, XML::Node $existing)
  {
    self.after($existing, $new);
    return $new;
  }

  method replaceChild (XML::Node $new, XML::Node $existing)
  {
    my $pos = self.index-of(* === $existing);
    if $pos ~~ Int
    {
      return @.nodes.splice($pos, 1, $new.reparent(self));
    }
    else
    {
      return False;
    }
  }

  method replace (XML::Node $existing, XML::Node $new)
  {
    return self.replaceChild($new, $existing);
  }

  method removeChild (XML::Node $node)
  {
    my $pos = self.index-of(* === $node);
    if $pos ~~ Int
    {
      return @.nodes.splice($pos, 1);
    }
    else
    {
      return False;
    }
  }

  method firstChild ()
  {
    if @.nodes.elems > 0
    {
      return @.nodes[0];
    }
  }

  method lastChild ()
  {
    if @.nodes.elems > 0
    {
      return @.nodes[@.nodes.end];
    }
  }

  multi method before (XML::Node $node)
  {
    if $.parent ~~ XML::Element
    {
      $.parent.before(self, $node);
    }
  }

  multi method after (XML::Node $node)
  {
    if $.parent ~~ XML::Element
    {
      $.parent.after(self, $node);
    }
  }

  method !craft-new (Str $name, %attribs, @contents)
  {
    my $new = self.new(:$name);
    $new.set(|%attribs);
    for @contents -> $what
    {
      if $what ~~ XML::Node
      {
        $new.append($what);
      }
      elsif $what ~~ Capture
      { ## In the case of a Capture, pass it to craft().
        $new.append(self.craft(|$what));
      }
      elsif $what ~~ Str
      {
        my $text = XML::Text.new(:text($what));
        $new.append($text);
      }
      elsif $what.can('Str')
      {
        my $text = XML::Text.new(:text($what.Str));
        $new.append($text);
      }
    }
    return $new;
  }

  method craft (Str $name, *@contents, *%attribs)
  {
    return self!craft-new($name, %attribs, @contents);
  }

  multi method insert (Str $name, *@contents, *%attribs)
  {
    my $new = self!craft-new($name, %attribs, @contents);
    self.insert($new);
  }

  multi method append (Str $name, *@contents, *%attribs)
  {
    my $new = self!craft-new($name, %attribs, @contents);
    self.append($new);
  }

  multi method before (Str $name, *@contents, *%attribs)
  {
    my $new = self!craft-new($name, %attribs, @contents);
    self.before($new);
  }

  multi method after (Str $name, *@contents, *%attribs)
  {
    my $new = self!craft-new($name, %attribs, @contents);
    self.after($new);
  }

  multi method set (Str $attrib, $value)
  {
    given $value {
      when Bool {
        if $value
        {
          %.attribs{$attrib} = $attrib;
        }
        else
        {
          %.attribs{$attrib}:delete;
        }
      }
      when Str | Numeric {
        %.attribs{$attrib} = $value;
      }
      when .can('Str') {
        %.attribs{$attrib} = $value.Str;
      }
    }
  }

  multi method set (*%attribs)
  {
    for %attribs.kv -> $attrib, $value
    {
      self.set($attrib, $value);
    }
  }

  multi method unset (*@attribs) {
    for @attribs -> $attrib
    {
      %.attribs{$attrib}:delete;
    }
  }

  multi method unset (*%attribs)
  {
    self.unset(|%attribs.keys);
  }

  method is-bool (Str $attrib)
  {
    return %.attribs{$attrib}:exists && %.attribs{$attrib} eq $attrib;
  }

# ck
  method add-values (Str $attrib, Set $values)
  {
    my $old_values = %.attribs{$attrib}.split(/\s+/).Set;
    my $new_values = $old_values (|) $values;
    %.attribs{$attrib} = $new_values.Str;
  }

# ck
  method delete-values (Str $attrib, Set $values)
  {
    my $old_values = %.attribs{$attrib}.split(/\s+/).Set;
    my $new_values = $old_values (-) $values;
    %.attribs{$attrib} = $new_values.Str;
  }

# ck
  method test-values (Str $attrib, @tests)
  {
    my $values = %.attribs{$attrib}.split(/\s+/).Set;
    my %result;
    for @tests -> $test
    {
      %result{$test} = $test (elem) $values;
    }
    return %result;
  }

  method insert-xml (Str $xml) {
    my $element = self.new($xml);
    self.insert: $element;
  }

  method append-xml (Str $xml) {
    my $element = self.new($xml);
    self.append: $element;
  }

  method before-xml (Str $xml)
  {
    my $element = self.new($xml);
    self.before: $element;
  }

  method after-xml (Str $xml)
  {
    my $element = self.new($xml);
    self.after: $element;
  }

  multi method new (Str $xml)
  {
    my $match = XML::Grammar.parse($xml);
    if ($match)
    {
      return self.parse-node($match<root>);
    }
    else
    {
      die "Could not parse XML passed to XML::Element.new()";
    }
  }

  method parse-node ($node, $mother?)
  {
    my $name = $node<name>.Str;
    my %attribs;
    my @nodes;

    if ($node<attribute>)
    {
      for @($node<attribute>) -> $a
      {
        my $an = ~$a<name>;
        my $av = $a<value><char>.list>>.ast.join // '';
        %attribs{$an} = $av;
      }
    }

    my $parent = XML::Element.new(:$name, :%attribs);

    if ($mother)
    {
      $parent.parent = $mother;
    }

    if ($node<child>)
    {
      for @($node<child>) -> $c
      {
        my $child;
        if ($c<cdata>)
        {
          my $data = ~$c<cdata><content>;
          $child = XML::CDATA.new(:$data, :$parent);
        }
        elsif ($c<comment>)
        {
          my $data = ~$c<comment><content>;
          $child = XML::Comment.new(:$data, :$parent);
        }
        elsif ($c<pi>)
        {
          my $data = ~$c<pi><content>;
          $child = XML::PI.new(:$data, :$parent);
        }
        elsif ($c<text>)
        {
          my $text = ~$c<text>;
          $child = XML::Text.new(:$text, :$parent);
        }
        elsif ($c<element>)
        {
          $child = self.parse-node($c<element>, $parent);
        }
        if defined $child
        {
          @nodes.push: $child;
        }
      }
    }
    $parent.nodes = @nodes;
    return $parent;
  }

  # elements()
  #   return all child elements
  #
  # elements(:TAG($tagname), :attrib1($value), ...)
  #   return all child elements that match the given query.
  #   If :TAG is specified, then the element tag must match.
  #   Any other parameter passed in the query is an attribute to match.
  #
  #  Eg.  @items = $form.elements(:TAG<input>, :type<checkbox>);
  #
  #   In addition to :TAG there is also :NS, which matches a namespace prefix.
  #
  # Eg.   @items = $doc.root.elements(:NS<tal>);
  #
  #   If you prefer to do your lookup by Namespace URI, you can use the
  #   URI method instead:
  #
  # Eg.   @items = $doc.root.elements(:URI<http://my.site.com/namespace/1.0>);
  #
  #  NOTE: NS and URI are not really compatible with TAG, as TAG needs to have
  #   the whole tag name, including prefix. This may change in the future.
  #
  #  There are three other 'special' keys that don't match attributes, but
  #  set rules for the elements query:
  #
  #    RECURSE   If set to a non-zero digit, child elements will also be
  #              searched for elements matching the queries. By default
  #              only non-matching elements will be searched (so only the
  #              top-most matching elements will be returned.)
  #
  #    NEST      If set to a positive value, the RECURSE option will apply to
  #              ALL child elements, including ones that have already matched
  #              the query and been added to the results.
  #
  #    SINGLE    If set to a positive value, elements will return only the
  #              first matching element. If no elements match it will return
  #              an empty array.
  #
  #    OBJECT    If set to a positive value, instead of returning an array
  #              of results, we will return a new XML::Element object with
  #              the same name the original, containing the matching nodes.
  #
  #    POS       Set to an integer, the element must be the nth child.
  #              If recurse is 0, or at max level, this forces SINGLE to True.
  #
  #    NOTPOS    The element is not the nth child.
  #
  #    FIRST     The element is the first child. The same rules apply as POS.
  #
  #    LAST      The element is the last child. The same rules apply as POS.
  #
  #    EVEN      The element is an even child.
  #
  #    ODD       The element is an odd child.
  #
  #    BYINDEX   If set to a True value, EVEN and ODD will be based on the
  #              position index (starts with 0) rather than the user idea of
  #              odd and even elements (starting with 1.)
  #
  
  method lookfor(*%query) {
    return self.elements(:RECURSE, |%query);
  }
  method elements (*%query)
  {
    my $recurse = 0;
    my $nest    = False;
    my $single  = False;
    my $object  = False;
    my $byindex = False;
    my @elements;
    my $nodepos = 0;

    if %query{'RECURSE'}:exists {
      $recurse = %query<RECURSE> if %query<RECURSE> ne True;
      $recurse = Inf if %query<RECURSE> eq True;
    }
    if %query{'NEST'}:exists    { $nest    = %query<NEST>;    }
    if %query{'SINGLE'}:exists  { $single  = %query<SINGLE>;  }
    if %query{'OBJECT'}:exists  { $object  = %query<OBJECT>;  }
    if %query{'BYINDEX'}:exists { $byindex = %query<BYINDEX>; }

    for @.nodes -> $node
    {
      if $node ~~ XML::Element
      {
        my $matched = True;
        for %query.kv -> $key, $val
        {
          if $key eq 'RECURSE' | 'NEST' | 'SINGLE' | 'OBJECT' | 'BYINDEX'
          {
            next;
          }
          elsif $key eq 'POS' | 'NOTPOS' | 'FIRST' | 'LAST'
          {
            my $want-atpos;
            my $pos;
            my $last = @.nodes.grep({$_ ~~ XML::Element}).end;

            my $one = False;

            given $key
            {
              when 'POS'
              {
                $want-atpos = True;
                $pos = $val;
                if $pos ~~ Int { $one = True; }
              }
              when 'NOTPOS'
              {
                $want-atpos = False;
                $pos = $val;
              }
              when 'FIRST'
              {
                $want-atpos = $val;
                $pos = 0;
                if $val { $one = True; }
              }
              when 'LAST'
              {
                $want-atpos = $val;
                $pos = $last;
                if $val { $one = True; }
              }
            }

            if
            (
              ( $want-atpos && $nodepos !~~ $pos )
              ||
              ( ! $want-atpos && $nodepos ~~ $pos )
            )
            {
              $matched = False;
              if $one && ! $recurse
              {
                $single = True;
              }
              last;
            }
          }
          elsif $key eq 'EVEN' | 'ODD'
          {
            my $pos = $nodepos;
            if ! $byindex { $pos++; }
            my $want-even;
            if $key eq 'EVEN'
            {
              $want-even = $val;
            }
            else
            {
              $want-even = $val ?? False !! True;
            }
            if $want-even && $pos % 2 !== 0 { $matched = False; last; }
            elsif ! $want-even && $pos % 2 == 0 { $matched = False; last; }
          }
          elsif $key eq 'TAG'
          {
            if $node.name !~~ $val { $matched = False; last; }
          }
          elsif $key eq 'NS' | 'URI'
          {
            my $prefix = $val;
            if $key eq 'URI'
            {
              $prefix = $node.nsPrefix($val);
              if !$prefix.defined() { $matched = False; last; }
            }
            if $prefix.defined && $prefix eq ''
            {
              if $node.name ~~ / ':' / { $matched = False; last; }
            }
            else
            {
              if $node.name !~~ / ^ $prefix ':' / { $matched = False; last; }
            }
          }
          else
          {
            if $val ~~ Bool
            {
              if $val === True
              {
                if $node.attribs{$key}:!exists { $matched = False; last; }
              }
              else
              {
                if $node.attribs{$key}:exists { $matched = False; last; }
              }
            }
            else
            {
              if $node.attribs{$key}:!exists || $node.attribs{$key} !~~ $val
              {
                $matched = False; last;
              }
            }
          }
        }
        if $matched
        {
          if $single
          {
            return $node;
          }
          else
          {
            @elements.push: $node;
          }
        }
        if ( $recurse && ($nest || !$matched ) )
        {
          my %opts = %query.clone;
          %opts<OBJECT> = False;
          %opts<RECURSE> = $recurse - 1;
          my $subelements = $node.elements(|%opts);
          if $subelements
          {
            if $subelements ~~ Array
            {
              @elements.push: |$subelements;
            }
            else
            {
              @elements.push: $subelements;
            }
          }
        }
        if ($single && @elements.elems > 0)
        {
          return @elements[0];
        }
        $nodepos++;
      }
    }
    if ($single)
    {
      return False;
    }

    if $object
    {
      my $new = self.new();
      $new.name = $.name;
      $new.idattr = $.idattr;
      $new.nodes = @elements;
      return $new;
    }
    return @elements;
  }

  ## Inspired by the DOM. If a matching element is found, it will
  ## return it, otherwise it will return null.
  method getElementById ($id)
  {
    my %query =
      'RECURSE' => Inf,
      'SINGLE'  => True,     ## an id should be unique, first come first serve.
      $.idattr  => $id,      ## the id attribute is configurable.
    ;
    return self.elements(|%query);
  }

  method getElementsByTagName ($name, Bool :$object)
  {
    my %query =
      'RECURSE' => Inf,
      'TAG'     => $name,
      'OBJECT'  => $object,
    ;
    return self.elements(|%query);
  }

  ## A way to look up an XML Namespace URI and find out what prefix it has.
  ## Returns Nil if there is no defined namespace prefix.
  ## Returns '' if the requested URI is the default XML namespace.
  method nsPrefix ($uri)
  {
    for $.attribs.kv -> $key, $val
    {
      if $val eq $uri && $key.match(/^xmlns(\:||$) <( .* )>/) -> $prefix
      {
        return ~$prefix;
      }
    }
    return $.parent.isa(XML::Element) ?? $.parent.nsPrefix($uri) !! Nil;
  }

  ## A way to look up an XML Namespace Prefix, and find out what URI it has.
  ## Returns Nil if there is no namespace assigned.
  ## Call it without a prefix or with a prefix of '' to find the default
  ## namespace URI.
  method nsURI ($prefix?)
  {
    if ($prefix)
    {
      if $.attribs{"xmlns:$prefix"}:exists
      {
        return $.attribs{"xmlns:$prefix"};
      }
    }
    else
    {
      if $.attribs{"xmlns"}:exists
      {
        return $.attribs{"xmlns"};
      }
    }
    return $.parent.isa(XML::Element) ?? $.parent.nsURI($prefix) !! Nil;
  }

  ## A quick way to set a namespace.
  method setNamespace ($uri, $prefix?)
  {
    if ($prefix)
    {
      $.attribs{"xmlns:$prefix"} = $uri;
    }
    else
    {
      $.attribs{"xmlns"} = $uri;
    }
  }

  # match-type($type)
  #   returns all child elements which are $type objects.
  #
  method match-type ($type)
  {
    my @elements;
    for @.nodes -> $node
    {
      if $node ~~ $type
      {
        @elements.push: $node;
      }
    }
    return @elements;
  }

  # comments()
  #   returns all child comments.
  #
  method comments()
  {
    self.match-type(XML::Comment);
  }

  # cdata()
  #   returns all child CDATA sections.
  #
  method cdata()
  {
    self.match-type(XML::CDATA);
  }

  # instructions()
  #   returns all child PI sections.
  #
  method instructions()
  {
    self.match-type(XML::PI);
  }

  # contents()
  #   returns all child text segments.
  #
  method contents()
  {
    self.match-type(XML::Text);
  }

  method Str()
  {
    my $element = '<' ~ $.name;
    for %.attribs.kv -> $key, $val
    {
      $element ~= " $key=\"$val\"";
    }
    if (@.nodes)
    {
      $element ~= '>';
      my $prev-node-string;
      for @.nodes -> $node
      {
        if
        (
          $prev-node-string.defined
          && $prev-node-string !~~ /\s+$/ && $node ~~ XML::Text
        )
        {
          $element ~= ' '; ## Add a space.
        }
        $prev-node-string  = ~$node;
        $element          ~= $prev-node-string;
      }
      $element ~= '</' ~ $.name ~ '>';
    }
    else
    {
      $element ~= '/>';
    }
    return $element;
  }

  method AT-POS ($offset)
  {
    my $self = self;
    Proxy.new(
      FETCH => method ()
      {
        $self.nodes[$offset];
      },
      STORE => method ($val)
      {
        $self.nodes[$offset] = $val;
      }
    );
  }

  method AT-KEY ($offset)
  {
    my $self = self;
    Proxy.new(
      FETCH => method ()
      {
        $self.attribs{$offset};
      },
      STORE => method ($val)
      {
        $self.set($offset, $val);
      }
    );
  }
}
