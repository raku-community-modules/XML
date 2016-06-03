use XML::Node;

## XML::CDATA - represents a CDATA section.
## Data is preserved "as is ", right from the [ to the ]]>
class XML::CDATA does XML::Node
{
  has $.data;
  method Str ()
  {
    return '<![CDATA[' ~ $.data ~ ']]>';
  }
}
