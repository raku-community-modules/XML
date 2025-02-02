use XML::Node;

## XML::Comment - represents a comment.
## Data is preserved "as is", right from the <!-- to the -->
class XML::Comment does XML::Node {
    has $.data;
    method Str() {
        '<!--' ~ $.data ~ '-->';
    }
}

# vim: expandtab shiftwidth=4
