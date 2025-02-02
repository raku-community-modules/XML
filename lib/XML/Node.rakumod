role XML::Node {
    has $.parent is rw;

    ## For XML classes, the gist is the stringified form.
    multi method gist(XML::Node:D:) {
        self.Str
    }

    method previousSibling() {
        if $.parent ~~ ::(q<XML::Element>) {
            my $pos = $.parent.index-of(* === self);
            if $pos > 0 {
                return $.parent.nodes[$pos-1];
            }
        }
        Nil
    }

    method nextSibling() {
        if $.parent ~~ ::(q<XML::Element>) {
            my $pos = $.parent.index-of(* === self);
            if $pos < $.parent.nodes.end {
                return $.parent.nodes[$pos+1];
            }
        }
        Nil
    }

    method remove() {
        if $.parent ~~ ::(q<XML::Element>) {
            $.parent.removeChild(self);
        }
        self
    }

    method reparent(::(q<XML::Element>) $parent) {
        self.remove if $.parent.defined;
        $.parent = $parent;
        self
    }

    method cloneNode() {
        self.clone
    }

    method ownerDocument() {
        $.parent ~~ ::(q<XML::Document>)
          ?? $.parent
          !! $.parent ~~ ::(q<XML::Node>)
            ?? $.parent.ownerDocument
            !! Nil
    }
}

# vim: expandtab shiftwidth=4
