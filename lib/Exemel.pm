## Exemel -- Object Oriented XML Library

## Exemel abstract role, used for $object ~~ Exemel
role Exemel {}

## Exemel::CDATA - represents a CDATA section.
#  Data is preserved "as is ", right from the [ to the ]]>
class Exemel::CDATA does Exemel {
  has $.data;
  method Str() {
    return '<![CDATA[' ~ $.data ~ ']]>';
  }
}

## Exemel::Comment - represents a comment.
#  Data is preserved "as is", right from the <!-- to the -->
class Exemel::Comment does Exemel {
  has $.data;
  method Str() {
    return '<!--' ~ $.data ~ '-->';
  }
}

## Exemel::PI - represents a PI section.
#  Data is preserved "as is", right from the <? to the ?>
class Exemel::PI does Exemel {
  has $.data;
  method Str() {
    return '<?' ~ $.data ~ '?>';
  }
}

## Exemel::Text - represents a text node.
#  The original text is stored in the 'text' attribute, and is
#  preserved in its original format, including whitespace.
#  The default stringification removes extra whitespace, and chomps
#  the string. If this is not what you expect, call .text directly.
class Exemel::Text does Exemel {
  has $.text;
  method Str(:$strip) {
    my $text = $.text;
    $text ~~ s:g/\s+/ /;  ## Relace multiple whitespace with a single space.
    if $strip {
        $text ~~ s:g/\s+$//;  ## Chop out trailing spaces.
        $text ~~ s:g/^\s+//;  ## Chop out leading spaces.
    }
    $text.=chomp;         ## Remove a trailing newline if it exists.
    return $text;
  }
  method string() {
    return self.Str(:strip);
  }
}

class Exemel::Element does Exemel {
  use Exemel::Grammar;
  has $.name is rw;    ## We may want to change element type.
  has @.nodes is rw;   ## Cloning requires rw.
  has %.attribs is rw; ## Cloning requires rw.

  method deep-clone() {
    my $clone = self.clone;
    $clone.attribs = $clone.attribs.clone;
    $clone.nodes = $clone.nodes.clone;
    loop (my $i=0; $i < $clone.nodes.elems; $i++) {
      if ($clone.nodes[$i] ~~ Exemel::Element) {
        $clone.nodes[$i] = $clone.nodes[$i].deep-clone;
      }
      else {
        $clone.nodes[$i] = $.nodes[$i].clone;
      }
    }
    return $clone;
  }

  method insert ($node) {
    @.nodes.unshift: $node;
  }

  method append ($node) {
    @.nodes.push: $node;
  }

  method set ($attrib, $value) {
    if $value ~~ Str|Numeric {
      %.attribs{$attrib} = $value;
    }
    if $value ~~ Bool {
      if $value {
        %.attribs{$attrib} = $attrib;
      }
      else {
        %.attribs.delete($attrib);
      }
    }
  }

  method unset ($attrib) {
    %.attribs.delete($attrib);
  }

  method insert-xml (Str $xml) {
    my $element = self.parse($xml);
    self.insert: $element;
  }

  method append-xml (Str $xml) {
    my $element = self.parse($xml);
    self.append: $element;
  }

  method parse (Str $xml) {
    my $match = Exemel::Grammar.parse($xml);
    if ($match) {
      return self.parse-node($match<root>);
    }
    return;
  }

