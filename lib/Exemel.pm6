## Exemel -- Object Oriented XML Library

## Exemel role, used for $object ~~ Exemel
## Also implements the $.parent attribute.
role Exemel {
  has $.parent is rw;
}

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
  has $.name is rw;          ## We may want to change element type.
  has @.nodes is rw;         ## Cloning requires rw.
  has %.attribs is rw;       ## Cloning requires rw.
  has $.idattr is rw = 'id'; ## Default id attribute is, well, 'id'.

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
      if ($clone.nodes[$i] ~~ Exemel) {
        $clone.nodes[$i].parent = $clone;
      }
    }
    return $clone;
  }

  method !reparent ($node) {
    if ($node ~~ Exemel) {
      $node.parent = self;
    }
    return $node;
  }

  method insert ($node) {
    @.nodes.unshift: self!reparent($node);
  }

  method append ($node) {
    @.nodes.push: self!reparent($node);
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

  method parse-node ($node, $mother?) {
    #$*ERR.say: "node: $node";
    my $name = $node<name>.Str;
    #$*ERR.say: "name: $name";
    my %attribs;
    my @nodes;

    #$*ERR.say: "attr elems: "~$node<attribute>.elems;

    if ($node<attribute>) {
      #$*ERR.say: "attribute found";
      for @($node<attribute>) -> $a {
        my $an = ~$a<name>;
        %attribs{$an} = ~$a<value>;
      }
    }

    my $parent = Exemel::Element.new(:$name, :%attribs);

    if ($mother) {
      $parent.parent = $mother;
    }

    #$*ERR.say: $node.caps;#.fmt('%s = %s',"\n");

    #$*ERR.say: "child elems: "~$node<child>.elems;

    if ($node<child>) {
      #$*ERR.say: "child found";
      for @($node<child>) -> $c {
        my $child;
        if ($c<cdata>) {
          my $data = ~$c<cdata><content>;
          $child = Exemel::CDATA.new(:$data, :$parent);
        }
        elsif ($c<comment>) {
          my $data = ~$c<comment><content>;
          $child = Exemel::Comment.new(:$data, :$parent);
        }
        elsif ($c<pi>) {
          my $data = ~$c<pi><content>;
          $child = Exemel::PI.new(:$data, :$parent);
        }
        elsif ($c<text>) {
          my $text = ~$c<text>;
          $child = Exemel::Text.new(:$text, :$parent);
        }
        elsif ($c<element>) {
          $child = self.parse-node($c<element>, $parent);
        }
        if defined $child {
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
  method elements (*%query is copy) {
    my @elements;
    for @.nodes -> $node {
      if $node ~~ Exemel::Element {
        my $matched = True;
        for %query.kv -> $key, $val {
          if $key eq 'RECURSE' { next; } # Skip recurse setting.
          if $key eq 'NEST'    { next; } # Skip nesting recurse setting.
          if $key eq 'SINGLE'  { next; } # Skup single element setting.
          
          if $key eq 'TAG' {
            if $node.name ne $val { $matched = False; }
          }
          elsif $key eq 'NS' | 'URI' {
            my $prefix = $val;
            if $key eq 'URI' {
              $prefix = self.nsPrefix($val);
            }
            if ($prefix eq '') {
              if $node.name ~~ / ':' / { $matched = False; }
            }
            else {
              ## Temporary hack until Rakudo's variable interpolation is
              ## working again in RegExes. 
              #if $node.name ~~ / ^ (\w+) ':' / {
              #  if $0.Str ne $prefix { $matched = False; }
              # }
              #else {
              #  $matched = False;
              #}
              ## Re-enable this code once variable interpolation is fixed.
              ## It seems to be working again, so I've re-enabled this.
              ## TODO: remove the above hackage in next release.
              if $node.name !~~ / ^ $prefix ':' / { $matched = False; }
            }
          }
          
          else {
            if ($val ~~ Bool) {
              if ! $node.attribs.exists($key) { $matched = False; }
            }
            else {
              if $node.attribs{$key} ne $val { $matched = False; }
            }
          }
        }
        if $matched {
          if (%query<SINGLE>) {
            return $node;
          }
          else {
            @elements.push: $node;
          }
        }
        if ( %query<RECURSE> && (%query<NEST> || !$matched ) ) {
          my %opts = %query.clone;
          %opts<RECURSE> = %query<RECURSE> - 1;
          my $subelements = $node.elements(|%opts);
          @elements.push: |$subelements;
        }
        if (%query<SINGLE> && @elements.elems > 0) {
          return @elements[0];
        }
      }
    }
    return @elements;
  }

  ## Inspired by the DOM. If a matching element is found, it will
  ## return it, otherwise it will return false.
  method getElementById ($id) {
    my %query = {
      'RECURSE' => 99,       ## don't nest this deep, please?
      'SINGLE'  => True,     ## an id should be unique, first come first serve.
      $.idattr  => $id,      ## the id attribute is configurable.
    };
    my $element = self.elements(|%query);
    if ($element) {
      return $element;
    }
  }

  ## A way to look up an XML Namespace URI and find out what prefix it has.
  ## Returns Nil if there is no defined namespace prefix.
  ## Returns '' if the requested URI is the default XML namespace.
  method nsPrefix ($uri) {
    for $.attribs.kv -> $key, $val {
      if $val eq $uri {
        return $key.subst(/^xmlns\:?/, '');
      }
    }
    return;
  }

  ## A way to look up an XML Namespace Prefix, and find out what URI it has.
  ## Returns Nil if there is no namespace assigned.
  ## Call it without a prefix or with a prefix of '' to find the default
  ## namespace URI.
  method nsURI ($prefix?) {
    if ($prefix) {
      if $.attribs.exists("xmlns:$prefix") {
        return $.attribs{"xmlns:$prefix"};
      }
    }
    else {
      if $.attribs.exists("xmlns") {
        return $.attribs{"xmlns"};
      }
    }
    return;
  }

  ## A quick way to set a namespace.
  method setNamespace ($uri, $prefix?) {
    if ($prefix) {
      $.attribs{"xmlns:$prefix"} = $uri;
    }
    else {
      $.attribs{"xmlns"} = $uri;
    }
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
        if (                ## Use this on anything now.
          defined $lastnode #&& $lastnode ~~ Exemel::Text 
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
  has $.root is rw; ## not sure I like this being rw, but needed for $.parent.
  has $.filename is rw; ## Optional, used for new load() and save() methods.

  method parse (Str $xml) {
    my $version = '1.0';
    my $encoding;
    my %doctype;
    my $root;
    my $doc = Exemel::Grammar.parse($xml);
    if ($doc) {
      #$*ERR.say: "We parsed the doc";
      if ($doc<xmldecl>) {
        $version = ~$doc<xmldecl>[0]<version><value>;
        if ($doc<xmldecl>[0]<encoding>) {
          $encoding = ~$doc<xmldecl>[0]<encoding>[0]<value>;
        }
      }
      if ($doc<doctypedecl>) {
        %doctype<type> = ~$doc<doctypedecl>[0]<name>;
        %doctype<value> = ~$doc<doctypedecl>[0]<content>;
      }
      my $document = Exemel::Document.new(:$version, :$encoding, :%doctype);
      $root = Exemel::Element.parse-node($doc<root>, $document);
      $document.root = $root;
      return $document;
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

  ## The original Exemel::Document had no concept of files.
  ## I am now adding an optional load() and save() ability for quick
  ## XML configuration files, etc. This is completely optional, and
  ## can be ignored if you don't want to use it.

  ## load() is used instead of parse() to create a new object.
  ## e.g.:  my $doc = Exemel::Document.load("myfile.xml");
  ##
  method load (Str $filename) {
    if ($filename.IO ~~ :f) {
      my $text = slurp($filename);
      my $xml = self.parse($text);
      $xml.filename = $filename;
      return $xml;
    }
  }

  ## save() is used on an instance. It has three forms.
  ##
  ##   $doc.save();
  ## Saves back to the file that was loaded previously.
  ## If there is no filename set, this will return false.
  ##
  ##   $doc.save("newfilename.xml");
  ## Saves the XML to a new file. Sets the new filename to the default,
  ## so that future calls to save() will use the new filename.
  ##
  ##   $doc.save("newfilename.xml", true);
  ## Saves the XML to a new file. Does not override the existing filename,
  ## so future calls to save() will save to the original file, not the new one.
  ##
  method save (Str $filename?, Bool $copy?) {
    my $fname = $.filename;
    if ($filename) {
      $fname = $filename;
      if (!$copy) {
        $.filename = $filename;
      }
    }
    if (!$fname) { return False; }
    my $file = open $filename, :w;
    $file.say: self;
    $file.close;
  }

}
