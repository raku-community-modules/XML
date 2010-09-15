class Exemel::CDATA {
  has $.data;
  method Str() {
    return '<![CDATA[' ~ $.data ~ ']]>';
  }
}

class Exemel::Comment {
  has $.data;
  method Str() {
    return '<!--' ~ $.data ~ '-->';
  }
}

class Exemel::PI {
  has $.data;
  method Str() {
    return '<?' ~ $.data ~ '?>';
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

  method parse-node($node) {
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
          my $cdata = ~$c<cdata>;
          $child = Exemel::CDATA.new(:data($cdata));
        }
        elsif ($c<comment>) {
          my $comment = ~$c<comment>;
          $child = Exemel::Comment.new(:data($comment));
        }
        elsif ($c<pi>) {
          my $pi = ~$c<pi>;
          $child = Exemel::PI.new(:data($pi));
        }
        elsif ($c<text>) {
          $child = ~$c<text>;
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

  method Str() {
    my $element = '<' ~ $.name;
    for %.attribs.kv -> $key, $val {
      $element ~= " $key=\"$val\"";
    }
    if (@.nodes) {
      $element ~= '>';
      for @.nodes -> $node {
        $element ~= $node;
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
  has $.version;
  has $.encoding;
  has %.doctype;
  has $.root;

  method parse (Str $xml) {
    say "Yeah, we're in parse.";
    my $version = '1.0';
    my $encoding;
    my %doctype;
    my $root;
    my $doc = Exemel::Grammar.parse($xml);
    if ($doc) {
      say "And it matches!";
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
