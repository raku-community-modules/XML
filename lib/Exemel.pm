## Exemel -- Object Oriented XML Library

## Exemel::CDATA - represents a CDATA section.
#  Data is preserved "as is ", right from the [ to the ]]>
class Exemel::CDATA {
  has $.data;
  method Str() {
    return '<![CDATA[' ~ $.data ~ ']]>';
  }
}

## Exemel::Comment - represents a comment.
#  Data is preserved "as is", right from the <!-- to the -->
class Exemel::Comment {
  has $.data;
  method Str() {
    return '<!--' ~ $.data ~ '-->';
  }
}

## Exemel::PI - represents a PI section.
#  Data is preserved "as is", right from the <? to the ?>
class Exemel::PI {
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
class Exemel::Text {
  has $.text;
  method Str() {
    my $text = $.text;
    $text ~~ s:g/\s+/ /;  ## Relace multiple whitespace with a single space.
    $text.=chomp;         ## Remove a trailing newline if it exists.
    return $text;
  }
  method string() {
    my $text = self.Str();
    $text ~~ s:g/\s+$//;  ## Chop out trailing spaces.
    return $text;
  }

}

class Exemel::Element {
  use Exemel::Grammar;
  has $.name;
  has @.nodes;
  has %.attribs;

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
  method elements (*%query) {
    my @elements;
    for @.nodes -> $node {
      if $node ~~ Exemel::Element {
        my $matched = True;
        for %query.kv -> $key, $val {
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

class Exemel::Document is Exemel::Element {
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
