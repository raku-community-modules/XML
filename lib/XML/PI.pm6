use XML::Node;

## XML::PI - represents a PI section.
## Data is preserved "as is", right from the <? to the ?>
class XML::PI does XML::Node
{
  has $.data;
  method Str ()
  {
    return '<?' ~ $.data ~ '?>';
  }
}
