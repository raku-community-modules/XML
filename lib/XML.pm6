## XML -- Object Oriented XML Library
use XML::Element;
use XML::Document;

module XML
{
  sub from-xml (Str $xml-string) is export
  {
    return XML::Document.new($xml-string);
  }

  sub from-xml-stream (IO $input) is export
  {
    return XML::Document.new($input.slurp);
  }

  sub from-xml-file (Str $file) is export
  {
    return XML::Document.load($file);
  }

  sub make-xml (Str $name, *@contents, *%attribs) is export
  {
    return XML::Element.craft($name, |@contents, |%attribs);
  }

}