  method parse-node ($node) {
    my $name = ~$node<name>;
    my %attribs;
    my @nodes;

    if ($node<attribute>) {
      for @($node<attribute>) -> $a {
        my $an = ~$a<name>;
        %attribs{$an} = ~$a<value>;
      }
    }
    if ($node<child>) {
      for @($node<child>) -> $c {
        my $child;
        if ($c<cdata>) {
          my $cdata = ~$c<cdata><content>;
          $child = Exemel::CDATA.new(:data($cdata));
        }
        elsif ($c<comment>) {
          my $comment = ~$c<comment><content>;
          $child = Exemel::Comment.new(:data($comment));
        }
        elsif ($c<pi>) {
          my $pi = ~$c<pi><content>;
          $child = Exemel::PI.new(:data($pi));
        }
        elsif ($c<text>) {
          $child = Exemel::Text.new(:text(~$c<text>));
        }
        elsif ($c<element>) {
          $child = self.parse-node($c<element>);
        }
        if defined $child {
          @nodes.push: $child;
        }
      }
    }
    return Exemel::Element.new(:$name, :%attribs, :@nodes);
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
  #  There are two other 'special' tags that don't match attributes, but
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
  method elements (*%query is copy) {
    my @elements;
    for @.nodes -> $node {
      if $node ~~ Exemel::Element {
        my $matched = True;
        for %query.kv -> $key, $val {
          if $key eq 'RECURSE' { next; } # Skip recurse setting.
          if $key eq 'NEST'    { next; } # Skip nesting recurse setting.
          
          if $key eq 'TAG' {
            if $node.name ne $val { $matched = False; }
          }
          else {
            if $node.attribs{$key} ne $val { $matched = False; }
          }
        }
        if $matched {
          @elements.push: $node;
        }
        if ( %query<RECURSE> && (%query<NEST> || !$matched ) ) {
          my %opts = %query.clone;
          %opts<RECURSE> = %query<RECURSE> - 1;
          my @subelements = $node.elements(|%opts);
          @elements.push: |@subelements;
        }
      }
    }
    return @elements;
  }

  # match-type($type)
  #   returns all child elements which are $type objects.
  #
  method match-type ($type) {
    my @elements;
    for @.nodes -> $node {
      if $node ~~ $type {
        @elements.push: $node;
      }
    }
    return @elements;
  }

  # comments()
  #   returns all child comments.
  #
  method comments() {
    self.match-type(Exemel::Comment);
  }

  # cdata()
  #   returns all child CDATA sections.
  #
  method cdata() {
    self.match-type(Exemel::CDATA);
  }

  # instructions()
  #   returns all child PI sections.
  #
  method instructions() {
    self.match-type(Exemel::PI);
  }

  # contents()
  #   returns all child text segments.
  #
  method contents() {
    self.match-type(Exemel::Text);
  }

  method Str() {
    my $element = '<' ~ $.name;
    for %.attribs.kv -> $key, $val {
      $element ~= " $key=\"$val\"";
    }
    if (@.nodes) {
      $element ~= '>';
      my $lastnode;
      for @.nodes -> $node {
        if (
          defined $lastnode && $lastnode ~~ Exemel::Text 
          && ~$lastnode !~~ /\s+$/ && $node ~~ Exemel::Text
        ) {
          $element ~= ' '; ## Add a space.
        }
        $element ~= $node;
        $lastnode = $node;
      }
      $element ~= '</' ~ $.name ~ '>';
    }
    else {
      $element ~= '/>';
    }
    return $element;
  }

}

class Exemel::Document does Exemel {
  use Exemel::Grammar;
  has $.version = '1.0';
  has $.encoding;
  has %.doctype;
  has $.root;

  method parse (Str $xml) {
    my $version = '1.0';
    my $encoding;
    my %doctype;
    my $root;
    my $doc = Exemel::Grammar.parse($xml);
    if ($doc) {
      if ($doc<xmldecl>) {
        $version = ~$doc<xmldecl><version><value>;
        if ($doc<xmldecl><encoding>) {
          $encoding = ~$doc<encoding><value>;
        }
      }
      if ($doc<doctypedecl>) {
        %doctype<type> = ~$doc<doctypedecl><name>;
        %doctype<value> = ~$doc<doctypedecl><content>;
      }
      $root = Exemel::Element.parse-node($doc<root>);
      return Exemel::Document.new(:$root, :$version, :$encoding, :%doctype);
    }
    return;
  }

  method Str() {
    my $document = '<?xml version="' ~ $.version ~ '"';
    if $.encoding {
      $document ~= ' encoding="' ~ $.encoding ~ '"';
    }
    $document ~= '?>';
    if +%.doctype.keys > 0 {
      $document ~= '<!DOCTYPE ' ~ %.doctype<type> ~ %.doctype<value> ~ '>';
    }
    $document ~= $.root;
    return $document;
  }

}
