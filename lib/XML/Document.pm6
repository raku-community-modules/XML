use XML::Node;
use XML::Element;
use XML::Grammar;
use XML::Text;

class XML::Document does XML::Node
{
  has $.version = '1.0';
  has $.encoding;
  has %.doctype;
  has $.root handles <
    attribs nodes elements lookfor getElementById getElementsByTagName
    nsURI nsPrefix setNamespace
    append insert set unset before after
    appendNode insertNode insertBefore insertAfter
    replaceChild removeChild craft
  >;
  has $.filename; ## Optional, used for new load() and save() methods.

  method cloneNode ()
  {
    my $root = $.root.cloneNode;
    my $version = $.version.clone;
    my $encoding = $.encoding.clone;
    my %doctype = %.doctype.clone;
    my $filename = $.filename.clone;
    my $clone = self.new(:$version, :$encoding, :%doctype, :$root, :$filename);
    return $clone;
  }

  method AT-POS ($offset)
  {
    $.root[$offset];
  }

  method AT-KEY ($offset)
  {
    $.root{$offset};
  }

  multi method new (Str $xml, :$filename)
  {
    my $version = '1.0';
    my $encoding;
    my %doctype;
    my $root;
    my $doc = XML::Grammar.parse($xml);
    if ($doc)
    {
      #$*ERR.say: "We parsed the doc";
      if ($doc<xmldecl>)
      {
        $version = ~$doc<xmldecl><version><value>;
        $version ~~ s:g/\"//;		## get rid of any quotes in the version
        $version ~~ s:g/\'//;
        if ($doc<xmldecl><encoding>)
        {
          $encoding = ~$doc<xmldecl><encoding><value>;
	  $encoding ~~ s:g/\"//;		## get rid of any quotes in the version
	  $encoding ~~ s:g/\'//;
        }
      }
      if ($doc<doctypedecl>)
      {
        %doctype<type> = ~$doc<doctypedecl><name>;
        %doctype<value> = ~$doc<doctypedecl><content>;
      }
      $root = XML::Element.parse-node($doc<root>);
      my $this = self.new(:$version, :$encoding, :%doctype, :$root, :$filename);
      $root.parent = $this;
      return $this;
    }
    else
    {
      die "could not parse XML";
    }
  }

  multi method new (XML::Element $root)
  {
    my $this = self.new(:$root);
    $root.parent = $this;
    return $this;
  }

  method Str()
  {
    my $document = '<?xml version="' ~ $.version ~ '"';
    if $.encoding
    {
      $document ~= ' encoding="' ~ $.encoding ~ '"';
    }
    $document ~= '?>';
    if +%.doctype.keys > 0
    {
      $document ~= '<!DOCTYPE ' ~ %.doctype<type> ~ %.doctype<value> ~ '>';
    }
    $document ~= $.root;
    return $document;
  }

  ## The original XML::Document had no concept of files.
  ## I am now adding an optional load() and save() ability for quick
  ## XML configuration files, etc. This is completely optional, and
  ## can be ignored if you don't want to use it.

  ## load() is used instead of new() to create a new object.
  ## e.g.:  my $doc = XML::Document.load("myfile.xml");
  ##
  method load (Str $filename)
  {
    if ($filename.IO ~~ :f)
    {
      my $text = slurp($filename);
      return self.new($text, :$filename);
    }
    else
    {
      die "File '$filename' does not exist.";
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
  ##   $doc.save("newfilename.xml", :copy);
  ## Saves the XML to a new file. Does not override the existing filename,
  ## so future calls to save() will save to the original file, not the new one.
  ##
  method save (Str $filename?, Bool :$copy)
  {
    my $fname = $!filename;
    if ($filename)
    {
      $fname = $filename;
      if (!$copy)
      {
        $!filename = $filename;
      }
    }
    if (!$fname) { return False; }
    my $file = open $filename, :w;
    $file.say: self;
    $file.close;
  }

}
